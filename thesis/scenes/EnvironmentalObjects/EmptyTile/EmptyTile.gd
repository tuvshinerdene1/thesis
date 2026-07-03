extends Node2D

func _ready() -> void:
	var grid_pos = GridManager.pixel_to_grid(global_position)
	GridManager.set_cell(grid_pos, GridManager.CellType.EMPTY)
	global_position = GridManager.grid_to_pixel(grid_pos)
