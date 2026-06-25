class_name ColoratorSwatch
extends ColorRect

const FONT_SIZE: int = 10
const FONT_OUTLINE_SIZE: int = 4

var _plugin: Colorator
var _color_name: String = ""
var _selected: bool = false

var _label: Label


func _init(plugin: Colorator, color_name: String) -> void:
	_plugin = plugin
	_color_name = color_name
	color = _plugin.get_color(color_name)
	custom_minimum_size = ProjectSettings.get_setting(Colorator.PROJECT_SETTING_SWATCH_SIZE_KEY, Colorator.DEFAULT_SWATCH_SIZE)
	plugin.color_changed.connect(_on_color_changed)
	plugin.color_selected.connect(_on_color_selected)
	
	_label = Label.new()
	add_child(_label)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.text = _color_name
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_constant_override("outline_size", FONT_OUTLINE_SIZE)


func _ready() -> void:
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT and event.shift_pressed:
			_clicked_left_shift()
		if event.button_index == MOUSE_BUTTON_LEFT:
			_clicked_left()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.shift_pressed:
			_clicked_right_shift()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_clicked_right()


func _draw() -> void:
	if not _selected:
		return
	
	draw_rect(Rect2(Vector2.ZERO, size), color.inverted(), false, 4)


func _clicked_left() -> void:
	_plugin.select_color(_color_name)


func _clicked_right() -> void:
	_plugin.select_color(_color_name)
	DisplayServer.clipboard_set(color.to_html(color.a < 1.0))


func _clicked_left_shift() -> void:
	_plugin.copy_color(_color_name, true)


func _clicked_right_shift() -> void:
	_plugin.remove_color(_color_name)


func _on_color_changed(color_name: String, ncolor: Color) -> void:
	if color_name == _color_name:
		color = ncolor


func _on_color_selected(color_name: String) -> void:
	_selected = color_name == _color_name
	queue_redraw()
