# TransitionRow.gd
extends HBoxContainer

signal row_about_to_be_deleted(row_node)

@onready var sensor_dropdown: OptionButton = $SensorDropdown
@onready var condition_check: CheckBox = $ConditionCheck
@onready var action_dropdown: OptionButton = $ActionDropdown
@onready var remove_button: Button = $RemoveButton

func _ready() -> void:
	# populate dropdowns
	sensor_dropdown.add_item("tree_front")
	sensor_dropdown.add_item("tree_left")
	sensor_dropdown.add_item("tree_right")
	sensor_dropdown.add_item("on_leaf")
	
	action_dropdown.add_item("move_forward")
	action_dropdown.add_item("turn_left")
	action_dropdown.add_item("turn_right")
	
	remove_button.pressed.connect(_on_remove_pressed)

func _on_remove_pressed() -> void:
	# tell the parent state node to clean up lines before freeing memory
	row_about_to_be_deleted.emit(self)
	queue_free()
	
# Helper function to read this specific row's values
func get_transition_data() -> PlayerStateMachine.Transition:
	var transition = PlayerStateMachine.Transition.new()
	
	var selected_sensor = sensor_dropdown.get_item_text(sensor_dropdown.selected)
	var expected_value = condition_check.button_pressed
	transition.conditions[selected_sensor] = expected_value
	
	var selected_action = action_dropdown.get_item_text(action_dropdown.selected)
	transition.actions.append(selected_action)
	
	return transition
	
	
