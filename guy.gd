extends Node2D

var vx : float = 0.0
var vy : float = 0.0
@onready var spr = $spr
var firedbuf : int = 0

@onready var bulits = $"../bulits"

func _physics_process(_delta: float) -> void:
	var dpad = Vector2i(
		1 if Input.is_action_pressed("ui_right") else 0-
		1 if Input.is_action_pressed("ui_left") else 0,
		1 if Input.is_action_pressed("ui_down") else 0-
		1 if Input.is_action_pressed("ui_up") else 0
	)
	if dpad.x: vx = move_toward(vx,1.0*dpad.x,0.1)
	else: vx *= 0.95
	if dpad.y: vy = move_toward(vy,1.0*dpad.y,0.1)
	else: vy *= 0.95
	
	position.x += vx
	position.y += vy

	if firedbuf > 0:
		firedbuf -= 1
		if firedbuf > 10: spr.frame = 58
		else: spr.frame = 57
	elif Input.is_action_pressed("ui_accept"):
		spr.frame = 58
		firedbuf = 16
		for x in [-2,2]:
			bulits.fire_bulit(position + Vector2(x,-2))
	if vx < 0 and position.x < 3: vx = reflect(vx)
	if vx > 0 and position.x > 128-3: vx = reflect(vx)
	if vy > 0 and position.y > 128-3: vy = reflect(vy)

func reflect(v:float)->float:
	v=-v
	if abs(v)<0.5: v=sign(v)*0.5
	return v
