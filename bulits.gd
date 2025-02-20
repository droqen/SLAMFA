extends Node2D

signal screen_cleared

@onready var maze = $"../TileMapLayer"
@onready var explosion = $"../explosion"
const BULITPREFAB = preload("res://bulit.tscn")

var all_cells : Array[Vector2i]

func _ready() -> void:
	explosion.hide()
	all_cells = maze.get_used_cells()

func try_hit_cell(cell : Vector2i) -> bool:
	var tid = read_tid(cell)
	match tid:
		0: return false
		10: pass # flash cell, destroy bullet
		12,13,14:
			%soundboss.play("plap").pitch_scale = 0.7 - 0.05 * (15-tid)
			flash_set_tid(cell, tid+1)
		2,15:
			%soundboss.play("plap").pitch_scale = randf_range(0.7,1.3)
			flash_set_tid(cell, 0)
		1:
			%soundboss.play("longboom")
			detonate_start(cell)
		25:
			flash_set_tid(cell, 1)
			%soundboss.play("harp")
		11,21:
			flash_set_tid(cell, 11)
			%soundboss.play("hit")
		22:
			%soundboss.play("pushleft").pitch_scale = 0.7 + 0.05 * cell.x
			%soundboss.play("pushright").pitch_scale = 0.7 + 0.05 * cell.x
			flash_set_tid(cell, 0)
			if cell.x > 0: flash_set_tid(cell+Vector2i.LEFT, 23)
			if cell.x < 15: flash_set_tid(cell+Vector2i.RIGHT, 24)
		23:
			%soundboss.play("pushleft").pitch_scale = 0.7 + 0.05 * cell.x
			flash_set_tid(cell, 0)
			if cell.x > 0: flash_set_tid(cell+Vector2i.LEFT, 23)
			else: %soundboss.play("plap").pitch_scale = randf_range(0.7,1.3)
		24:
			%soundboss.play("pushright").pitch_scale = 0.7 + 0.05 * cell.x
			flash_set_tid(cell, 0)
			if cell.x < 15: flash_set_tid(cell+Vector2i.RIGHT, 24)
			else: %soundboss.play("plap").pitch_scale = randf_range(0.7,1.3)
	return true

func _request_extrahurty() -> void:
	all_cells.shuffle()
	for cell in all_cells:
		if try_hit_cell(cell): break

func _physics_process(_delta: float) -> void:
	var all_clear : bool = true
	for cell in all_cells:if read_tid(cell)!=0:all_clear=false
	if all_clear: screen_cleared.emit()
	
	for bulit in get_children():
		var cell = maze.local_to_map(bulit.position)
		if cell.y < 0: bulit.queue_free()
		else:
			if try_hit_cell(cell): bulit.queue_free()

func fire_bulit(position:Vector2)->void:
	var bulit = BULITPREFAB.instantiate()
	bulit.position = position
	add_child(bulit)
	bulit.owner = owner if owner else self

func removeallbullets() -> void:
	for child in get_children():child.queue_free()

func read_tid(cell:Vector2i)->int:
	var coords = maze.get_cell_atlas_coords(cell)
	if coords.x < 0 or coords.y < 0: return 0
	return coords.y * 10 + coords.x

func flash_set_tid(cell:Vector2i,tid:int)->void:
	maze.set_cell(cell,0,Vector2i(0,1))
	await get_tree().create_timer(0.1).timeout
	maze.set_cell(cell,0,Vector2i(tid%10,tid/10))

func detonate_start(cell:Vector2i)->void:
	maze.set_cell(cell,0,Vector2i(0,2))
	get_tree().paused = true
	explosion.position = maze.map_to_local(cell)
	explosion.get_node("ColorRect").color = Color("#111d35") # black
	explosion.show()
	await get_tree().create_timer(0.1).timeout
	for _i in range(5):
		explosion.get_node("ColorRect").color = Color("#f3ef7d") # white
		await get_tree().create_timer(0.05).timeout
		explosion.get_node("ColorRect").color = Color("#ff6e59") # red
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.1).timeout
	detonate_chain_reaction_cell(cell)
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = false
	explosion.hide()

func detonate_chain_reaction_cell(cell:Vector2i) -> void:
	%soundboss.play("boomafterblip").pitch_scale = randf_range(0.5,2.0)
	maze.set_cell(cell,0,Vector2i(0,2))
	await get_tree().create_timer(0.05).timeout
	for dx in [-1,0,1]:
		for dy in [-1,0,1]:
			if (dx==0)!=(dy==0):
				var off = Vector2i(dx,dy)
				match read_tid(cell+off):
					0: pass
					10,20: guarantee_explode(cell)
					_:
						prints(cell,off,read_tid(cell+off))
						detonate_chain_reaction_cell(cell+off)
	await get_tree().create_timer(0.05).timeout
	maze.set_cell(cell,0,Vector2i(0,1))
	await get_tree().create_timer(0.05).timeout
	maze.set_cell(cell,0,Vector2i(0,0))

func guarantee_explode(cell:Vector2i) -> void:
	for _i in range(5):
		await get_tree().create_timer(0.05).timeout
		match read_tid(cell):
			0: return # done
			10,20: continue
			_: detonate_chain_reaction_cell(cell) # boom!
