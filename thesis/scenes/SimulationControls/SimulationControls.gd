# SimulationControls.gd
extends Control

signal play_pressed 
signal pause_pressed
signal stop_pressed
signal speed_changed(new_speed : float)

@onready var play_button: Button = $Toolbar/PlayButton
@onready var pause_button: Button = $Toolbar/PauseButton
@onready var stop_button: Button = $Toolbar/StopButton

func _ready() -> void:
	play_button.pressed.connect(func(): play_pressed.emit())
	pause_button.pressed.connect(func(): pause_pressed.emit())
	stop_button.pressed.connect(func(): stop_button.emit())
