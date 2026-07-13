# base_level.gd
class_name BaseLevel
extends Node2D

# export variables
@export var level_name: String = "Unnamed Level"
@export var next_level_scene: PackedScene

# internal references
@export var graph_canvas: GraphEdit = null
@export var player_runner: Node = null
@export var ui_controls: Control = null

# shared logic for every single level
func _ready() -> void:
	print("Loading: ", level_name)
	_wire_simulation_signals()
	setup_level()

func _wire_simulation_signals() -> void:
	# verifying all vital fields were dragged into the inspector
	if not graph_canvas or not player_runner or not ui_controls:
		push_error("BaseLevel error. Not all necessary export variables were assigned.")
		return
		
	# Wire up the UI Control Panel buttons to our simulation runners
	if ui_controls.has_signal("play_pressed") and not ui_controls.play_pressed.is_connected(_on_run_simulation):
		ui_controls.play_pressed.connect(_on_run_simulation)
		
	if ui_controls.has_signal("stop_pressed") and not ui_controls.stop_pressed.is_connected(_on_stop_simulation):
		ui_controls.stop_pressed.connect(_on_stop_simulation)
		
	print("Successfully wired Visual Editor, Simulation Toolbar, and Player Runner via explicit Inspector assignments!")

func setup_level() -> void:
	# level scripts can override this to set up level-specific features
	pass

func _on_run_simulation() -> void:
	if not graph_canvas or not player_runner:
		print("in _on_run_simulation, not all export variables were assigned.")
		return
	
	print("Compiling visual program ... ")
	var fsm_data: Dictionary = graph_canvas.compile_graph()
	
	if fsm_data.is_empty():
		print("Compilation failed: No states found on the canvas!")
		return
	
	# wipe old state machine state running from previous code attempts 
	player_runner.states.clear()
	
	# load the newly compiled visual states straight into the FSM executor backend 
	for state_name in fsm_data:
		player_runner.add_state(fsm_data[state_name])
	
	# begin running! we search for an explicit Start ndoe first 
	if fsm_data.has("Start"):
		player_runner.start_program("Start")
	else: 
		# fallback: if there is no state named Start, pick the first one as default 
		var fallback_state = fsm_data.keys()[0]
		print("Warning: no Start state found. defaulting execution entry to ", fallback_state)
		player_runner.start_program(fallback_state)

func _on_stop_simulation() -> void:
	if player_runner:
		print("simulation stopped by user request. ")
		player_runner.is_running = false
		
func complete_level() -> void:
	print(level_name, " Cleared!")
	# stop any running async loops inside the runner immediately before switching levels
	_on_stop_simulation()
	
	if next_level_scene:
		LevelManager.change_level(next_level_scene)
	else:
		print("game ended")
	
