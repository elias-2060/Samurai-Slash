extends CharacterBody2D

# Player object
@onready var player = $"../../Player"
# Enemy object
@onready var enemy = $AnimatedSprite2D
# Enemy attackBox
@onready var attack_box = $Hitbox/AttackBox

# Enemy stats
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const ATTACK_DAMAGE = 5
var hitpoints = 100
const ATTACK_RANGE = 65
const IDLE_TIME = 1
const ATTACKTIME = 0.3

# Enemy states
enum EnemyState { IDLE, CHASING, ATTACKING, HURT, DYING, DEAD }
var state = EnemyState.CHASING
var prevState
var idle_timer = 0.0
var attack_timer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# When enemy gets hit take damage.
func take_damage(attack_damage):
	prevState = state
	state = EnemyState.HURT
	hitpoints -= attack_damage

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
		EnemyState.ATTACKING:
			velocity.x = 0
			attack_player()
			attack_timer += delta
			if attack_timer >= ATTACKTIME:
				attack_timer = 0.0
				attack_box.disabled = false
				state = EnemyState.IDLE
		EnemyState.HURT:
			attack_box.disabled = true
			enemy.play("hurt")
		EnemyState.DYING:
			velocity.x = 0
			attack_box.disabled = true
			enemy.play("dying")
			
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle movement
	move_and_slide()

func chase_player():
	enemy.play("running")
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
	if distance_to_player < ATTACK_RANGE:
		state = EnemyState.ATTACKING

func attack_player():
	# Play attack animation
	enemy.play("attack")


func _on_animated_sprite_2d_animation_finished():
	if enemy.animation == "hurt":
		if (prevState != 3):
			state = prevState
		else:
			state = EnemyState.CHASING
	elif enemy.animation == "dying":
		state = EnemyState.DEAD
		queue_free()

func _on_hurtbox_area_entered(area):
	var entity = area.get_parent()
	if entity.comboCount == 1:
		take_damage(entity.attack_damage)
	elif entity.comboCount == 2:
		take_damage(entity.attack_damage2)
	elif entity.comboCount == 3:
		take_damage(entity.attack_damage3)
