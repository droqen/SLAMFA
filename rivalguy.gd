extends Node2D

signal extrahurty

var dir : int = 1
var vx : float = 0
var phase : float = 0

var damage : int = 0

var ani : int = 0
var subani : int = 0
func _ready() -> void:
	$bulletcatcher.area_entered.connect(func(area):
		area.get_parent().queue_free()
		hurt()
	)
func _physics_process(_delta: float) -> void:
	if damage >= 10:
		if !get_tree().paused: hurt()
		else: subani = 0
		damage = 10
	else:
		phase += 0.01
		vx = lerp(vx,dir*0.8,0.01)
		if position.x > 100: dir = -1
		if position.x < 28: dir = 1
		if randf() < 0.001: dir = -dir
		position.x += vx
		position.y = lerp(position.y, 7 + sin(phase) * 5, 0.1)
	subani += 1
	if subani > 12:
		subani = 0
		ani = (ani+1) % 4
		$spr.flip_h = vx < 0
		$spr.frame = 50 + ani
func hurt() -> void:
	if $spr.frame < 60:
		%soundboss.play("ouchrival").pitch_scale = randf_range(0.9,1.1) + (10-damage) * 0.1
		$spr.frame = 61
		await get_tree().physics_frame
		await get_tree().physics_frame
		$spr.frame = 60
		subani = 0
		damage += 1
		if damage > 10:
			extrahurty.emit()
			subani = 7
