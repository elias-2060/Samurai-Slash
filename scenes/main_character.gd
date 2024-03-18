extends CharacterBody2D

const SPEED = 350.0
const JUMP_VELOCITY = -550.0
@onready var sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var isAttacking = false

func _ready():
	sprite_2d.connect("animation_finished", _on_animated_sprite_2d_animation_finished, )


func _physics_process(delta):
	# Animations
	if isAttacking:
		sprite_2d.play("attack 1")
	elif not is_on_floor():
		sprite_2d.play("jumping")
	elif abs(velocity.x) > 1 and is_on_floor():
		sprite_2d.play("running")
	elif is_on_floor():
		sprite_2d.play("idle")

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle attack
	if Input.is_action_just_pressed("slash"):
		isAttacking = true

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 25)

	move_and_slide()

	# If the player is going left turn the player to the left.
	sprite_2d.flip_h = velocity.x < 0


func _on_animated_sprite_2d_animation_finished():
	if sprite_2d.animation == "attack 1":
		isAttacking = false
