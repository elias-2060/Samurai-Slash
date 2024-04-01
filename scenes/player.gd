extends CharacterBody2D

# Player stats
var speed = 350.0
const JUMP_VELOCITY = -550.0
const ATTACK_DAMAGE = 20
const ATTACK_DAMAGE2 = 25
const ATTACK_DAMAGE3 = 30
const COMBO_TIME_LIMIT = 0.5
var hitpoints = 1000

# Player states
var isAttacking = false
var isRunning = false
var isJumping = false
var isIdle = false
var isHurt = false
var isDying = false
var isDead = false

# Combo Attack
var comboCount = 0
var comboResetTimer = 0


# Player object
@onready var player = $AnimatedSprite2D

# Player sword hitboxs
@onready var attack_1_hitbox = $Hitbox/Attack1Hitbox
@onready var attack_2_hitbox = $Hitbox/Attack2Hitbox
@onready var attack_3_hitbox = $Hitbox/Attack3Hitbox

var attackAnimationFinished = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# When player gets hit take damage.
func take_damage(attack_damage):
	isHurt = true
	isIdle = false
	hitpoints -= attack_damage

func _physics_process(delta):
	# Set dying state
	if hitpoints <= 0:
		hitpoints = -1
		isDying = true
		isIdle = false
	
	# Animations
	if isDying:
		player.play("dying")
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
	elif isHurt:
		player.play("hurt")
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
