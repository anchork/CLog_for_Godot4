@tool
extends EditorPlugin

var _connected_labels: Array[RichTextLabel] = []
var _refresh_timer: Timer


func _enable_plugin() -> void:
	pass


func _enter_tree() -> void:
	call_deferred("_on_deferred")


func _exit_tree() -> void:
	if _refresh_timer:
		_refresh_timer.queue_free()
		_refresh_timer = null


func _on_deferred():
	_generate_colors_class_file()
	_setup_timer()
	_refresh_label_connections()
	EditorInterface.get_editor_settings().settings_changed.connect(_on_setting_changed)


func _on_setting_changed():
	var changed_settings = EditorInterface.get_editor_settings().get_changed_settings()
	if changed_settings.has("interface/theme/preset"):
		_generate_colors_class_file()


func _generate_colors_class_file():
	var source_link_color = EditorInterface.get_editor_settings().get_setting(
		"text_editor/theme/highlighting/safe_line_number_color",
	)
	var error_color = EditorInterface.get_editor_settings().get_setting(
		"text_editor/theme/highlighting/breakpoint_color",
	)
	var warning_color = EditorInterface.get_editor_settings().get_setting(
		"text_editor/theme/highlighting/executing_line_color",
	)

	var text_color = EditorInterface.get_editor_settings().get_setting(
		"text_editor/theme/highlighting/text_color",
	)

	var comment_color = EditorInterface.get_editor_settings().get_setting(
		"text_editor/theme/highlighting/comment_color",
	)

	var buf = (
		"\n".join(
			[
				"class_name CLogColors",
				"\n",
				"const SOURCE_LINK_COLOR = Color{source_link_color}",
				"const TEXT_COLOR = Color{text_color}",
				"const DIMMED_COLOR = Color{dimmed_color}",
				"const ERROR_COLOR = Color{error_color}",
				"const WARNING_COLOR = Color{warning_color}",
			],
		).format(
			{
				"source_link_color": source_link_color,
				"text_color": text_color,
				"dimmed_color": comment_color,
				"error_color": error_color,
				"warning_color": warning_color,
			},
		)
	)
	var file = FileAccess.open("res://addons/clog/clog_colors.gd", FileAccess.WRITE)
	file.store_string(buf)
	file.flush()
	file.close()
	print("(re)generated clog_colors.gd")
	EditorInterface.get_resource_filesystem().scan()


func _setup_timer():
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 10.0
	_refresh_timer.autostart = true
	_refresh_timer.timeout.connect(_refresh_label_connections)
	add_child(_refresh_timer)


func _refresh_label_connections():
	_connected_labels = _connected_labels.filter(func(label): return is_instance_valid(label))

	var labels = EditorInterface.get_base_control().find_children("*", "RichTextLabel", true, false)
	for label in labels:
		if !label.meta_clicked.is_connected(_on_meta_clicked):
			label.meta_clicked.connect(_on_meta_clicked)
			_connected_labels.append(label)


func _on_meta_clicked(meta: Variant):
	var meta_str = str(meta)
	# expected "./path/to/file.gd:10 @_ready()"
	if (meta_str.begins_with("./")
		&& meta_str.find(":") != -1
		&& meta_str.find("@") != -1 ):
		var path_and_other = meta_str.split(":")
		var file_path = path_and_other[0].replace("./", "res://") # "res" + "//path..."
		var line_number = int(path_and_other[1].split("@")[0].strip_edges())

		if FileAccess.file_exists(file_path):
			_open_script_at_line(file_path, line_number)


func _open_script_at_line(path: String, line: int):
	var script = load(path)
	if script is Script:
		EditorInterface.edit_resource(script)
		EditorInterface.get_script_editor().goto_line(line - 1)


func _disable_plugin() -> void:
	for label in _connected_labels:
		if label.meta_clicked.is_connected(_on_meta_clicked):
			label.meta_clicked.disconnect(_on_meta_clicked)
