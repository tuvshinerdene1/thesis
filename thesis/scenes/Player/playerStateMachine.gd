# player_state_machine.gd
class_name PlayerStateMachine

class Transition:
	# { FSMTypes.Sensor: bool }
	var conditions: Dictionary = {}
	
	# Array[FSMTypes.Action]
	var actions: Array[FSMTypes.Action] = []
	
	var next_state_name: String = ""
	
class State:
	var name: String = ""
	var transitions: Array[Transition] = []
