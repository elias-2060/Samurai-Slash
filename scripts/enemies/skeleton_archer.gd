extends CharacterBody2D

@onready var bullet = $Bullet

# Player object
@onready var player = $"../../Player"
# Enemy object
@onready var enemy = $AnimatedSprite2D
# Enemy hitbox object
@onready var attack_box = $Hitbox/AttackBox
# Enemy bullet object
const arrowObject = preload("res://scenes/bullets/arrow.tscn")
@onready var healthbar = $Healthbar
@onready var hit_sound = $HitSound
@onready var knife_attack = $KnifeAttack
@onready var dying_sound = $DyingSound
@onready var shoot_sound = $ShootSound


# Enemy stats
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var hitpoints = 50
const ATTACK_RANGE = 550
const ATTACK_RANGE2 = 60
const IDLE_TIME = 1.5
const HEIGHT = 13
const ATTACKTIME = 0.3
const ATTACK_DAMAGE = 5
const score = 20

# Enemy states
enum EnemyState { IDLE, CHASING, ATTACKING, ATTACKING2, HURT, DYING, DEAD }
var state = EnemyState.IDLE
var prevState
var idle_timer = 0.0
var attack_timer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	healthbar.init_health(hitpoints)

# When enemy gets hit take damage.
func take_damage(attack_damage):
	prevState = state
	state = EnemyState.HURT
	hitpoints -= attack_damage
	healthbar.health = hitpoints

func _physics_process(delta):
	# Set dying state
	if hitpoints <= 0:
		hitpoints = -1
		state = EnemyState.DYING
	

	match state:
		EnemyState.IDLE:
			velocity.x = 0
			attack_box.disabled = true
			enemy.play("idle")
			idle_timer += delta
			if idle_timer >= IDLE_TIME:
				idle_timer = 0.0
				state = EnemyState.CHASING
		EnemyState.CHASING:
			attack_box.disabled = true
			chase_player()
		EnemyState.ATTACKING2:
			velocity.x = 0
			attack_box.disabled = true
			knife_attack.play()
			enemy.play("attack 2")
			attack_timer += delta
			if attack_timer >= ATTACKTIME:
				attack_timer = 0.0
				attack_box.disabled = false
				state = EnemyState.IDLE
		EnemyState.ATTACKING:
			velocity.x = 0
			attack_player()
		EnemyState.HURT:
			attack_box.disabled = true
			enemy.play("hurt")
		EnemyState.DYING:
			if !dying_sound.playing:
				dying_sound.play()
			velocity.x = 0
			attack_box.disabled = true
			enemy.play("dying")
	
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle movement
	move_and_slide()

func chase_player():
	enemy.play("walking")
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	# Flip sprite
	if direction.x < 0:
		enemy.flip_h = true
		attack_box.position.x = -abs(attack_box.position.x)
	elif direction.x > 0:
		enemy.flip_h = false
		attack_box.position.x = abs(attack_box.position.x)
	# Transition to attacking state if in range
	var distance_to_player = global_position.distance_to(player.global_position)
	var rangeAttack = randi_range(500, ATTACK_RANGE)
	if distance_to_player < ATTACK_RANGE2:
		state = EnemyState.ATTACKING2
	elif distance_to_player < rangeAttack and distance_to_player > 200:
		state = EnemyState.ATTACKING

func attack_player():
	# Play attack animation
	enemy.play("attack")


func _on_animated_sprite_2d_animation_finished():
	if enemy.animation == "hurt":
		if (prevState != 4 and prevState != 2):
			state = prevState
		else:
			state = EnemyState.CHASING
	elif enemy.animation == "attack":
		if EnemyState.ATTACKING:
			shoot_sound.play()
			shoot()
			state = EnemyState.IDLE
	elif enemy.animation == "dying":
		state = EnemyState.DEAD
		queue_free()

func _on_hurtbox_area_entered(area):
	hit_sound.play()
	var entity = area.get_parent()
	if entity.comboCount == 1:
		take_damage(entity.attack_damage)
	elif entity.comboCount == 2:
		take_damage(entity.attack_damage2)
	elif entity.comboCount == 3:
		take_damage(entity.attack_damage3)
		
func shoot():
	# Create a new instance of the bullet object
	var arrow = arrowObject.instantiate()

	# Set the position of the bullet to the enemy's position
	arrow.global_position = global_position
	arrow.global_position.y -= HEIGHT

	# Calculate the direction towards the player
	var direction = (player.global_position - global_position).normalized()

	# Set the bullet's velocity to move towards the player
	if player.is_on_floor():
		direction.y = 0
	arrow.velocity = direction
	
	# Calculate the angle between the direction vector and the horizontal axis
	var angle = direction.angle()

	# Rotate the arrow sprite to the calculated angle
	arrow.rotation_degrees = angle * 180 / PI  # Convert angle to degrees
	
	# Rotate the collision shape as well
	var collision_shape = arrow.get_node("Hitbox")
	collision_shape.rotation_degrees = arrow.rotation_degrees

	# Add the bullet to the scene
	bullet.add_child(arrow)
