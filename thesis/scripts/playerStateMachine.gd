class_name PlayerStateMachine

class Transition:
	var conditions: Dictionary = {}
	var actions: Array[String] = []
	var next_state_name: String = ""
	
class State:
	var name: String = ""
	var transitions: Array[Transition] = []
