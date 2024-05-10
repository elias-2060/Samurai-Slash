extends Node2D

# Player object
@onready var player = $"../../Player"
@onready var animation_player = $AnimationPlayer


# Play animation
func _physics_process(_delta):
	animation_player.play("animation")


func _on_area_2d_area_entered(_area):
	player.add_max_health_boost()
	queue_free()
