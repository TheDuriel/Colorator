@tool
class_name iColoratorDock
extends EditorDock

@export var _box_container: BoxContainer
@export var _scroll_container: ScrollContainer
@export var _swatch_container: ColoratorSwatchContainer
@export var _editor: ColoratorEditor

var _plugin: Colorator


static func instantiate(plugin: Colorator) -> iColoratorDock:
	var i: iColoratorDock = load(Colorator.DOCK_SCENE_UID).instantiate()
	i.set_plugin(plugin)
	return i


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and layout_direction == EditorDock.DOCK_LAYOUT_FLOATING:
		_box_container.vertical = size.y > size.x


func _ready() -> void:
	_scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_swatch_container.set_plugin(_plugin)
	_swatch_container.load_swatches()


func _update_layout(layout: int) -> void:
	_box_container.vertical = true if layout == EditorDock.DOCK_LAYOUT_VERTICAL else false 


func set_plugin(plugin: Colorator) -> void:
	_plugin = plugin
	_editor.set_plugin(_plugin)
