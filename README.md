![GoInputBuffer](icon.svg)
# GoInputBuffer
A small Godot addon that implements input buffering.

## 🤔 Why use GoInputBuffer?

There are a bunch of sitautions where you might want user inputs to carry over several frames when implementing certain features in games.

- Input latency 
- Input combos (e.g. fighting games)
- Coyote time
- etc...

`GoInputBuffer` is fully comment documented and simple to use. 

## 🧠 How it works

`GoInputBuffer` is a static class that refrences a (singleton) `GoInputBufferInstance`.

Simply call `buffer_event()` on `GoInputBuffer` when you wish to add an InputEvent to the buffer along with the number of frames to buffer it with. The script also contains several helper classes that allow users to query actions in the input buffer later.

By enabling the plugin in the Godot editor, it also adds 2 new setting options in the `ProjectSettings`
- `addons/go_input_buffer/max_buffer_size`: The max number of InputEvent that the input buffer can contain at once.
- `addons/go_input_buffer/default_buffer_frames`: Default number of buffer frames granted to a BufferedInputEvent if none is specified.

## 🤝 Contributing

If you want to add new action types, improve documentation, or suggest enhancements, please open an issue. Feedback is welcome and appreciated!
