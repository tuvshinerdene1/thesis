# visualStateNode.gd
extends GraphNode

@onready var state_name_edit: LineEdit = $VBoxContainer/StateNameEdit

var state_name: String = "New State":
	get:
		return state_name_edit.text if state_name_edit else "New State"

func _ready() -> void:
	#set up default graphnode properties
	title = "Behavior Mode"
	slot_updated.connect(_on_slot_updated)
	
	# create a basic ui layout inside the node card
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	add_child(vbox)
	
	# add a line edit to name the state (e.g. "Search", "Evade")
	state_name_edit = LineEdit.new()
	state_name_edit.placeholder_text = "Mode Name..."
	vbox.add_child(state_name_edit)
	
	# add a button to add a conditional transition path arrow
	var add_path_btn = Button.new()
	add_path_btn.text = "+ Add Sensory Trigger"
	add_path_btn.pressed.connect(add_transition_slot)
	vbox.add_child(add_path_btn)

func add_transition_slot() -> void:
	var slot_index = get_child_count()
	
	# create a visual container for the transition rules
	var slot_ui = HBoxContainer.new()
	
	# a label showing the rule index
	var label = Label.new()
	label.text= "Path "+ str(slot_index - 1)
	slot_ui.add_child(label)
	
	add_child(slot_ui)
	
	# enable an output port (right side connection link) for this slot
	# set_slot(slot_index, enable_left, left_type, left_color, enable_right, right_type, right_color)
	set_slot(slot_index, false, 0, Color.WHITE, true, 0, Color.MEDIUM_SPRING_GREEN)
