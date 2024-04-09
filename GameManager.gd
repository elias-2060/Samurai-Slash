extends Node

# Player object
@onready var player = $"../Player"

@onready var enemys = $"../Enemy's"

# Enemies
const ENEMY_TYPES = [
	preload("res://scenes/wolf_enemy.tscn"),
	preload("res://scenes/wolf_enemy_white.tscn"),
	preload("res://scenes/wolf_enemy_red.tscn"),
	preload("res://scenes/skeleton_warrior.tscn"),
	preload("res://scenes/skeleton_spear.tscn"),
	preload("res://scenes/knight_white.tscn"),
	preload("res://scenes/knight_red.tscn"),
	preload("res://scenes/knight_pink.tscn"),
	preload("res://scenes/skeleton_archer.tscn"),
	preload("res://scenes/fire_wizard.tscn"),
	preload("res://scenes/lightning_mage.tscn"),
	preload("res://scenes/dark_magican.tscn"),
	preload("res://scenes/kitsune.tscn"),
	preload("res://scenes/firespirit.tscn")
]

var current_wave = 0
var enemies_left_in_wave = 0
var wave_enemy_limit = 1 # Initial limit for enemies in each wave

# Called when the node enters the scene tree for the first time.
func _ready():
	start_wave()

# Start a new wave
func start_wave():
	current_wave += 1
	enemies_left_in_wave = wave_enemy_limit * current_wave
	spawn_enemies()

# Spawn enemies for the current wave
func spawn_enemies():
	for i in range(enemies_left_in_wave):
		var enemy_type = ENEMY_TYPES[randi() % ENEMY_TYPES.size()]
		var enemy = enemy_type.instantiate()
		
		# Set collision layer and mask
		enemy.collision_layer = 0b10 # Layer 2
		enemy.collision_mask = 0b100 # Mask 3
		
		# Add the enemy tot the scene
		enemys.add_child.call_deferred(enemy)

# Check if all enemies in the wave are defeated
func check_wave_completed():
	if enemies_left_in_wave <= 0:
		start_wave()


# Called when an enemy is defeated
func _on_enemys_child_exiting_tree(_node):
	enemies_left_in_wave -= 1
	check_wave_completed()
