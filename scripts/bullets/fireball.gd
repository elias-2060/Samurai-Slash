extends CharacterBody2D

# Player object
@onready var player = $"../../../../Player"
# Fireball object
@onready var animated_sprite_2d = $AnimatedSprite2D

const ATTACK_DAMAGE = 25
const SPEED = 800.0


# Movement and collision handling
func _physics_process(delta):
	animated_sprite_2d.play("fireball")
	var collision_info = move_and_collide(velocity.normalized() * delta * SPEED)
	if collision_info:
		var colider = collision_info.get_collider()
		if colider == player:
			player.take_damage(ATTACK_DAMAGE)
		queue_free()
