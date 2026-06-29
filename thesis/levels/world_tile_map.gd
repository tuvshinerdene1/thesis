extends TileMapLayer

const TILE_MAPPING = {
	GridManager.CellType.EMPTY: Vector2i(0,9),
	GridManager.CellType.TREE: Vector2i(6,5),
	GridManager.CellType.LEAF: Vector2i(1,4),
	GridManager.CellType.MUSHROOM: Vector2i(7,6)
}


func _ready() -> void:
	render_entire_grid()

func render_entire_grid() -> void:
	clear()
	for coords in GridManager.grid_data.keys():
		var type = GridManager.grid_data[coords]
		var atlas_coords = TILE_MAPPING[type]
		set_cell(coords,2, atlas_coords)
		
