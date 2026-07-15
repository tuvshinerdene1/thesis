# test_level.gd
extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	# 1. build states and transitions
	var state_search = PlayerStateMachine.State.new()
	state_search.name = "Search"
	
	var state_move = PlayerStateMachine.State.new()
	state_move.name = "Move"
	
	# Transition 1: if there's tree in front, turn right and keep searching
	var t_hit_tree = PlayerStateMachine.Transition.new()
	t_hit_tree.conditions = { FSMTypes.Sensor.TREE_FRONT: true }
	t_hit_tree.actions.append(FSMTypes.Action.TURN_RIGHT) # <-- FIXED: Using append()
	t_hit_tree.next_state_name = "Search"
	
	# Transitions 2: if the path is clear, transition to Move
	var t_clear = PlayerStateMachine.Transition.new()
	t_clear.conditions = { FSMTypes.Sensor.TREE_FRONT: false }
	# No actions appended here, defaults to empty
	t_clear.next_state_name = "Move"
	
	state_search.transitions = [t_hit_tree, t_clear] as Array[PlayerStateMachine.Transition]
	
	# Transition 3: move forward and go back to Search
	var t_execute_move = PlayerStateMachine.Transition.new()
	t_execute_move.conditions = {}
	t_execute_move.actions.append(FSMTypes.Action.MOVE_FORWARD) # <-- FIXED: Using append()
	t_execute_move.next_state_name = "Search"
	
	state_move.transitions = [t_execute_move] as Array[PlayerStateMachine.Transition]
	
	player.add_state(state_search)
	player.add_state(state_move)
	
	player.start_program("Search")
