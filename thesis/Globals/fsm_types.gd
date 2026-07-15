# fsm_types.gd
class_name FSMTypes

# Type-safe actions

enum Action {
	MOVE_FORWARD,
	TURN_LEFT,
	TURN_RIGHT
}

# Type-safe sensors (Callable signatures)
enum Sensor {
	TREE_FRONT,
	TREE_RIGHT,
	TREE_LEFT,
	ON_LEAF
}

# static helpers to map the enums to actual player methods
static func get_action_name(action: Action) -> StringName:
	match action:
		Action.MOVE_FORWARD: return &"move_forward"
		Action.TURN_LEFT: return &"turn_left"
		Action.TURN_RIGHT: return &"turn_right"
	return &""

static func get_sensor_name(sensor: Sensor) -> StringName:
	match sensor:
		Sensor.TREE_FRONT: return &"tree_front"
		Sensor.TREE_RIGHT: return &"tree_right"
		Sensor.TREE_LEFT: return &"tree_left"
		Sensor.ON_LEAF: return &"on_leaf"
	return &""
