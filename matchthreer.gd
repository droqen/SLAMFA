extends Node2D

@onready var maze : TileMapLayer = $TileMapLayer

@export var levels : Array[PackedScene]
var levelindex : int = 0

func _ready() -> void:
	for cell in maze.get_used_cells():
		maze.set_cell(cell,0,Vector2i(0,0))
	$rivalguy.extrahurty.connect($bulits._request_extrahurty)
	$bulits.screen_cleared.connect(empty_repopulate_screen)
	#await $deathline.cutscene_move_to_y(72)
	empty_repopulate_screen()
	$deadplayer.emitting = false
	$deadplayer.one_shot = true

var crushed : int = 0

func _physics_process(_delta: float) -> void:
	if $guy.position.y - 3 < $deathline.position.y:
		$deathline.flash_white()
		$guy.vy = 1
		if $guy.position.y > 120:
			$guy.vy = remap($guy.position.y,120,125,1,0)
			crushed += 4
	if crushed > 0:
		crushed -= 1
	if crushed > 10 and $guy.visible:
		$guy.hide(); $guy.process_mode = Node.PROCESS_MODE_DISABLED
		$bulits.removeallbullets()
		$deadplayer.position = $guy.position
		$deadplayer.emitting = true
		await $deadplayer.finished
		if is_inside_tree():
			get_tree().reload_current_scene()

var populating : bool = false

func empty_repopulate_screen() -> void:
	if populating: return
	populating = true
	get_tree().paused = true
	for child in $bulits.get_children():
		child.queue_free()
	var deathline_celly : int = maze.local_to_map($deathline.position).y
	for y in range(deathline_celly,0-1,-1):
		for x in range(16):
			maze.set_cell(Vector2i(x,y),0,Vector2i(0,0))
		await $deathline.cutscene_move_to_y(y*8)
	$rivalguy.damage = 0
	await populate_packedscene(levels[levelindex])
	levelindex = (levelindex + 1) % len(levels)
	populating = false
	# load new level

func populate_packedscene(levelscene : PackedScene) -> void:
	var levelmaze : TileMapLayer = levelscene.instantiate()
	var lowest_celly : int = 0
	for cell in levelmaze.get_used_cells():
		if levelmaze.get_cell_atlas_coords(cell) != Vector2i(0,0):
			lowest_celly = maxi(lowest_celly,cell.y)
	for y in range(lowest_celly+1):
		await $deathline.cutscene_move_to_y((y+1)*8)
		for x in range(16):
			var coords = levelmaze.get_cell_atlas_coords(Vector2i(x,y))
			if coords != Vector2i(0,0):
				maze.set_cell(Vector2i(x,y), 0, coords)
