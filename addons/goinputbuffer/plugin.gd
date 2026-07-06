@tool
extends EditorPlugin

const AUTOLOAD_NAME = "GoInputBufferInstance"
const AUTOLOAD_PATH = "res://addons/goinputbuffer/go_input_buffer_autoload.gd"
const SETTINGS_ROOT_PATH = "addons/go_input_buffer/"
const SETTINGS = {
	"max_buffer_size":{
			"initial_value":10,
			"type":TYPE_INT,
			"hint":PROPERTY_HINT_RANGE,
			"hint_string": "1,100,1,or_greater",
			"description": "Max number of InputEvent that the input buffer can contain at once."
		},
	"default_buffer_frames":{
			"initial_value":25,
			"type":TYPE_INT,
			"hint":PROPERTY_HINT_RANGE,
			"hint_string": "1,100,1,or_greater",
			"description": "Default number of buffer frames granted to a BufferedInputEvent if none is specified."
		},
}
func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton(AUTOLOAD_NAME,AUTOLOAD_PATH)
	_init_plugin_settings()

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	_cleanup_plugin_settings()
	remove_autoload_singleton(AUTOLOAD_NAME)

func _init_plugin_settings():
	for setting_key:String in SETTINGS:
		var path = SETTINGS_ROOT_PATH + setting_key
		if not ProjectSettings.has_setting(path):
			ProjectSettings.set_setting(path,SETTINGS[setting_key]["initial_value"])
		ProjectSettings.set_initial_value(path,SETTINGS[setting_key]["initial_value"])
		ProjectSettings.add_property_info({
			"name":path,
			"type":SETTINGS[setting_key]["type"],
			"hint":SETTINGS[setting_key]["hint"],
			"hint_string": SETTINGS[setting_key]["hint_string"],
		})
	ProjectSettings.save()

func _cleanup_plugin_settings():
	for setting_key:String in SETTINGS:
		var path = SETTINGS_ROOT_PATH + setting_key
		if ProjectSettings.has_setting(path):
			ProjectSettings.set_setting(path,null)
	ProjectSettings.save()
