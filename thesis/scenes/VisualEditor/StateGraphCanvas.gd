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
				
