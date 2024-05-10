extends Control

# Player object
@onready var game_manager


func _on_continue_pressed():
	# Resume the game
	get_tree().paused = false
	queue_free()


func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed():
	game_manager.reset()
	get_tree().paused = false
	queue_free()
