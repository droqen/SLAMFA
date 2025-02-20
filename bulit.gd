extends Node2D

func _physics_process(_delta: float) -> void:
	position.y -= 2
	if position.y < 0: queue_free()
