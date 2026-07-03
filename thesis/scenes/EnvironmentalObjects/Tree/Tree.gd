extends Node2D

func _ready() -> void:
	# calculate which grid slot this tree was placed on in the editor
	var grid_pos = GridManager.pixel_to_grid(global_position)
	
	# register this obstacle into the database
	GridManager.set_cell(grid_pos, GridManager.CellType.TREE)
	
	# snap its visual sprite perfectly to the center of that tile
	global_position = GridManager.grid_to_pixel(grid_pos)
