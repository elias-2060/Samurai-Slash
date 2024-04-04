extends CharacterBody2D

@onready var player = $"../../Player"
const ATTACK_DAMAGE = 10
const SPEED = 1200.0


# Movement and collision handling
func _physics_process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * SPEED)
	if collision_info:
		var colider = collision_info.get_collider()
		if colider == player:
			player.take_damage(ATTACK_DAMAGE)
		queue_free()
