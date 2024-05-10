extends Control
@onready var game_manager

@onready var label_2 = $MarginContainer/VBoxContainer/VBoxContainer/Label2

var score

func _process(_delta):
	label_2.text = "Your Score: " + str(score)

func _on_restart_pressed():
	game_manager.reset()
	get_tree().paused = false
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
