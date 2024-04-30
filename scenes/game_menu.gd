extends Control

const GAME_SCENE = preload("res://scenes/samurai_slash.tscn")
var highScore


func _on_start_pressed():
	get_tree().change_scene_to_packed(GAME_SCENE)
	


func _on_quit_pressed():
	get_tree().quit()
