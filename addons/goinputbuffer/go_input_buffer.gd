@icon("res://addons/goinputbuffer/go_input_buffer.svg")
class_name GoInputBuffer extends RefCounted
## Captures [InputEvent]s, keeping references 
## as [GoInputBuffer.BufferedInputEvent]s for later use.
##
## [InputEvent]s are not added to the buffered automatically. [method buffer_event] must be 
## called whenever you wish to add an event to the buffer.
## [br][br]
## Input buffering is used across many games to implement features such as
## but not limited to...
## [codeblock lang=text]
## - Coyote time
## - More responsive user inputs (platformers)
## - Combos in fighting games
## - etc...
## [/codeblock]
## [b][color=goldenrod]Note:[/color][/b][br]
## For more consistnet results, the lifetime of [GoInputBuffer.BufferedInputEvent]
## are evaluated on [b]Physics Frames[/b]. Keep this in mind when choosing how
## many frames to buffer [InputEvent]s with 
## ([b]i.e.[/b] At 60 physics-FPS, each frame takes around 16ms).



## Adds an [InputEvent] to the buffer and stores it as an [BufferedInputEvent].
## Returns [code]true[/code] if the event is added succesfully, [code]false[/code] otherwise.
## [br]
## [br] - [code]event[/code]: [InputEvent] to buffer. Event must be of action type to 
## store in buffer.
## [br] - [code]buffer_frames[/code]: Number of frames the event will be buffered for.
static func buffer_event(event:InputEvent,buffer_frames:int = 0)->bool:
	if not event.is_action_type():
		return false
	if GoInputBufferInstance._input_event_buffer.size() == GoInputBufferInstance._max_buffer_size:
		GoInputBufferInstance._input_event_buffer.pop_front()
	var buffered_event:BufferedInputEvent = BufferedInputEvent.new(event,buffer_frames)
	GoInputBufferInstance._input_event_buffer.push_back(buffered_event)
	return true

## Search for the most recent instance of a given action in the buffer.
## Returns the BufferedInputEvent if the action is found, null otherwise.
## [br] - [code]action[/code]: Name of the input action.
## [br] - [code]consume_events[/code]: If [code]true[/code] and the action is found,
## consumes the event and remove it from the buffer. If [code]false[/code] let it expire normally. 
static func get_latest_buffered_action(action:String,consume_event:bool = false)->BufferedInputEvent:
	for e:BufferedInputEvent in GoInputBufferInstance._input_event_buffer:
		if e.input_event.is_action(action,true):
			if consume_event:
				GoInputBufferInstance._input_event_buffer.erase(e)
			return e
	return null

## Search for the oldest instance of a given action in the buffer.
## Returns the BufferedInputEvent if the action is found, null otherwise.
## [br] - [code]action[/code]: Name of the input action.
## [br] - [code]consume_events[/code]: If [code]true[/code] and the action is found,
## consumes the event and remove it from the buffer. If [code]false[/code] let it expire normally. 
static func get_oldest_buffered_action(action:String,consume_event:bool = false)->BufferedInputEvent:
	var buffer:= GoInputBufferInstance._input_event_buffer
	for idx in range(buffer.size()-1,-1,-1):
		var e:BufferedInputEvent = buffer[idx]
		if e.input_event.is_action(action,true):
			if consume_event:
				GoInputBufferInstance._input_event_buffer.erase(e)
			return e
	return null

## Checks if a given action is in the buffer.
## Returns [code]true[/code] if the action is found, [code]false[/code] otherwise.
## [br] - [code]action[/code]: Name of the input action.
## [br] - [code]consume_events[/code]: If [code]true[/code] and the action is found,
## consumes the event and remove it from the buffer. If [code]false[/code] let it expire normally. 
static func is_action_buffered(action:String,consume_event:bool = false)->bool:
	for e:BufferedInputEvent in GoInputBufferInstance._input_event_buffer:
		if e.input_event.is_action(action,true):
			if consume_event:
				GoInputBufferInstance._input_event_buffer.erase(e)
			return true
	return false

## Checks if a given sequence of [InputEventAction]s is in the buffer.
## Returns [code]true[/code] if the sequence is found, [code]false[/code] otherwise.
## [br] - [code]sequence[/code]: Array of string containing the sequence of actions to query.
## [br] - [code]consume_events[/code]: If [code]true[/code] and the sequence is found,
## consumes the events associated with this sequence and remove them from the buffer.
## If [code]false[/code] [InputEvent]s remain in the buffer to expire normally. 
static func is_action_sequence_buffered(sequence:Array[String] = [],consume_events:bool = false)->bool:
	# if sequence is empty or shorter than current buffer, early return
	if sequence.is_empty() or GoInputBufferInstance._input_event_buffer.size() < sequence.size():
		return false
	var found:bool = false
	var sub_array:Array[BufferedInputEvent]
	var idx:int = 0
	for e:BufferedInputEvent in GoInputBufferInstance._input_event_buffer:
		var action :String = sequence[idx]
		# current event sequence matches...
		if InputMap.has_action(action) and e.input_event.is_action(action,true):
			sub_array.append(e)
			idx += 1
			# Sequence found!
			if idx == sequence.size():
				found = true
				break
		else:
			sub_array.clear()
			idx = 0
	if found:
		if consume_events:
			for e in sub_array:
				GoInputBufferInstance._input_event_buffer.erase(e)
		return true
	else:
		return false

## Clears all [GoInputBuffer.BufferedInputEvent]s from the buffer.
static func clear_input_buffer():
	GoInputBufferInstance._input_event_buffer.clear()

## Returns a refrence of the input buffer.
static func get_input_buffer()->Array[BufferedInputEvent]:
	return GoInputBufferInstance._input_event_buffer


## Instance of buffered [InputEvent].
class BufferedInputEvent extends RefCounted:
	## Buffered [InputEvent].
	var input_event:InputEvent
	## Physics frame on which the [InputEvent] was buffered.
	var initial_physics_frame:int
	## Number of frames the [InputEvent] is buffered with. 
	var buffer_frames:int
	
	func _init(_input_event:InputEvent, _buffer_frames:int = 0) -> void:
		input_event = _input_event
		initial_physics_frame = Engine.get_physics_frames()
		if _buffer_frames <= 0:
			buffer_frames = ProjectSettings.get_setting("addons/go_input_buffer/default_buffer_frames",20)
		else:	
			buffer_frames = _buffer_frames
	
	## Checks if this instance has expired past it's buffer frames.
	func buffer_expired()->bool:
		var current_frame:int = Engine.get_physics_frames()
		return current_frame-initial_physics_frame >= buffer_frames
	
	func _to_string() -> String:
		var string:String = "<%s>"%input_event.as_text()
		string += " - Buffer Frames:%d"%buffer_frames
		return string
