@tool
class_name ColoratorSwatchContainer
extends FlowContainer

var _plugin: Colorator
var _swatches: Dictionary[String, ColoratorSwatch] = {}
var _sort_on_change: bool = false


func _init() -> void:
	child_order_changed.connect(_on_child_order_changed)


func set_plugin(plugin: Colorator) -> void:
	_plugin = plugin
	_plugin.color_added.connect(_on_color_added)
	_plugin.color_removed.connect(_on_color_removed)


func load_swatches() -> void:
	_sort_on_change = false
	
	for swatch: ColoratorSwatch in _swatches.keys():
		swatch.queue_free()
	_swatches = {}
	
	var colors: Array[String] = _plugin.get_color_names()
	for color_name: String in colors:
		_add_swatch(color_name)
	
	_sort_on_change = true


func _add_swatch(color_name: String) -> void:
	var s: ColoratorSwatch = ColoratorSwatch.new(_plugin, color_name)
	_swatches[color_name] = s
	add_child(s)


func _on_color_added(color_name: String) -> void:
	if not color_name in _swatches:
		_add_swatch(color_name)


func _on_color_removed(color_name: String) -> void:
	if color_name in _swatches:
		_swatches[color_name].queue_free()
		_swatches.erase(color_name)


func _on_child_order_changed() -> void:
	if not _sort_on_change:
		return
	
	# TODO: This crashes the editor.
	
	## This function runs when this node is freed. So we avoid a crash here.
	#if not is_instance_valid(_plugin):
		#return
	#
	#var names: Array[String] = _plugin.get_color_names()
	#for color_name: String in names:
		#_swatches[color_name].move_to_front.call_deferred()
