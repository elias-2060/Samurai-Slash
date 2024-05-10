extends Control

# Reference to the player node
var player

# Maximum position limits
var maxX = 2039
var maxXleft = -682
var maxY = 39.7198181152344

func _ready():
	# Assuming the player node is named "Player"
	player = get_parent()

func _process(_delta):
	# Update the control box position to match the player's position
	global_position.x = player.global_position.x - 330
	global_position.y = 39.7198181152344

	# Clamp the control box position within the maximum limits
	global_position.x = clamp(global_position.x, maxXleft, maxX)
