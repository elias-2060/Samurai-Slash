extends Node

# Player object
@onready var player = $"../Player"

@onready var enemys = $"../Enemy's"

# Enemies
const NIVEAU_ONE = [
	preload("res://scenes/wolf_enemy.tscn"),
	preload("res://scenes/skeleton_warrior.tscn"),
	preload("res://scenes/skeleton_archer.tscn"),
]

const NIVEAU_TWO = [
	preload("res://scenes/wolf_enemy_white.tscn"),
	preload("res://scenes/skeleton_spear.tscn"),
	preload("res://scenes/knight_white.tscn"),
	preload("res://scenes/fire_wizard.tscn"),
	preload("res://scenes/firespirit.tscn"),
]

const NIVEAU_THREE = [
	preload("res://scenes/wolf_enemy_red.tscn"),
	preload("res://scenes/knight_red.tscn"),
	preload("res://scenes/lightning_mage.tscn"),
]

const NIVEAU_FOUR = [
	preload("res://scenes/knight_pink.tscn"),
	preload("res://scenes/dark_magican.tscn"),
	preload("res://scenes/kitsune.tscn"),
]

# Variables
var current_wave = 0
var enemies_left_in_wave = 0
var wave_enemy_limit = 2 # Initial limit for enemies in each wave
var current_niveau = 1 # Initial niveau
var enemies_by_niveau = [] # Array to hold enemies based on their niveau

# Called when the node enters the scene tree for the first time.
func _ready():
	start_wave()

# Start a new wave
func start_wave():
	current_wave += 1
	enemies_left_in_wave = wave_enemy_limit * current_wave
	update_niveau()
	spawn_enemies()

# Update the niveau every two waves
func update_niveau():
	if current_wave % 2 == 0:
		current_niveau += 1
		# Reset current_niveau to 1 if it exceeds 4 (maximum niveau)
		if current_niveau > 4:
			current_niveau = 4
	
	# Update enemies list based on the current niveau
	match current_niveau:
		1: enemies_by_niveau = NIVEAU_ONE
		2: enemies_by_niveau = NIVEAU_TWO
		3: enemies_by_niveau = NIVEAU_THREE
		4: enemies_by_niveau = NIVEAU_FOUR

# Spawn enemies for the current wave
func spawn_enemies():
	for i in range(enemies_left_in_wave):
		var enemy_type = enemies_by_niveau[randi() % enemies_by_niveau.size()]
		var enemy = enemy_type.instantiate()
		
		# Set collision layer and mask
		enemy.collision_layer = 0b10 # Layer 2
		enemy.collision_mask = 0b100 # Mask 3
		
		# Set the enemy position
		enemy.global_position.y = player.global_position.y
		
		# Defining the x-ranges
		var minRight = player.global_position.x + 600
		var minLeft = player.global_position.x - 600
		var maxRight = 2895
		var maxLeft = -870
		
		# Ensure minLeft and minRight do not exceed maxLeft and maxRight
		if minLeft < maxLeft:
			minLeft = maxLeft
		if minRight > maxRight:
			minRight = maxRight
		
		# Randomize x-position within specified ranges
		if randi() % 2 == 0:
			enemy.global_position.x = randf_range(minLeft, maxLeft)
		else:
			enemy.global_position.x = randf_range(minRight, maxRight)
		
		# Add the enemy to the scene
		enemys.add_child.call_deferred(enemy)

# Check if all enemies in the wave are defeated
func check_wave_completed():
	if enemies_left_in_wave <= 0:
		start_wave()

# Called when an enemy is defeated
func _on_enemys_child_exiting_tree(_node):
	enemies_left_in_wave -= 1
	check_wave_completed()
