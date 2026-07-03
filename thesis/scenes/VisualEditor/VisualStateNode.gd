# visualStateNode.gd
extends GraphNode

@onready var state_name_edit: LineEdit

var state_name: String = "New State":
	get:
		# Using has_node safety check
		if has_node("VBoxContainer/StateNameEdit"):
			var edit = get_node("VBoxContainer/StateNameEdit") as LineEdit
			return edit.text if edit.text != "" else "New State"
		return "New State"

func _ready() -> void:
	# Set up default visual appearance
	title = "Behavior Mode"
	
	# Important for GraphNodes: give it an initial size so it isn't tiny
	custom_minimum_size = Vector2(200, 150)
	
	# Create a basic UI layout container inside the node card
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	add_child(vbox)
	
	# Add a line edit to name the state (e.g. "Search", "Evade")
	state_name_edit = LineEdit.new()
	state_name_edit.name = "StateNameEdit"
	state_name_edit.placeholder_text = "Mode Name ..."
	vbox.add_child(state_name_edit)
	
	# Set up the very first input slot (Left side) so other nodes can link INTO this state
	# Slot 0: Left enabled (true), Right disabled (false)
	set_slot(0, true, 0, Color.WHITE, false, 0, Color.TRANSPARENT)
	
func add_transition_slot() -> void:
	# Determine slot index based on child count
	var slot_index = get_child_count()
	
	# Create a visual container for the transition rules
	var slot_ui = HBoxContainer.new()
	slot_ui.name = "PathSlot_" + str(slot_index)
	
	# A label showing the rule index
	var label = Label.new()
	label.text = "Path " + str(slot_index)
	slot_ui.add_child(label)
	
	add_child(slot_ui)
	
	# Enable an output port (right side connection link) for this specific path slot
	# set_slot(index, enable_left, type_left, color_left, enable_right, type_right, color_right)
	set_slot(slot_index, false, 0, Color.WHITE, true, 0, Color.MEDIUM_SPRING_GREEN)
