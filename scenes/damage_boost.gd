extends CharacterBody2D

# Player object
@onready var player = $"../../Player"

const ATTACK_DAMAGE_BOOST = 10
const BOOST_DURATION = 10.0
const SPEED = 0


# Movement and collision handling
func _physics_process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * SPEED)
	if collision_info:
		var colider = collision_info.get_collider()
		if colider == player:
			player.add_attack_boost(ATTACK_DAMAGE_BOOST, BOOST_DURATION)
			queue_free()
