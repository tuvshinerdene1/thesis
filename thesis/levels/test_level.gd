extends Node2D

@onready var player = $Player



func _ready() -> void:
	# Wait a second before the program starts so the player can process it
	await get_tree().create_timer(1.0).timeout
	
	print("Executing program...")
	await player.move_forward()
	await player.turn_left()
	await player.move_forward()
	await player.turn_right()
	await player.move_forward()
	await player.move_forward()
	await player.move_forward()
	await player.move_forward()
	await player.move_forward()
	print("Program finished!")
