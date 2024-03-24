extends CharacterBody2D

# Enemy object
@onready var enemy = $AnimatedSprite2D
# Enemy attackBox
@onready var attack_box = $Hitbox/AttackBox

# Enemy stats
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ATTACK_DAMAGE = 10
var hitpoints = 100

# Enemy states
var isIdle = true
var isRunning = false
var isAttacking = false
var isDying = false
var isHurt = false
var isDead = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# When enemy gets hit take damage.
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
		enemy.play("dying")
	elif isAttacking:
		attack_box.disabled = false
		enemy.play("attack")
	elif isRunning:
		enemy.play("running")
	elif isHurt:
		enemy.play("hurt")
	elif isIdle:
		enemy.play("idle")
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Set the running state
	if abs(velocity.x) > 1 and is_on_floor():
		isRunning = true
	elif is_on_floor():
		isIdle = true
		isRunning = false
		
		
	# Handle attack
	if Input.is_action_just_pressed("slashTest"):
		isAttacking = true
		isIdle = false
		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_action_strength("rightTest") - Input.get_action_strength("leftTest")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 25)
		
		
	# If the player is going left or right turn the player to the left or right.
	if velocity.x < 0:
		enemy.flip_h = true
		attack_box.position.x = -abs(attack_box.position.x)
	elif velocity.x > 0:
		enemy.flip_h = false
		attack_box.position.x = abs(attack_box.position.x)
		
		

	move_and_slide()


func _on_hurtbox_area_entered(area):
	var player = area.get_parent()
	if player.comboCount == 1:
		take_damage(player.ATTACK_DAMAGE)
	elif player.comboCount == 2:
		take_damage(player.ATTACK_DAMAGE2)
	elif player.comboCount == 3:
		take_damage(player.ATTACK_DAMAGE3)


func _on_animated_sprite_2d_animation_finished():
	if enemy.animation == "hurt":
		isHurt = false
		isIdle = true
	elif enemy.animation == "attack":
		attack_box.disabled = true
		isAttacking = false
	elif enemy.animation == "dying":
		isDying = false
		isDead= true
		isIdle = true
