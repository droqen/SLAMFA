extends Node2D

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://matchthreer.tscn")
