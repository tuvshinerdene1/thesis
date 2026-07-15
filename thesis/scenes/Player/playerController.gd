extends CharacterBody2D

enum Heading {NORTH, EAST, SOUTH, WEST}

const DIR_VECTORS = {
	Heading.NORTH : Vector2i(0,-1),
	Heading.EAST : Vector2i(1,0),
	Heading.SOUTH : Vector2i(0,1),
	Heading.WEST : Vector2i(-1,0)
}

const DIR_ROTATIONS = {
	Heading.NORTH: -90.0,
	Heading.EAST: 0.0,
	Heading.SOUTH: 90.0,
	Heading.WEST: 180.0
}

# player's current simulation state
var grid_pos : Vector2i = Vector2i(2,2) # starting postion
var current_heading : Heading = Heading.EAST

@export var tilemap_layer: TileMapLayer
@export var move_speed: float = 0.25

# STATE MACHINE VARIABLES
var states: Dictionary = {}
var current_state: PlayerStateMachine.State = null
var is_running: bool = false



func _ready() -> void:
	# Read where the player node is placed visually
	grid_pos = GridManager.pixel_to_grid(global_position)
	# Snap the player perfectly to the center of that tile
	global_position = GridManager.grid_to_pixel(grid_pos)
	rotation_degrees = DIR_ROTATIONS[current_heading]
		
# --- PLAYER'S API SENSORS ---
func tree_front() -> bool:
	var front_cell = grid_pos + DIR_VECTORS[current_heading]
	return GridManager.get_cell_type(front_cell) == GridManager.CellType.TREE

func tree_right() -> bool:
	var right_cell = grid_pos + DIR_VECTORS[_get_relative_heading(1)]
	return GridManager.get_cell_type(right_cell) == GridManager.CellType.TREE
	
func tree_left() -> bool:
	var left_cell = grid_pos + DIR_VECTORS[_get_relative_heading(-1)]
	return GridManager.get_cell_type(left_cell) == GridManager.CellType.TREE
		
func on_leaf() -> bool:
	return GridManager.get_cell_type(grid_pos) == GridManager.CellType.LEAF

# --- PLAYER'S API ACTIONS ---
func move_forward() -> void:
	if not tree_front():
		grid_pos += DIR_VECTORS[current_heading]
		print("Player moved to: ", grid_pos)
		var tween = animate_movement()
		if tween:
			await tween.finished
	else:
		print("boom, player hit a tree or world boundary")
		await get_tree().create_timer(move_speed).timeout

func turn_left() -> void:
	# enum order: NORTH(0), EAST(1), SOUTH(2), WEST(3)
	# turning left subtracting 1, wrapping around with modulo 4
	current_heading = posmod(current_heading - 1, 4) as Heading
	print("Player turned left. now facing; ", Heading.keys()[current_heading])
	var tween  = animate_rotation()
	await tween.finished

func turn_right() -> void:
	current_heading = posmod(current_heading + 1, 4) as Heading
	print("Player turned right. now facing: ", Heading.keys()[current_heading])
	var tween = animate_rotation()
	await tween.finished

# --- VISUAL TWEEN ANIMATIONS ---
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

# --- HELPER FUNCTIONS ---
func _get_relative_heading(offset: int) -> Heading:
	return posmod(current_heading + offset, 4) as Heading

# --- STATE MACHINE FUNCTIONS ---
func add_state(state:PlayerStateMachine.State) -> void:
	states[state.name] = state

# set the entry point of the program and start it 
func start_program(initial_state_name: String) -> void:
	if not states.has(initial_state_name):
		print('Error: initial state has not been found')
		return
	
	current_state = states[initial_state_name]
	is_running = true
	run_simulation_loop()

func run_simulation_loop() -> void:
	while is_running and current_state != null:
		print("Current state: ", current_state.name)
		
		var triggered_transition: PlayerStateMachine.Transition = null
		
		for transition in current_state.transitions:
			if evaluate_transition(transition):
				triggered_transition = transition
				break
		
		if triggered_transition == null:
			print("simulation stopped: no valid transition found out of state: ", current_state.name)
			is_running = false
			break
			
		# Resolve the Enum actions to method names safely
		for action_enum in triggered_transition.actions:
			var action_name = FSMTypes.get_action_name(action_enum)
			if has_method(action_name):
				await call(action_name)
		
		if triggered_transition.next_state_name in ["Stop", ""]:
			print("Reached stop state. compiled successfully")
			is_running = false
		else:
			current_state = states[triggered_transition.next_state_name]
		
		await get_tree().create_timer(0.1).timeout

func evaluate_transition(transition: PlayerStateMachine.Transition) -> bool:
	for sensor_enum in transition.conditions.keys():
		var expected_value = transition.conditions[sensor_enum]
		var sensor_name = FSMTypes.get_sensor_name(sensor_enum)
		
		if has_method(sensor_name):
			var actual_value = call(sensor_name)
			if actual_value != expected_value:
				return false
		else:
			# If a sensor method is missing, fail safe
			return false
	return true
