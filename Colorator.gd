@tool
class_name Colorator
extends EditorPlugin

signal color_added(color_name: String)
signal color_changed(color_name: String, color: Color)
signal color_selected(color_name: String)
signal color_removed(color_name: String)

const PROJECT_SETTING_COLORS_KEY: String = "duriel/colorator/colors"
const PROJECT_SETTING_SWATCH_SIZE_KEY: String = "duriel/colorator/swatch_size"
const DEFAULT_SWATCH_SIZE: Vector2i = Vector2i(64, 64)

const DEFAULT_COLORS: Dictionary[String, Color] = {"a_white" : Color.WHITE, "a_black" : Color.BLACK}
const DOCK_SCENE_UID: String = "uid://d3dknqnrxxk4f"

var _colors: Dictionary[String, Color] = DEFAULT_COLORS.duplicate()
var _dock: iColoratorDock
var _selected_color: String = ""


func _ready() -> void:
	if ProjectSettings.get_setting(PROJECT_SETTING_SWATCH_SIZE_KEY, Vector2i.ZERO) == Vector2i.ZERO:
		ProjectSettings.set_setting(PROJECT_SETTING_SWATCH_SIZE_KEY, DEFAULT_SWATCH_SIZE)
	
	var d: Dictionary = ProjectSettings.get_setting(PROJECT_SETTING_COLORS_KEY, DEFAULT_COLORS)
	_colors.assign(d)
	print("Colorator initialized with %s saved colors." % _colors.size())
	
	_dock = iColoratorDock.instantiate(self)
	add_dock(_dock)
	


func _exit_tree() -> void:
	ProjectSettings.set_setting(PROJECT_SETTING_COLORS_KEY, _colors)
	ProjectSettings.save()
	
	remove_dock(_dock)
	_dock.queue_free()


func get_color_names() -> Array[String]:
	return _colors.keys()


func get_color(color_name: String) -> Color:
	return _colors.get(color_name, Color.DEEP_PINK)


func set_color(color_name: String, color: Color) -> void:
	if not color_name in _colors:
		_colors[color_name] = color
		color_added.emit(color_name)
	else:
		_colors[color_name] = color
		color_changed.emit(color_name, color)


func copy_color(color_name: String, select: bool = false) -> void:
	if not color_name in _colors:
		return
	
	var _copy_suffix: int = 0
	while true:
		if color_name + "_%s" % _copy_suffix in _colors:
			continue
		_copy_suffix += 1
		break
	
	var new_name: String = color_name + "_%s" % _copy_suffix
	set_color(new_name, get_color(color_name))
	
	if select:
		select_color.call_deferred(new_name)


func remove_color(color_name: String) -> void:
	_colors.erase(color_name)
	color_removed.emit(color_name)


func rename_color(color_name: String, new_name: String) -> void:
	var c: Color = get_color(color_name)
	remove_color(color_name)
	set_color.call_deferred(new_name, c)


func select_color(color_name: String) -> void:
	if not color_name in _colors:
		return
	_selected_color = color_name
	color_selected.emit(color_name)
