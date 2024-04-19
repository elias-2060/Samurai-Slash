extends Control

func _on_continue_pressed():
	# Resume the game
	get_tree().paused = false
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
