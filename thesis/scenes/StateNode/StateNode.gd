# StateNode.gd
extends GraphNode

@export var transition_row_scene: PackedScene # TransitionRow.tscn
@onready var state_name_edit: LineEdit = $StateNameEdit
@onready var add_button : Button = $AddTransitionButton

func _ready() -> void:
	# Connect the add button
	add_button.pressed.connect(add_new_transition_row)


func add_new_transition_row() -> void:
	var new_row = transition_row_scene.instantiate()
	add_child(new_row)
	
	new_row.row_about_to_be_deleted.connect(_on_row_deleted)
	
	# CRITICAL: Wait one frame for Godot to register the new child's
	# size and update the internal right_port_cache size!
	await get_tree().process_frame
	
	# Determine the slot index of our newly added row child
	var current_slot_index = new_row.get_index()
	
	#enable the right connection port for this specific row slot
	# parameters: slot_index, enable_left, left_type, left_color, enable_right, right_type, right_color
	set_slot(current_slot_index, true, 0, Color.WHITE, true, 0, Color.GREEN)


# gather data for all transition rows inside this node
func get_state_data() -> PlayerStateMachine.State:
	var state = PlayerStateMachine.State.new()
	state.name = state_name_edit.text if state_name_edit.text != "" else name
	
	# loop through our children and look for TransitionRow instances
	for child in get_children():
		if child.has_method("get_transition_data"):
			var transition = child.get_transition_data()
			state.transitions.append(transition)
	
	return state

func _on_row_deleted(row_node: HBoxContainer) -> void:
	var port_index = row_node.get_index()
	var canvas = get_parent() # graphedit node
	
	if canvas and canvas.has_method("disconnect_node"):
		# find any connection coming out of this specific port and sever it 
		for conn in canvas.get_connection_list():
			if conn.from_node == name and conn.from_port == port_index:
				canvas.disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
	
	# clear the slot layout settings for this row so the cache clears
	set_slot(port_index, false, 0, Color.WHITE, false, 0, Color.WHITE)
