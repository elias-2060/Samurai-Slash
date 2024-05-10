extends Control

@onready var player = $"../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !visible:
		position.x = player.global_position.x - 450
		position.y = player.global_position.y - 450
