extends Node

enum CellType {EMPTY, TREE, LEAF, MUSHROOM}

#dictionary stores grid data using Vector2i keys; {Vector2i(x,y):Celltype
var grid_data: Dictionary = {}

const GRID_WIDTH = 10
const GRID_HEIGHT = 10


func _ready() -> void:
	clear_grid()
	set_cell(Vector2i(3,2), CellType.TREE)
	set_cell(Vector2i(4,2), CellType.LEAF)

func clear_grid() -> void:
	grid_data.clear()
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			grid_data[Vector2i(x, y)] = CellType.EMPTY
			
func set_cell(coords:Vector2i, type: CellType) -> void:
	if is_within_bounds(coords):
		grid_data[coords] = type
		
func get_cell_type(coords: Vector2i) -> CellType:
	if not is_within_bounds(coords):
		return CellType.TREE
	return grid_data.get(coords, CellType.EMPTY)
	
func is_within_bounds(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x <GRID_WIDTH and coords.y >= 0 and coords.y <GRID_HEIGHT
	
