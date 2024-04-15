extends Node

# Player object
@onready var player = $"../Player"
# Enemy's cointainer object
@onready var enemy_s_container = $"../Enemy'sContainer"
# Power ups container object
@onready var power_ups_container = $"../PowerUpsContainer"

const POWER_UPS = [
	preload("res://scenes/damage_boost.tscn")
]

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
var power_up_spawn_timer # Timer for spawning power-ups
var time_since_last_power_up = 0.0 # Variable to track time elapsed for power-up spawning
const POWER_UP_TIMER = 20.0 # Variable to define the time before the power up spawns

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
		enemy_s_container.add_child.call_deferred(enemy)

# Spawn a power-up at a random position
func spawn_power_up():
	var power_up_type = POWER_UPS[randi() % POWER_UPS.size()]
	var power_up = power_up_type.instantiate()
	
	# Set the power-up position randomly within the visible area
	var minHeight = 459
	var maxHeight = 310
	var minWidth = -870
	var maxWidth = 2895
	power_up.global_position.x = randf_range(minWidth, maxWidth)
	power_up.global_position.y = randf_range(minHeight, maxHeight)
	
	# Add the power-up to the scene
	power_ups_container.add_child(power_up)

# Check if all enemies in the wave are defeated
func check_wave_completed():
	if enemies_left_in_wave <= 0:
		start_wave()

# Called when an enemy is defeated
func _on_enemys_child_exiting_tree(_node):
	enemies_left_in_wave -= 1
	check_wave_completed()

func _physics_process(delta):
	# Increment time_since_last_power_up by the time passed since the last frame
	time_since_last_power_up += delta
	# Check if 20 seconds have passed and there are no power-ups already in the container
	if time_since_last_power_up >= POWER_UP_TIMER and power_ups_container.get_child_count() == 0:
		# Spawn a power-up
		spawn_power_up()


func _on_power_ups_container_child_exiting_tree(_node):
	# Reset the time_since_last_power_up
	time_since_last_power_up = 0.0
