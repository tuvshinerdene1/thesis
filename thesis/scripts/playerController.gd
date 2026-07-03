extends Node2D

enum Heading {NORTH, EAST, SOUTH, WEST}

# mapping directions to grid movement vectors
const DIR_VECTORS = {
	Heading.NORTH: Vector2i(0, -1),
	Heading.EAST: Vector2i(1,0),
	Heading.SOUTH: Vector2i(0,1),
	Heading.WEST: Vector2i(-1,0)
}

const DIR_ROTATIONS = {
	Heading.NORTH: -90.0,
	Heading.EAST: 0.0,
	Heading.SOUTH: 90.0,
	Heading.WEST: 180.0
}

# player's current simulation state
var grid_pos : Vector2i = Vector2i(2,2) # starting position
var current_heading: Heading = Heading.EAST

@export var tilemap_layer: TileMapLayer
@export var move_speed: float = 0.25

func _ready() -> void:
	if tilemap_layer:
		global_position = tilemap_layer.map_to_local(grid_pos)
		rotation_degrees = DIR_ROTATIONS[current_heading]



# players API SENSORS
func tree_front() -> bool:
	var front_cell = grid_pos + DIR_VECTORS[current_heading]
	return GridManager.get_cell_type(front_cell) == GridManager.CellType.TREE

func on_leaf() -> bool:
	return GridManager.get_cell_type(grid_pos) == GridManager.CellType.LEAF
	
	
# players API ACTIONS
func move_forward() -> void:
	if not tree_front():
		grid_pos += DIR_VECTORS[current_heading]
		print("kara moved to: ", grid_pos)
		var tween = animate_movement()
		if tween:
			await tween.finished
	else:
		print("boom, kara hit a tree or world boundary")
		await get_tree().create_timer(move_speed).timeout
		
func turn_left() -> void:
	# enum order: NORTH(0), EAST(1), SOUTH(2), WEST(3)
	# turning left subtracting 1, wrapping around with modulo 4
	current_heading = posmod(current_heading - 1, 4) as Heading
	print("kara turned left. now facing: ", Heading.keys()[current_heading])
	var tween = animate_rotation()
	await tween.finished
	
func turn_right() -> void:
	current_heading = posmod(current_heading+ 1, 4) as Heading
	print("kara turned right. now facing: ", Heading.keys()[current_heading])
	var tween = animate_rotation()
	await tween.finished

# --- visual tween animations ---
func animate_movement() -> Tween:
	if not tilemap_layer: 
		return
	var target_pixel_pos = tilemap_layer.map_to_local(grid_pos)
	var tween = create_tween()
	
	tween.tween_property(self, "global_position", target_pixel_pos, move_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
	
func animate_rotation() -> Tween:
	var target_rotation = DIR_ROTATIONS[current_heading]
	var tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees", target_rotation, move_speed * 0.6)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween
	
