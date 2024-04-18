extends Node2D

# Player object
@onready var player = $"../../Player"
@onready var animation_player = $AnimationPlayer

const BOOST_DURATION = 10.0


# Play animation
func _physics_process(_delta):
	animation_player.play("animation")


func _on_area_2d_area_entered(_area):
	player.add_invincible_boost(BOOST_DURATION)
	queue_free()
