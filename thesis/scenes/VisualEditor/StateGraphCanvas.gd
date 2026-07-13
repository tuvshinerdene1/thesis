extends GraphEdit

@export var state_node_scene: PackedScene # StateNode.tscn

func _ready() -> void:
	# initial visual states for testing
	spawn_new_state(Vector2(100, 100))
	spawn_new_state(Vector2(400, 100))
	delete_nodes_request.connect(_on_delete_nodes_request)

func spawn_new_state(spawn_position: Vector2):
	var new_node = state_node_scene.instantiate()
	add_child(new_node)
	new_node.position_offset = spawn_position


# signal fired when player drags a line from one node port to another
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# draw the visual line on the canvas
	connect_node(from_node, from_port, to_node, to_port)

# signal fired when player disconnects/deletes a line
func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# erase the visual line from the canvas
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node = get_node(str(node_name))
		if node:
			# disconnect any lines attached to this node first
			for conn in get_connection_list():
				if conn.from_node == node_name or conn.to_node == node_name:
					disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			
			# delete the node safely
			node.queue_free()
				

func compile_graph() -> Dictionary:
	var compiled_states : Dictionary = {}
	
	# step 1 : collect base state data from all visual nodes 
	for child in get_children():
		if child.has_method("get_state_data"):
			var state_data: PlayerStateMachine.State = child.get_state_data()
			# store using the unique Graphnode name as the key for wiring lookups
			compiled_states[child.name] = state_data
			
	# step 2 : use connection wires to fill in next_state_name for every transition
	# get_connection_list() returns an array of dicts: [{from_node, from_port, to_node, to_port}]
	for connection in get_connection_list():
		var source_node_name = connection.from_node
		var target_node_name = connection.to_node
		var source_port_index = connection.from_port
		
		if compiled_states.has(source_node_name) and compiled_states.has(target_node_name):
			var source_state = compiled_states[source_node_name]
			var target_state = compiled_states[target_node_name]
			
			# map the visual target node's title/name as FSM next state destination
			# because slot 0 is the title/name, transision rows map to indices starting with 1 
			# we adjust the index to align with state's transition array
			var transition_index = source_port_index - 1
			
			if transition_index >= 0 and transition_index < source_state.transitions.size():
				source_state.transitions[transition_index].next_state_name = target_state.name
	
	# step 3: convert internal dictionary into a clean lookup of final state names 
	var final_fsm: Dictionary = {}
	for node_name in compiled_states:
		var state = compiled_states[node_name]
		final_fsm[state.name] = state
		
	return final_fsm
	
