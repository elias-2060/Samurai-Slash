extends Node

# Player object
@onready var player = $"../Player"
# Enemy's cointainer object
@onready var enemy_s_container = $"../Enemy'sContainer"
# Power ups container object
@onready var power_ups_container = $"../PowerUpsContainer"
# Self object
@onready var game_manager_object = $"."
# WaveInfo object
@onready var wave_info = $"../WaveInfo"
# WaveInfoText object
@onready var label = $"../WaveInfo/MarginContainer/HBoxContainer/VBoxContainer/Label"
# WaveInfoText2 object
@onready var label2 = $"../WaveInfo/MarginContainer/HBoxContainer/VBoxContainer/Label2"
# WaveInfoTimer object
@onready var wave_info_timer = $"../WaveInfoTimer"
@onready var wave_info_t_imer_2 = $"../WaveInfoTImer2"
@onready var score_info = $"../Player/ScoreInfo/HBoxContainer/Label"
@onready var background_sound = $"../BackgroundSound"
@onready var wave_sound = $"../WaveSound"

const MENU_SCENE = preload("res://scenes/game/menu.tscn")
const DEAD_MENU_SCENE = preload("res://scenes/game/dead_menu.tscn")
const WAVE_INFO_SCENE = preload("res://scenes/game/wave_info.tscn")

const POWER_UPS = [
	preload("res://scenes/boosts/damage_boost.tscn"),
	preload("res://scenes/boosts/max_health.tscn"),
	preload("res://scenes/boosts/speed_boost.tscn"),
	preload("res://scenes/boosts/invincible_boost.tscn")
]

# Enemies
const NIVEAU_ONE = [
	preload("res://scenes/enemies/wolf_enemy.tscn"),
	preload("res://scenes/enemies/skeleton_warrior.tscn"),
	preload("res://scenes/enemies/skeleton_archer.tscn"),
]

const NIVEAU_TWO = [
	preload("res://scenes/enemies/wolf_enemy_white.tscn"),
	preload("res://scenes/enemies/skeleton_spear.tscn"),
	preload("res://scenes/enemies/knight_white.tscn"),
	preload("res://scenes/enemies/fire_wizard.tscn"),
	preload("res://scenes/enemies/firespirit.tscn"),
]

const NIVEAU_THREE = [
	preload("res://scenes/enemies/wolf_enemy_red.tscn"),
	preload("res://scenes/enemies/knight_red.tscn"),
	preload("res://scenes/enemies/lightning_mage.tscn"),
]

const NIVEAU_FOUR = [
	preload("res://scenes/enemies/knight_pink.tscn"),
	preload("res://scenes/enemies/dark_magican.tscn"),
	preload("res://scenes/enemies/kitsune.tscn"),
]

# Variables
var current_wave = 0
var enemies_left_in_wave = 0
var wave_enemy_limit = 0 # Initial limit for enemies in each wave
var current_niveau = 1 # Initial niveau
var enemies_by_niveau = [] # Array to hold enemies based on their niveau
var power_up_spawn_timer # Timer for spawning power-ups
var time_since_last_power_up = 0.0 # Variable to track time elapsed for power-up spawning
const POWER_UP_TIMER = 15.0 # Variable to define the time before the power up spawns
const playerPos = Vector2(1160,509.7198)
var restart = false
var score
var highscore = 0
const FADE_OUT_DURATION = 1.0  # Define the fade-out duration in seconds
var startFade = false
var startFade2 = false
var maxEnemy = 5
var spawnEnemies = false
var enemyCount = 0
var menu_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	restart = false
	player.visible = true
	enemy_s_container.visible = true
	power_ups_container.visible = true
	score = 0
	player.global_position = playerPos
	restartAudio()
	start_wave()
 
func reset():
	restart = true
	spawnEnemies = false
	current_wave = 0
	enemies_left_in_wave = 0
	wave_enemy_limit = 0
	current_niveau = 1
	time_since_last_power_up = 0.0
	wave_info.visible = false
	label.visible = false
	label2.visible = false
	startFade = false
	startFade2 = false
	while enemy_s_container.get_child_count() > 0:
		var child = enemy_s_container.get_child(0)  # Get the first child
		enemy_s_container.remove_child(child)       # Remove the child from the parent node
		child.queue_free()
		
	while power_ups_container.get_child_count() > 0:
		var child = power_ups_container.get_child(0)  # Get the first child
		power_ups_container.remove_child(child)       # Remove the child from the parent node
		child.queue_free()
	player.reset()
	_ready()
	
func restartAudio():
	background_sound.stop()   # Stop the audio player
	background_sound.play()   # Play the audio player from the beginning

# Start a new wave
func start_wave():
	current_wave += 1
	wave_enemy_limit += current_niveau
	enemies_left_in_wave = wave_enemy_limit
	enemyCount = enemies_left_in_wave
	update_niveau()
	update_wave_info()  # Update the wave information before spawning enemies
	# Start the wave info timer
	wave_sound.play()
	wave_info_timer.start()
	
# Function to update the wave information text
func update_wave_info():
	wave_info.visible = true
	label.modulate.a = 1.0  # Reset the alpha value when updating text
	label2.modulate.a = 1.0  # Reset the alpha value when updating text
	# Show the WaveInfo object and update its text label
	label.visible = true
	label.text = "Wave " + str(current_wave)
	

# Update the niveau every two waves
func update_niveau():
	if current_wave % 2 == 0:
		current_niveau += 1
		label2.text = "Stronger monsters are coming"
		# Reset current_niveau to 1 if it exceeds 4 (maximum niveau)
		if current_niveau > 4:
			current_niveau = 4
			label2.text = "Monsters are coming"
	else:
		label2.text = "Monsters are coming"
	
	# Update enemies list based on the current niveau
	match current_niveau:
		1: enemies_by_niveau = [NIVEAU_ONE]
		2: enemies_by_niveau = [NIVEAU_ONE, NIVEAU_TWO]
		3: enemies_by_niveau = [NIVEAU_ONE, NIVEAU_TWO, NIVEAU_THREE]
		4: enemies_by_niveau = [NIVEAU_ONE, NIVEAU_TWO, NIVEAU_THREE, NIVEAU_FOUR]

# Spawn enemies for the current wave
func spawn_enemy():
	# Selecting the niveau based on weighted probability
	var enemy_type = choose_enemy_type()
	var enemy = enemy_type.instantiate()
		
	# Set collision layer and mask
	enemy.collision_layer = 0b10 # Layer 2
	enemy.collision_mask = 0b100 # Mask 3
		
	# Set the enemy position
	enemy.global_position.y = playerPos.y
		
	# Defining the x-ranges
	var minRight = player.global_position.x + 600
	var minLeft = player.global_position.x - 600
	var maxRight = 2850
	var maxLeft = -850
		
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
	enemyCount -= 1

# Helper function to choose enemy type with higher probability for the current niveau
func choose_enemy_type() -> PackedScene:
	var current_niveau_index = current_niveau - 1
	if randf() < 0.7:  # 70% chance to spawn from current niveau
		return enemies_by_niveau[current_niveau_index][randi() % enemies_by_niveau[current_niveau_index].size()]
	else:
		# Randomly select from all niveaus
		var all_enemies = []
		for niveau in enemies_by_niveau:
			all_enemies += niveau
		return all_enemies[randi() % all_enemies.size()]

# Spawn a power-up at a random position
func spawn_power_up():
	var power_up_type = POWER_UPS[randi() % POWER_UPS.size()]
	var power_up = power_up_type.instantiate()
	
	# Set the power-up position randomly within the visible area
	var minHeight = 459
	var maxHeight = 310
	var minWidth = -870
	var maxWidth = 2885
	power_up.global_position.x = randf_range(minWidth, maxWidth)
	power_up.global_position.y = randf_range(minHeight, maxHeight)
	
	# Add the power-up to the scene
	power_ups_container.add_child(power_up)

# Check if all enemies in the wave are defeated
func check_wave_completed():
	if enemies_left_in_wave <= 0 and restart == false:
		spawnEnemies = false
		start_wave()

# Called when an enemy is defeated
func _on_enemys_child_exiting_tree(node):
	score += node.score
	enemies_left_in_wave -= 1
	check_wave_completed()

func _physics_process(delta):
	if player.isDead:
		end_game()
	score_info.text = "Score: " + str(score)
	if startFade:
		var fade_alpha = clamp(label.modulate.a - (delta / FADE_OUT_DURATION), 0.0, 1.0)
		label.modulate.a = fade_alpha
		if fade_alpha <= 0.0:
			label.visible = false
			startFade = false
			label2.visible = true
			wave_info_t_imer_2.start()
	elif startFade2:
		var fade_alpha = clamp(label2.modulate.a - (delta / FADE_OUT_DURATION), 0.0, 1.0)
		label2.modulate.a = fade_alpha
		if fade_alpha <= 0.0:
			label2.visible = false
			startFade2 = false
			wave_info.visible = false
			spawnEnemies = true
	# Increment time_since_last_power_up by the time passed since the last frame
	time_since_last_power_up += delta
	# Check if 20 seconds have passed and there are no power-ups already in the container
	if time_since_last_power_up >= POWER_UP_TIMER and power_ups_container.get_child_count() == 0:
		# Spawn a power-up
		spawn_power_up()
		
	
	if Input.is_action_just_pressed("escape"):
		pause_game()
	if spawnEnemies and enemy_s_container.get_child_count() < maxEnemy and enemyCount > 0:
		spawn_enemy()
		
func end_game():
	get_tree().paused = true
	enemy_s_container.visible = false
	power_ups_container.visible = false
	player.visible = false
	
	# Load and instance the menu scene
	menu_instance = DEAD_MENU_SCENE.instantiate()
	
	menu_instance.global_position.x = player.global_position.x - 35
	menu_instance.global_position.y = player.global_position.y - 300
	
	
	menu_instance.game_manager = game_manager_object
	menu_instance.score = score
	
	# Add the menu as a child of the root viewport
	get_tree().get_root().add_child(menu_instance)


func pause_game():
	# Pause any game processes (e.g., physics, animations)
	get_tree().paused = true
	
	# Load and instance the menu scene
	menu_instance = MENU_SCENE.instantiate()
	
	menu_instance.global_position.x = player.global_position.x - 35
	menu_instance.global_position.y = player.global_position.y - 300
	
	
	menu_instance.game_manager = game_manager_object
	# Add the menu as a child of the root viewport
	get_tree().get_root().add_child(menu_instance)
		


func _on_power_ups_container_child_exiting_tree(_node):
	# Reset the time_since_last_power_up
	time_since_last_power_up = 0.0


func _on_wave_info_timer_timeout():
	wave_info_timer.stop()
	startFade = true


func _on_wave_info_t_imer_2_timeout():
	wave_info_t_imer_2.stop()
	startFade2 = true
