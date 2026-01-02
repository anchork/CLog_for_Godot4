@tool
extends EditorPlugin


func _enable_plugin() -> void:
	_connect_labels()

func _connect_labels():
	var base_control = EditorInterface.get_base_control()
	var labels = base_control.find_children("*", "RichTextLabel", true, false)
	
	for label in labels:
		if label is RichTextLabel:
			if not label.meta_clicked.is_connected(_on_meta_clicked):
				label.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta: Variant):
	var url = str(meta)
	if url.begins_with("./") && url.find(":") != -1:
		var split = url.split(":")
		var res_url = split[0].strip_edges().replace("./", "res://")
		var line_number = int(split[1].split("@")[0].strip_edges())
		open_script_at_line(res_url, line_number)
	
	
func open_script_at_line(file_path: String, line_number: int):
	var script = load(file_path)
	if script is Script:
		EditorInterface.edit_resource(script)
		
		var script_editor = EditorInterface.get_script_editor()
		script_editor.goto_line(line_number - 1) 
		
func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass
