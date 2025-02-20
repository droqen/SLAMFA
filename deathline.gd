extends Node2D

var aniindex : int = 0
var subindex : int = 0

func cutscene_move_to_y(y:int) -> void:
	get_tree().paused = true
	while position.y < y:
		advance_aniindex(true)
		await get_tree().create_timer(0.02).timeout
	while position.y > y:
		retreat_aniindex(true)
		await get_tree().create_timer(0.02).timeout
	get_tree().paused = false
	
func retreat_aniindex(force_step : bool = false) -> void:
	aniindex -= 1
	if aniindex < 0: aniindex = 3
	for x in range(16):
		$TileMapLayer.set_cell(Vector2i(x,0), 0, Vector2i(3+aniindex,0))
	if aniindex == 3 or force_step:
		position.y -= 1
		
func advance_aniindex(force_step : bool = false) -> void:
	aniindex = (aniindex + 1) % 4
	for x in range(16):
		$TileMapLayer.set_cell(Vector2i(x,0), 0, Vector2i(3+aniindex,0))
	if aniindex == 0 or force_step:
		position.y += 1

func _physics_process(_delta: float) -> void:
	subindex += 1
	if subindex > 10:
		subindex = 0
		advance_aniindex()

func flash() -> void:
	visible = false
	await get_tree().create_timer(0.05).timeout
	show()

func flash_white() -> void:
	for x in range(16):
		$TileMapLayer.set_cell(Vector2i(x,0), 0, Vector2i(7,0))
	subindex = 5
