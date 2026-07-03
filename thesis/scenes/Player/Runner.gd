extends Node

var states: Dictionary = {} # {"statename": playerstatemachine.state}
var current_state: PlayerStateMachine.State = null
var is_running: bool = false

@onready var player = get_parent()

# add a state to state machine
func add_state(state:PlayerStateMachine.State) -> void:
	states[state.name] = state

# set the entry point of the program and start it 
func start_program(initial_state_name: String) -> void:
	if not states.has(initial_state_name):
		print("Error: initial state not found")
		return
	
	current_state = states[initial_state_name]
	is_running = true
	run_simulation_loop()
	
func run_simulation_loop() -> void:
	while is_running and current_state != null:
		print ("Current FSM state: ", current_state.name)
		
		# look for the first transition where all conditions match player's reality
		var triggered_transition: PlayerStateMachine.Transition = null
		
		for transition in current_state.transitions:
			if evaluate_transition(transition):
				triggered_transition = transition
				break # found the match for this step
		
		if triggered_transition == null:
			print("simulation stopped: no valid transitions found out of state: ", current_state.name)
			is_running = false
			break
			
		# execute the specified actions sequentially, awaiting animations
		for action in triggered_transition.actions:
			if player.has_method(action):
				await player.call(action)
		
		# move to the next state 
		if triggered_transition.next_state_name == "Stop" or triggered_transition.next_state_name == "":
			print("Reached Stop state. program completed successfully")
			is_running = false
		else:
			current_state = states[triggered_transition.next_state_name]
		
		await get_tree().create_timer(0.1).timeout

# check if player's sensors match the criteria for a transition path
func evaluate_transition(transition: PlayerStateMachine.Transition) -> bool:
	for sensor_name in transition.conditions.keys():
		var expected_value = transition.conditions[sensor_name]
		if player.has_method(sensor_name):
			var actual_value = player.call(sensor_name)
			if actual_value != expected_value:
				return false # conditions failed
	return true # all conditions passed
	
