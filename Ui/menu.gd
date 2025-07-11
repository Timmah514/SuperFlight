extends Node2D

@export var type = ""

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Areas/test_area.tscn")
