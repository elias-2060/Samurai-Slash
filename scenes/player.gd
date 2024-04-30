extends CharacterBody2D

# Player stats
var speed = 350.0
const JUMP_VELOCITY = -550.0
var attack_damage = 20
var attack_damage2 = 25
var attack_damage3 = 30
const COMBO_TIME_LIMIT = 0.5
const MAX_HEALTH = 200
var hitpoints = 0

# Player states
var isAttacking = false
var isRunning = false
var isJumping = false
var isIdle = false
var isHurt = false
var isDying = false
var isDead = false
var power_up_duration = 0
var power_up_time = 0
var damage_boost = false
var speed_boost = false
var invincible_boost = false
var attackAnimationFinished = true
var isGrounded


# Combo Attack
var comboCount = 0
var comboResetTimer = 0

# Player object
@onready var player = $AnimatedSprite2D
# Camera object
@onready var camera_2d = $Camera2D
# AnimationPlayer object
@onready var animation_player = $AnimationPlayer

# Player sword hitboxs
@onready var attack_1_hitbox = $Hitbox/Attack1Hitbox
@onready var attack_2_hitbox = $Hitbox/Attack2Hitbox
@onready var attack_3_hitbox = $Hitbox/Attack3Hitbox

@onready var healthbar = $Healthbar
# Boost objects
@onready var damage_boost_object = $BoostMenu/HBoxContainer/damageBoost
@onready var speed_boost_object = $BoostMenu/HBoxContainer/speedBoost
@onready var invincibility_boost_object = $BoostMenu/HBoxContainer/invincibilityBoost
@onready var dust = $Dust



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	hitpoints = MAX_HEALTH
	healthbar.init_health(hitpoints)


func reset():
	isDead = false
	isDying = false
	remove_speed_boost()
	remove_invincible_boost()
	remove_attack_boost()
	_ready()
	
# When player gets hit take damage.
func take_damage(damage):
	if !invincible_boost:
		isHurt = true
		isIdle = false
		hitpoints -= damage
		healthbar.health = hitpoints
	
func add_attack_boost(attack_boost, duration):
	attack_damage += attack_boost
	attack_damage2 += attack_boost
	attack_damage3 += attack_boost
	power_up_duration = duration
	power_up_time = 0
	damage_boost = true
	
func add_speed_boost(boost, duration):
	speed += boost
	power_up_duration = duration
	power_up_time = 0
	speed_boost = true

func add_max_health_boost():
	hitpoints = MAX_HEALTH
	healthbar.health = hitpoints

func add_invincible_boost(duration):
	power_up_duration = duration
	power_up_time = 0
	invincible_boost = true
	

func remove_speed_boost():
	speed = 350
	power_up_duration = 9999999
	speed_boost = false
	
func remove_invincible_boost():
	invincible_boost = false
	power_up_duration = 9999999

func remove_attack_boost():
	attack_damage = 20
	attack_damage2 = 25
	attack_damage3 = 30
	power_up_duration = 9999999
	damage_boost = false
	

func _physics_process(delta):
	# Play dust animation when player lands
	if isGrounded == false and is_on_floor() == true:
		dust.visible = true
		dust.play("dust")
		
	isGrounded = is_on_floor()
	# show the boost in the menu if it is active
	if damage_boost:
		damage_boost_object.visible = true
	else:
		damage_boost_object.visible = false
		
	if speed_boost:
		speed_boost_object.visible = true
	else:
		speed_boost_object.visible = false
		
	if invincible_boost:
		invincibility_boost_object.visible = true
	else:
		invincibility_boost_object.visible = false
	# make the player invincible if he has the boost
	if invincible_boost:
		animation_player.play("invincible")
		
	power_up_time += delta
	if power_up_time >= power_up_duration:
		if damage_boost:
			remove_attack_boost()
		elif speed_boost:
			remove_speed_boost()
		elif invincible_boost:
			remove_invincible_boost()
		
	# Set dying state
	if hitpoints <= 0:
		hitpoints = -1
		isDying = true
		isIdle = false
	
	# Animations
	if isDying:
		player.play("dying")
	elif isHurt:
		player.play("hurt")
	elif isAttacking:
		if comboCount == 1:
			attack_1_hitbox.disabled = false
		elif comboCount == 2:
			attack_2_hitbox.disabled = false
		elif comboCount == 3:
			attack_3_hitbox.disabled = false
		attackAnimationFinished = false
		player.play("attack " + str(comboCount)) # Change animation based on combo count
	elif isJumping:
		player.play("jumping")
	elif isRunning:
		player.play("running")
	elif isIdle:
		player.play("idle")

		
	# Set the running state
	if abs(velocity.x) > 1 and is_on_floor():
		isRunning = true
		isJumping = false
	# Add the gravity
	elif not is_on_floor():
		velocity.y += gravity * delta
	# Set the idle state
	elif is_on_floor():
		isIdle = true
		isJumping = false
		isRunning = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		isJumping = true
		velocity.y = JUMP_VELOCITY
	# Handle attack
	elif Input.is_action_just_pressed("slash") and attackAnimationFinished == true:
		if comboResetTimer == 0:
			comboCount = 1
		else:
			comboCount += 1
			if comboCount > 3:
				comboCount = 1 # Reset combo if exceeds max combo count
		comboResetTimer = COMBO_TIME_LIMIT
		isAttacking = true
	# Update combo reset timer
	if comboResetTimer > 0:
		comboResetTimer -= delta
		if comboResetTimer <= 0:
			comboCount = 1
			comboResetTimer = 0

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 25)

	move_and_slide()

	# If the player is going left or right turn the player to the left or right.
	if velocity.x < 0:
		player.flip_h = true
		attack_1_hitbox.position.x = -abs(attack_1_hitbox.position.x)
		attack_2_hitbox.position.x = -abs(attack_2_hitbox.position.x)
		attack_2_hitbox.rotation = -abs(attack_2_hitbox.rotation)
		attack_3_hitbox.position.x = -abs(attack_3_hitbox.position.x)
		attack_3_hitbox.rotation = abs(attack_3_hitbox.rotation)
	elif velocity.x > 0:
		attack_1_hitbox.position.x = abs(attack_1_hitbox.position.x)
		attack_2_hitbox.position.x = abs(attack_2_hitbox.position.x)
		attack_2_hitbox.rotation = abs(attack_2_hitbox.rotation)
		attack_3_hitbox.position.x = abs(attack_3_hitbox.position.x)
		attack_3_hitbox.rotation = -abs(attack_3_hitbox.rotation)
		player.flip_h = false

# If the attack animation ended, disable the sword hitbox and set attacking to false.
func _on_animated_sprite_2d_animation_finished():
	if player.animation == "attack 1" or player.animation == "attack 2" or player.animation == "attack 3":
		attack_1_hitbox.disabled = true
		attack_2_hitbox.disabled = true
		attack_3_hitbox.disabled = true
		isAttacking = false
		attackAnimationFinished = true
	elif player.animation == "hurt":
		isHurt = false
		isIdle = true
	elif player.animation == "dying":
		isDying = false
		isDead= true
		isIdle = true
		


func _on_hurtbox_area_entered(area):
	var enemy = area.get_parent()
	take_damage(enemy.ATTACK_DAMAGE)


func _on_dust_animation_finished():
	dust.visible = false
