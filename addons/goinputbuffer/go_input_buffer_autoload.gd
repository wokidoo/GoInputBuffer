@icon("res://addons/goinputbuffer/go_input_buffer.svg")
extends Node

var _input_event_buffer:Array[GoInputBuffer.BufferedInputEvent] = []
var _max_buffer_size:int

func _ready() -> void:
	_max_buffer_size = ProjectSettings.get_setting("addons/go_input_buffer/max_buffer_size",30)

func _physics_process(_delta: float) -> void:
	var current_frame: int = Engine.get_physics_frames()
	for e:GoInputBuffer.BufferedInputEvent in _input_event_buffer:
		if e.buffer_expired():
			_input_event_buffer.erase(e)
