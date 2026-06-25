@tool
class_name ColoratorEditor
extends MarginContainer

@export var _color_rect_preview: ColorPickerButton
@export var _line_edit_name: LineEdit
@export var _button_save: Button
@export var _button_copy: Button
@export var _button_delete: Button

@export var _box_H: SpinBox
@export var _box_S: SpinBox
@export var _box_V: SpinBox
@export var _box_R: SpinBox
@export var _box_G: SpinBox
@export var _box_B: SpinBox
@export var _box_A: SpinBox

@export var _line_edit_hex: LineEdit

@export var _button_hex_copy: Button
@export var _button_hex_paste: Button

var _plugin: Colorator
var _color_name: String
var _color: Color:
	set(value):
		_color = value
		_refresh_previews()
var _changed: bool = false:
	set(value):
		_changed = value
		if _button_save: _button_save.modulate = Color.RED if _changed else Color.WHITE
var _is_updating_previews: bool = false
var _is_ignoring_picker_changes: bool = false


func _ready() -> void:
	visible = false
	_line_edit_name.text_submitted.connect(_on_name_submitted)
	_button_save.pressed.connect(_on_save_pressed)
	_button_copy.pressed.connect(_on_copy_pressed)
	_button_delete.pressed.connect(_on_delete_pressed)
	_color_rect_preview.get_picker().color_changed.connect(_on_picker_color_changed)
	_box_H.value_changed.connect(_on_H_changed)
	_box_S.value_changed.connect(_on_S_changed)
	_box_V.value_changed.connect(_on_V_changed)
	_box_R.value_changed.connect(_on_R_changed)
	_box_G.value_changed.connect(_on_G_changed)
	_box_B.value_changed.connect(_on_B_changed)
	_box_A.value_changed.connect(_on_A_changed)
	_line_edit_hex.text_submitted.connect(_on_hex_submitted)
	_button_hex_copy.pressed.connect(_on_hex_copy_pressed)
	_button_hex_paste.pressed.connect(_on_hex_paste_pressed)


func set_plugin(plugin: Colorator) -> void:
	_plugin = plugin
	_plugin.color_selected.connect(_on_color_selected)
	_plugin.color_removed.connect(_on_color_removed)


func _on_color_selected(color_name: String) -> void:
	_color_name = color_name
	_color = _plugin.get_color(_color_name)
	_line_edit_name.text = color_name
	visible = true
	_changed = false


func _on_color_removed(color_name: String) -> void:
	if _color_name == color_name:
		visible = false


func _on_name_submitted(new_name: String) -> void:
	_plugin.set_color(new_name, _color)
	_changed = false
	_plugin.select_color.call_deferred(new_name)


func _on_save_pressed() -> void:
	_plugin.set_color(_color_name, _color)
	_changed = false


func _on_copy_pressed() -> void:
	_plugin.copy_color(_color_name, true)
	_changed = false


func _on_delete_pressed() -> void:
	_plugin.remove_color(_color_name)
	_changed = false


func _on_picker_color_changed(color: Color) -> void:
	if _is_ignoring_picker_changes: return
	_is_ignoring_picker_changes = true
	_color = color
	_is_ignoring_picker_changes = false


func _on_H_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	if is_equal_approx(value, 360.0):
		value = 0.0
	_color.h = remap(value, 0.0, 360.0, 0.0, 1.0)


func _on_S_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.s = remap(value, 0.0, 100.0, 0.0, 1.0)


func _on_V_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.v = remap(value, 0.0, 100.0, 0.0, 1.0)


func _on_R_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.r = remap(value, 0.0, 255.0, 0.0, 1.0)


func _on_G_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.g = remap(value, 0.0, 255.0, 0.0, 1.0)


func _on_B_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.b = remap(value, 0.0, 255.0, 0.0, 1.0)


func _on_A_changed(value: float) -> void:
	if _is_updating_previews: return
	_changed = true
	_color.a = remap(value, 0.0, 100.0, 0.0, 1.0)


func _on_hex_submitted(hex: String) -> void:
	if _is_updating_previews: return
	if not Color.html_is_valid(hex):
		return
	
	_changed = true
	_color = Color.html(hex)


func _refresh_previews() -> void:
	_is_updating_previews = true
	if _color_rect_preview: _color_rect_preview.color = _color
	if _color_rect_preview: _color_rect_preview.modulate.a = _color.a
	if _box_H: _box_H.value = remap(_color.h, 0.0, 1.0, 0.0, 360.0)
	if _box_S: _box_S.value = remap(_color.s, 0.0, 1.0, 0.0, 100.0)
	if _box_V: _box_B.value = remap(_color.v, 0.0, 1.0, 0.0, 100.0)
	if _box_R: _box_R.value = remap(_color.r, 0.0, 1.0, 0.0, 255.0)
	if _box_G: _box_G.value = remap(_color.g, 0.0, 1.0, 0.0, 255.0)
	if _box_B: _box_B.value = remap(_color.b, 0.0, 1.0, 0.0, 255.0)
	if _box_A: _box_A.value = remap(_color.a, 0.0, 1.0, 0.0, 100.0)
	if _line_edit_hex: _line_edit_hex.text = _color.to_html(_color.a < 1.0)
	_is_updating_previews = false


func _on_hex_copy_pressed() -> void:
	var c: String = _color.to_html(_color.a < 1.0)
	print("Colorizer: Set clipboard %s" % c)
	DisplayServer.clipboard_set(c)


func _on_hex_paste_pressed() -> void:
	var s: String = DisplayServer.clipboard_get()
	print("Colorizer: Get clipboard %s" % s)
	if Color.html_is_valid(s):
		_changed = true
		_color = Color.html(s)
