@tool
extends EditorPlugin

var _connected_labels: Array[RichTextLabel] = []
var _refresh_timer: Timer
var _target_node_path: NodePath
var _target_node_relative_path: NodePath


func _enable_plugin() -> void:
	pass


func _enter_tree() -> void:
	call_deferred("_on_deferred")


func _exit_tree() -> void:
	# disconnect signals
	for label in _connected_labels:
		if label.meta_clicked.is_connected(_on_meta_clicked):
			label.meta_clicked.disconnect(_on_meta_clicked)

	if _refresh_timer:
		_refresh_timer.queue_free()
		_refresh_timer = null


func _on_deferred():
	_generate_colors_class_file()
	_setup_timer()
	_refresh_label_connections()
	EditorInterface.get_editor_settings().settings_changed.connect(_on_setting_changed)

	scene_changed.connect(_on_scene_changed)


func _on_setting_changed():
	var changed_settings = EditorInterface.get_editor_settings().get_changed_settings()
	if changed_settings.has("interface/theme/preset"):
		_generate_colors_class_file()


func _generate_colors_class_file():
	var source_link_color = (
		EditorInterface.get_editor_settings().get_setting(
			"text_editor/theme/highlighting/safe_line_number_color",
		)
	)
	var error_color = (
		EditorInterface.get_editor_settings().get_setting(
			"text_editor/theme/highlighting/breakpoint_color",
		)
	)
	var warning_color = (
		EditorInterface.get_editor_settings().get_setting(
			"text_editor/theme/highlighting/executing_line_color",
		)
	)

	var text_color = (
		EditorInterface.get_editor_settings().get_setting(
			"text_editor/theme/highlighting/text_color",
		)
	)

	var comment_color = (
		EditorInterface.get_editor_settings().get_setting(
			"text_editor/theme/highlighting/comment_color",
		)
	)

	var buf = (
		"\n".join(
			[
				"@abstract class_name CLogColors",
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
	_connected_labels = _connected_labels.filter(
		func(label):
			return is_instance_valid(label)
	)

	var labels = EditorInterface.get_base_control().find_children("*", "RichTextLabel", true, false)
	for label in labels:
		if !label.meta_clicked.is_connected(_on_meta_clicked):
			label.meta_clicked.connect(_on_meta_clicked)
			_connected_labels.append(label)


func _on_scene_changed(_scene: Node):
	if _target_node_path.is_empty():
		return
	_focus_node_in_scene_tree()


func _on_meta_clicked(meta: Variant):
	var meta_str = str(meta)
	if !CLog.is_godot_4_6_or_higher():
		if (meta_str.begins_with("./")
			&& meta_str.find(":") != -1 ):
			# expected "./path/to/file.gd:10 @_ready()"
			var path_and_other = meta_str.split(":")
			var file_path = path_and_other[0].replace("./", "res://") # "res" + "//path..."
			var line_number = int(path_and_other[-1])

			if FileAccess.file_exists(file_path):
				_open_script_at_line(file_path, line_number)

	if meta_str.begins_with("__node_info__"):
		# expected "__node_path__/root/path/to/node"
		_open_node_path(meta_str)


func _open_node_path(meta_str: String):
	var split := meta_str.trim_prefix("__node_info__/root").split(";")

	if split.size() < 3:
		print("CLog: Invalid link, ", meta_str)
		return

	var node_path := split[0]
	var relative_path := split[1]
	var scene_file_path := split[2]
	var scene_roots := EditorInterface.get_open_scene_roots()

	_target_node_path = node_path
	_target_node_relative_path = relative_path

	# scene is already editing.
	if scene_file_path != EditorInterface.get_edited_scene_root().scene_file_path:
		EditorInterface.open_scene_from_path(scene_file_path)
		return

	_focus_node_in_scene_tree()


func _focus_node_in_scene_tree():
	var scene_root = EditorInterface.get_edited_scene_root()

	if scene_root == null:
		print("CLog: Edited scene root is not found")
		return

	var path_in_editor = NodePath(str(scene_root.get_path()).path_join(str(_target_node_path)))
	var target_node = scene_root.get_node_or_null(path_in_editor)

	if target_node == null:
		# couldn't reach target_node path.
		# search with relative node path again.
		path_in_editor = NodePath(
			str(scene_root.get_path()).path_join(str(_target_node_relative_path)),
		)

	target_node = scene_root.get_node_or_null(path_in_editor)

	if target_node != null:
		EditorInterface.edit_node(target_node)
	else:
		print("CLog: Node not found in scene: ", _target_node_path)

	_target_node_path = ""
	_target_node_relative_path = ""


func _open_script_at_line(path: String, line: int):
	var script = load(path)
	if script is Script:
		EditorInterface.edit_resource(script)
		EditorInterface.get_script_editor().goto_line(line - 1)
