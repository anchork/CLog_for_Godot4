@abstract class_name CLog
## Adds a source link to the line header.
## Converts node paths or node IDs into node links when present.
## [codeblock]
## CLog.o("Normal output") # Normal [INFO] log
## CLog.e("Error output") # [ERROR] log with stack trace
## CLog.w("Warning output") # [WARNING] log
## CLog.v("Verbose output") # [VERBOSE] log with stack trace (no error)
## CLog.c(Color.ORANGE, "Color output") # Log in custom color
## CLog.once(&"key", "Once output") # Log only once per key
## [/codeblock]

const ERROR_TAG = "ERROR"
const WARNING_TAG = "WARNING"
const INFO_TAG = "INFO"
const VERBOSE_TAG = "VERBOSE"

static var disable_output_on_release_mode = true
static var _timers: Dictionary = { }
static var _timer_id: int = 0
static var _timer_bg_colors: Array[Color] = [
	Color.html("#c99e40ff"),
	Color.html("#8eb5cbff"),
	Color.html("#4b8b7aff"),
	Color.html("#b6b282ff"),
	Color.html("#5d95b6ff"),
	Color.html("#9b6c49ff"),
	Color.html("#c095adff"),
]
static var _last_output: String = ""
static var _once_keys: Dictionary[StringName, int] = { }
static var _scheduled_messages: Dictionary[String, int] = { }


## Error output. Shows an emphasized message in color with a "[ERROR]" prefix
## and calls push_error().
static func e(...args) -> void:
	push_error(_get_raw_message(args))

	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	var message = _get_formatted_message(args)
	var current_stack = get_stack()
	var error_message = message + "\n"
	error_message += "\n".join(_get_formatted_stack(4, ERROR_TAG))

	_output(CLogColors.ERROR_COLOR, error_message.trim_suffix("\n"), ERROR_TAG)


## Warning output. Shows an emphasized message in color with a "[WARNING]" prefix
## and calls push_warning().
static func w(...args) -> void:
	push_warning(_get_raw_message(args))
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	var message = _get_formatted_message(args)
	_output(CLogColors.WARNING_COLOR, message, WARNING_TAG)


## Verbose output. Shows a message with a stack trace without an error.
static func v(...args) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	var message = _get_formatted_message(args) + "\n"
	message += "\n".join(_get_formatted_stack(4, VERBOSE_TAG))
	_output(CLogColors.TEXT_COLOR, message.trim_suffix("\n"), VERBOSE_TAG)


## Starts a timer and returns ID and outputs the timer name.
## Call timer_end() with the ID to stop the timer.
## [br]
## [codeblock]
## var timer1_id = CLog.timer_start("timer1")
## # some processing...
## CLog.timer_end(timer1_id)
## [/codeblock]
static func timer_start(timer_name: String) -> int:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return -1

	_timer_id += 1
	var indent_level = _timers.size()
	var bg_color = _get_bg_color(_timer_id)
	var use_alpha = Engine.is_embedded_in_editor()
	var content: String = (
		"".join(
			[
				"[color={indent_line_color}]{indent}[/color]",
				"[bgcolor={bgcolor}]  [/bgcolor] 🚀 ",
				"[color={text_color}]",
				"[ {timer_name} [b]<TIMER_START>[/b] ]",
				"[/color]",
			],
		).format(
			{
				"text_color": "#" + CLogColors.TEXT_COLOR.to_html(use_alpha),
				"indent": "|   ".repeat(indent_level),
				"indent_line_color": "#" + CLogColors.DIMMED_COLOR.to_html(use_alpha),
				"bgcolor": "#" + bg_color.to_html(use_alpha),
				"timer_name": timer_name,
			},
		)
	)

	_timers[_timer_id] = {
		"name": timer_name,
		"start_time": Time.get_ticks_usec(),
		"indent_level": indent_level,
	}

	_output(CLogColors.TEXT_COLOR, content)
	return _timer_id


## Stops the timer with the ID and outputs the timer name and elapsed time.
## [br]
## [codeblock]
## var timer1_id = CLog.timer_start("timer1")
## # some processing...
## CLog.timer_end(timer1_id)
## [/codeblock]
static func timer_end(id: int) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	if _timers.has(id):
		var start_time = float(_timers[id]["start_time"])
		var end_time = float(Time.get_ticks_usec())
		var elapsed = (end_time - start_time) / 1000.0
		var timer_name = _timers[id]["name"]
		var indent_level = _timers[id]["indent_level"]

		var bg_color = _get_bg_color(id)
		var use_alpha = Engine.is_embedded_in_editor()
		var content = (
			"".join(
				[
					"[color={indent_line_color}]{indent}[/color]",
					"[bgcolor={bgcolor}]  [/bgcolor] ⏱️",
					"[color={text_color}]",
					" [ {timer_name} [b]<TIMER_END>[/b] ",
					"[/color]",
					"[color={elapsed_color}]",
					"([i]{elapsed}[/i]) ",
					"[/color]",
					"[color={text_color}]",
					"]",
					"[/color]",
				],
			).format(
				{
					"text_color": "#" + CLogColors.TEXT_COLOR.to_html(use_alpha),
					"indent_line_color": "#" + CLogColors.DIMMED_COLOR.to_html(use_alpha),
					"indent": "|   ".repeat(indent_level),
					"bgcolor": "#" + bg_color.to_html(use_alpha),
					"timer_name": timer_name,
					"elapsed": "%.3f" % elapsed + "ms",
					"elapsed_color": "#" + CLogColors.WARNING_COLOR.to_html(use_alpha),
				},
			)
		)
		_output(CLogColors.TEXT_COLOR, content)
		_timers.erase(id)
	else:
		e("Timer %s is not running or has already ended." % id)


## Cancels the timer with the ID and outputs the timer name.
## [br]
## [codeblock]
## var timer1_id = CLog.timer_start("timer1")
## # some processing...
## CLog.timer_cancel(timer1_id)
## [/codeblock]
static func timer_cancel(id: int) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	if _timers.has(id):
		var timer_name = _timers[id]["name"]
		var indent_level = _timers[id]["indent_level"]
		_timers.erase(id)
		var bg_color = _get_bg_color(id)
		var use_alpha = Engine.is_embedded_in_editor()
		var content = (
			"".join(
				[
					"[color={indent_line_color}]{indent}[/color]",
					"[bgcolor={bgcolor}]  [/bgcolor] ❌",
					"[color={text_color}]",
					" [ {timer_name} [b]<TIMER_CANCELED>[/b] ]",
					"[/color]",
				],
			).format(
				{
					"text_color": "#" + CLogColors.TEXT_COLOR.to_html(use_alpha),
					"indent_line_color": "#" + CLogColors.DIMMED_COLOR.to_html(use_alpha),
					"indent": "|   ".repeat(indent_level),
					"bgcolor": "#" + bg_color.to_html(use_alpha),
					"timer_name": timer_name,
				},
			)
		)
		_output(CLogColors.TEXT_COLOR, content)
	else:
		e("Timer %s is not running or has already ended." % id)


## Normal output.
static func o(...args) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return
	_output(CLogColors.TEXT_COLOR, _get_formatted_message(args), INFO_TAG)


## Outputs with the specified color.
## [br]
## [codeblock]
## CLog.c(Color.MISTY_ROSE, "color print")
## [/codeblock]
static func c(color: Color, ...args) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	_output(color, _get_formatted_message(args), INFO_TAG)


## Outputs the message only once per key.
static func once(key: String, ...args) -> void:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return

	_output(CLogColors.TEXT_COLOR, _get_formatted_message(args), INFO_TAG, key)


static func _output(color: Color, message: String, tag: String = "", key: String = "") -> void:
	var source_link = _get_source_link(_get_caller(3))

	if !key.is_empty():
		if _once_keys.has(key):
			return

	var use_alpha = Engine.is_embedded_in_editor()
	var formatted_message = (
		"".join(
			[
				"[color={line_color}]",
				"[{source_link}]",
				"[/color]",
				"[color={color}]",
				"{tag}{message}",
				"[/color]",
			],
		).format(
			{
				"line_color": "#" + CLogColors.SOURCE_LINK_COLOR.to_html(use_alpha),
				"source_link": source_link,
				"color": "#" + color.to_html(use_alpha),
				"tag": "" if tag.is_empty() else " [b][" + tag + "][/b]",
				"message": " " + message,
			},
		)
	)

	if _last_output == formatted_message:
		_schedule_flush(formatted_message)
	else:
		_flush(_last_output)
		print_rich(formatted_message)
		_last_output = formatted_message

	if !key.is_empty():
		_once_keys[key] = 0


static func _schedule_flush(message: String) -> void:
	if _scheduled_messages.has(message):
		_scheduled_messages[message] += 1
		return

	_scheduled_messages[message] = 0

	var main_loop = Engine.get_main_loop()
	if main_loop:
		await main_loop.process_frame

	_flush(message)


static func _flush(message: String) -> void:
	var use_alpha = Engine.is_embedded_in_editor()
	if _scheduled_messages.has(message):
		var count = _scheduled_messages[message] + 1
		if count > 5:
			print_rich(
				(
					"[color={color}] └ (repeated {count}x)[/color]".format(
						{
							"color": "#" + CLogColors.DIMMED_COLOR.to_html(use_alpha),
							"count": count,
						},
					)
				),
			)
		else:
			for i in count:
				print_rich(message)

	_scheduled_messages.erase(message)
	_last_output = ""


static func _get_source_link(stacktrace_line: Dictionary) -> String:
	if stacktrace_line.size() == 0:
		return "UNKNOWN CALLER"

	# { "source": "res://scenes/view/view.gd", "function": "enter", "line": 38 }
	var full_path = ProjectSettings.globalize_path(stacktrace_line["source"])
	var project_path = ProjectSettings.globalize_path("res://")
	var file_path = full_path.trim_prefix(project_path)
	var link = (
		"{file_path}:{line_number}".format(
			{
				"file_path": file_path,
				"line_number": str(stacktrace_line["line"]),
			},
		)
	)

	var short_link = link.split("/")[-1]
	var function_name = stacktrace_line["function"]
	var formatted = "./%s @%s()" % [link, function_name]
	if Engine.is_embedded_in_editor():
		formatted = (
			"".join(
				[
					"[hint='{link}']",
					"[url={scheme}{link}]",
					"/{short_link} @{function}()",
					"[/url]",
					"[/hint]",
				],
			).format(
				{
					"scheme": "res://" if is_godot_4_6_or_higher() else "./",
					"link": link,
					"short_link": short_link,
					"function": function_name,
				},
			)
		)

	return formatted


static func _get_formatted_stack(start_index: int = 0, hint: String = "") -> Array[String]:
	var current_stack = get_stack()
	var formatted_lines: Array[String] = []
	var in_editor = Engine.is_embedded_in_editor()

	for i in range(start_index, current_stack.size() + 1):
		# Add an invisible tag to allow filtering.
		var hint_str = ""
		if in_editor && !hint.is_empty():
			hint_str = "[hint={hint}][/hint]"

		formatted_lines.append(
			"".join(
				[
					hint_str,
					"\t",
					" ".repeat(i - start_index),
					"[color={comment_color}] └ ",
					_get_source_link(_get_caller(i)),
					"[/color]",
				],
			).format(
				{
					"hint": hint,
					"comment_color": "#" + CLogColors.DIMMED_COLOR.to_html(in_editor),
				},
			),
		)
	return formatted_lines


static func _get_formatted_message(arr: Array) -> String:
	var r: Array[String] = []

	if !Engine.is_embedded_in_editor():
		return _get_raw_message(arr)

	for e in arr:
		var link = ""
		if e is NodePath:
			var current_scene = Engine.get_main_loop().current_scene
			if current_scene != null:
				var node = current_scene.get_node_or_null(e)
				link = _format_node_link(node, str(e))
		elif e is Node:
			link = _format_node_link(e, str(e))

		if !link.is_empty():
			r.append(link)
		else:
			r.append(str(e))

	return " ".join(r)


static func _format_node_link(node: Node, display_text: String) -> String:
	if node == null || !node.is_inside_tree():
		return ""

	var node_path := str(node.get_path())
	var relative_path := ""
	var file_path := ""

	if node.owner != null:
		# not root node.
		relative_path = str(node.owner.get_path_to(node))
		file_path = node.owner.scene_file_path
	else:
		# root node. it has no owner.
		file_path = node.scene_file_path

	if file_path.is_empty():
		# instantiated node by script.
		# has no owner, so walk up the parent nodes to find scene_file_path.
		var parent: Node = node.get_parent()
		while file_path.is_empty() && parent != null:
			file_path = parent.scene_file_path
			parent = parent.get_parent()

	if file_path.is_empty():
		return ""

	return "".join(
		[
			"[hint={node_path} <{file_path}>]",
			"[url=__node_info__{node_path};{relative_path};{file_path}]",
			"{text}",
			"[/url]",
			"[/hint]",
		],
	).format(
		{
			"node_path": node_path,
			"relative_path": relative_path,
			"file_path": file_path,
			"text": display_text,
		},
	)


static func _get_raw_message(arr: Array):
	var r: Array[String] = []
	for e in arr:
		r.append(str(e))
	return " ".join(r)


static func _get_caller(backward_index: int) -> Dictionary:
	var current_stack = get_stack()
	if current_stack.size() <= backward_index:
		return { }

	return current_stack[backward_index]


static func _get_bg_color(seed: int) -> Color:
	return _timer_bg_colors[seed % _timer_bg_colors.size()]


static func _get_root_child(node: Node) -> Node:
	var root = node.get_tree().root
	if node == root:
		return node

	var parent = node.get_parent()
	while parent != null && parent != root:
		node = parent
		parent = node.get_parent()

	return node


static func is_godot_4_6_or_higher():
	var version = Engine.get_version_info()
	return version.major > 4 || (version.major == 4 && version.minor >= 6)
