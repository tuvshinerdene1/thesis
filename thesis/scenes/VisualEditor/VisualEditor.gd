extends Control

@onready var graph_edit: GraphEdit = $GraphEdit
@export var runner: Node = null

var state_node_script = preload("res://scenes/VisualEditor/VisualStateNode.gd")

func _ready() -> void:
	# Connect the native signals that handle creating and deleting wire links visually
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	
	# Create a button on screen to spawn a new logic state 
	var spawn_btn = Button.new()
	spawn_btn.text = "+ New Mode"
	spawn_btn.position = Vector2(20,20)
	spawn_btn.pressed.connect(spawn_new_state_node)
	add_child(spawn_btn)
	
func spawn_new_state_node() -> void:
	# instantiate a clean GraphNode via code
	var node = GraphNode.new()
	node.set_script(state_node_script)
	graph_edit.add_child(node)
	
	# Position it slightly offset from the current viewport center
	node.position_offset = graph_edit.scroll_offset + Vector2(200, 150)

# Fired when a user drags a wire from an output port onto an input port
func _on_connection_request(from_node: StringName, from_port:int, to_node: StringName, to_port: int ) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

# Fired when a user disconnects a linked wire 
func _on_disconnection_request(from_node: StringName, from_port: int, to_node:StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

# --- The compiler: converts visual wires into game logic data ---
func compile_graph_to_fsm() -> void:
	if not runner:
		print("Error: FSMRunner node is not assigned in the VisualEditor inspector!")
		return
	
	# wipe out any old running memory paths 
	runner.states.clear()
	
	var visual_nodes = graph_edit.get_children()
	var connections = graph_edit.get_connection_list()
	
	# Pass 1: Scan all visual cards and register them as clean State logic blocks
	var node_map = {} # maps internal GraphNode string IDs to logic State data objects
	var initial_state_name = ""
	
	for child in visual_nodes:
		# Check if it has custom script property
		if child is GraphNode and "state_name" in child:
			var logic_state = PlayerStateMachine.State.new()
			logic_state.name = child.state_name
			
			# keep track of the very first node name to use as program entry point 
			if initial_state_name == "":
				initial_state_name = logic_state.name
			
			runner.add_state(logic_state)
			node_map[child.name] = logic_state
	
	# Pass 2: Iterate through visual connection lines and build transition logic
	for conn in connections:
		var parent_state = node_map.get(conn["from_node"])
		var target_state = node_map.get(conn["to_node"])
		var path_slot = conn["from_port"] # which path slot row this wire comes out of
		
		if parent_state and target_state:
			var transition = PlayerStateMachine.Transition.new()
			transition.next_state_name = target_state.name
			
			# TEMPORARY HARDCODED RULES
			if path_slot == 1:
				transition.conditions = {"tree_front": false}
				transition.actions = ["move_forward"] as Array[String]
			else:
				transition.conditions = {"tree_front": true}
				transition.actions = ["turn_left"] as Array[String]
			
			parent_state.transitions.append(transition)
	
	if initial_state_name != "":
		print("--- BLUEPRINTS COMPILED SUCCESSFULLY ---")
		runner.start_program(initial_state_name)
	else:
		print("Compilation failed: No behavioral modes found on canvas.")
