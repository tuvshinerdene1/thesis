extends Camera2D

@export var tilemap_layer: TileMapLayer
@export var padding_pixels: float = 64.0

func _ready() -> void:
	if not tilemap_layer:
		tilemap_layer = get_node_or_null("../WorldTileMap")
	
	if tilemap_layer:
		call_deferred("center_camera_on_grid")

func center_camera_on_grid() -> void:
	# get the size of the grid in pixels
	var map_size_tiles = Vector2(GridManager.GRID_WIDTH, GridManager.GRID_HEIGHT)
	var tile_size = tilemap_layer.tile_set.tile_size
	var grid_pixel_size = map_size_tiles  * Vector2(tile_size)
	
	# position the camera precisely at the center of the grid map
	global_position = grid_pixel_size / 2.0
	
	# calculate how much we need to zoom to fit the grid on screen
	var viewport_size = get_viewport_rect().size
	
	# add some breathing room padding
	var target_size_with_padding = grid_pixel_size + Vector2(padding_pixels * 2, padding_pixels * 2)
	
	# determine the zoom scale factor for both width and height
	var zoom_x = viewport_size.x / target_size_with_padding.x
	var zoom_y = viewport_size.y / target_size_with_padding.y
	
	# use the smaller zoom factor so nothing gets cut off
	var final_zoom = min(zoom_x, zoom_y)
	
	zoom = Vector2(final_zoom, final_zoom)
	
