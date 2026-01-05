class_name CLog

const TIMER_BG_LIGHTNESS = 0.5
const TIMER_BG_ALPHA = 0.4

static var disable_output_on_release_mode = true
static var _timers: Dictionary = { }
static var _timer_id: int = 0

static var _last_output: String = ""
static var _once_keys: Dictionary[StringName, int] = { }
static var _scheduled_messages: Dictionary[String, int] = { }


static func e(...args):
	var message = _join(args)

	push_error(message)

	var current_stack = get_stack()
	var buf = "[b][ERROR][/b] " + message + "\n"
	var start = 3
	for i in range(start, current_stack.size() + 1):
		buf += "".join(
			[
				"\t",
				" ".repeat(i - start),
				"[color={comment_color}]L ",
				_get_source_link(_get_caller(i)),
				"[/color]\n",
			],
		).format(
			{
				"comment_color": "#" + CLogColors.DIMMED_COLOR.to_html(Engine.is_embedded_in_editor()),
			},
		)

	_output(CLogColors.ERROR_COLOR, buf.trim_suffix("\n"))


static func w(...args):
	var message = _join(args)
	push_warning(message)
	_output(CLogColors.WARNING_COLOR, "[b][WARNING][/b] " + message)


static func timer_start(timer_name: String) -> int:
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return -1

	_timer_id += 1
	_timers[_timer_id] = {
		"name": timer_name,
		"start_time": Time.get_ticks_usec(),
	}

	var bg_color = _get_color(_timer_id, TIMER_BG_LIGHTNESS, TIMER_BG_ALPHA)
	var content = """
		[bgcolor={bgcolor}]
			[b][TIMER_START][/b] {timer_name}
		[/bgcolor]""".strip_escapes().format(
		{
			"bgcolor": "#" + bg_color.to_html(Engine.is_embedded_in_editor()),
			"timer_name": timer_name,
		},
	)
	_output(CLogColors.TEXT_COLOR, content)
	return _timer_id


static func timer_end(id: int):
	if _timers.has(id):
		var start_time = float(_timers[id]["start_time"])
		var end_time = float(Time.get_ticks_usec())
		var elapsed = (end_time - start_time) / 1000.0
		var timer_name = _timers[id]["name"]

		var bg_color = _get_color(id, TIMER_BG_LIGHTNESS, TIMER_BG_ALPHA)
		var content = """
			[bgcolor={bgcolor}]
				[b][TIMER_END][/b] {timer_name}: {elapsed}
			[/bgcolor]
		""".strip_escapes().format(
			{
				"bgcolor": "#" + bg_color.to_html(Engine.is_embedded_in_editor()),
				"timer_name": " " + timer_name,
				"elapsed": "%.3f" % elapsed + "ms",
			},
		)
		_output(CLogColors.TEXT_COLOR, content)
		_timers.erase(id)
	else:
		e("Timer %s is not running or has already ended." % id)


static func timer_cancel(id: int):
	if _timers.has(id):
		var timer_name = _timers[id]["name"]
		_timers.erase(id)
		var bg_color = _get_color(id, TIMER_BG_LIGHTNESS, TIMER_BG_ALPHA)
		var content = """
			[bgcolor={bgcolor}]
				[b][TIMER_CANCELED][/b] {timer_name}
			[/bgcolor]""".strip_escapes().format(
			{
				"bgcolor": "#" + bg_color.to_html(Engine.is_embedded_in_editor()),
				"timer_name": " " + timer_name,
			},
		)
		_output(CLogColors.TEXT_COLOR, content)
	else:
		e("Timer %s is not running or has already ended." % id)


static func o(...args):
	_output(CLogColors.TEXT_COLOR, _join(args))


static func c(color: Color, ...args):
	_output(color, _join(args))


static func once(key: String, ...args):
	_output(CLogColors.TEXT_COLOR, _join(args), key)


static func _output(color: Color, message: String, key: String = ""):
	if !OS.is_debug_build() && disable_output_on_release_mode:
		return
	# var formatted_message = _format_message(message, _get_caller(3))
	var source_link = _get_source_link(_get_caller(3))

	if !key.is_empty():
		if _once_keys.has(key):
			return

	var formatted_message = """
			[color={line_color}]
				[{source_link}]
			[/color]
			[color={color}]
				{message}
			[/color]
		""".strip_escapes().format(
		{
			"line_color": "#" + CLogColors.SOURCE_LINK_COLOR.to_html(Engine.is_embedded_in_editor()),
			"source_link": source_link,
			"color": "#" + color.to_html(Engine.is_embedded_in_editor()),
			"message": " " + message,
		},
	)

	if _last_output == formatted_message:
		_schedule_flush(formatted_message)
	else:
		_flush(_last_output)
		print_rich(formatted_message)
		_last_output = formatted_message

	if !key.is_empty():
		_once_keys[key] = 0


static func _schedule_flush(message: String):
	if _scheduled_messages.has(message):
		_scheduled_messages[message] += 1
		return

	_scheduled_messages[message] = 0

	var main_loop = Engine.get_main_loop()
	if main_loop:
		await main_loop.process_frame

	_flush(message)


static func _flush(message: String):
	if _scheduled_messages.has(message):
		var count = _scheduled_messages[message] + 1
		print_rich(
			"[color={color}] └ (repeated {count}x)[/color]".format(
				{
					"color": "#" + CLogColors.DIMMED_COLOR.to_html(Engine.is_embedded_in_editor()),
					"count": count,
				},
			)
		)

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
		"./{file_path}:{line_number} @{function}()".format(
			{
				"file_path": file_path,
				"line_number": str(stacktrace_line["line"]),
				"function": stacktrace_line["function"],
			},
		)
	)

	var short_link = link.split("/")[-1]
	var formatted = link
	if Engine.is_embedded_in_editor():
		formatted = """
			[hint='{link}']
				[url={link}]
					/{short_link}
				[/url]
			[/hint]
		""".strip_escapes().format(
			{
				"link": link,
				"short_link": short_link,
			},
		)

	return formatted


static func _join(arr: Array):
	var r: Array[String] = []
	for e in arr:
		r.append(str(e))
	return " ".join(r)


static func _get_caller(backward_index: int) -> Dictionary:
	var current_stack = get_stack()
	if current_stack.size() <= backward_index:
		return { }

	return current_stack[backward_index]


static func _get_color(seed: int, lightness: float, alpha: float) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var h := rng.randf()
	var color := Color.from_ok_hsl(h, 1.0, lightness)
	color.a = alpha
	return color
