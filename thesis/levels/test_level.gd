extends Node2D

@onready var fsm_runner = $Player/StateMachineRunner

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	setup_test_program()

func setup_test_program() -> void:
	var walking_state = PlayerStateMachine.State.new()
	walking_state.name = "Walking"
	
	# Path A: If NO tree in front -> Move Forward, stay in "Walking" state
	var path_move = PlayerStateMachine.Transition.new()
	path_move.conditions = {"tree_front": false}
	path_move.actions = ["move_forward"]
	path_move.next_state_name = "Walking"
	
	# Path B: If tree IS in front -> Turn Left, go to "Stop"
	var path_turn = PlayerStateMachine.Transition.new()
	path_turn.conditions = {"tree_front": true}
	path_turn.actions = ["turn_left"]
	path_turn.next_state_name = "Stop"
	
	# Assign transitions to the state
	walking_state.transitions.append(path_move)
	walking_state.transitions.append(path_turn)
	
	# 2. Feed the states to the runner
	fsm_runner.add_state(walking_state)
	
	# 3. Start running!
	print("--- LAUNCHING STATE MACHINE PROGRAM ---")
	fsm_runner.start_program("Walking")
