class_name CLog

enum LogType { NORMAL, TEMP, BACKGROUND }

const MOUSE_EMOJI = "🐹"
const TEMP_EMOJI = "🚮"

# Core logging methods
static func stack(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	var currentStack = get_stack();
	var buf = _join([v1,v2,v3,v4,v5,v6,v7,v8]) + "\n";
	for i in range(2, currentStack.size()):
		var info = currentStack[i];
		buf += "".join([
			"⛏️ [./",
			info["source"].trim_prefix("res://"),
			":",
			info["line"],
			" ",
			info["function"],
			"()]\n"
		]);
	buf = buf.trim_suffix("\n");
	output("red", "" + buf, "🖥️");

static func e(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("pink", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), "❌")
	if OS.is_debug_build():
		assert(false, "")

static func err(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	var currentStack = get_stack();
	var buf = "[color=white][bgcolor=brown][b]" + _join([v1,v2,v3,v4,v5,v6,v7,v8]) + "[/b][/bgcolor][/color]\n";
	for i in range(2, currentStack.size()):
		var info = currentStack[i];
		buf += "".join([
			"⛏️ [./",
			info["source"].trim_prefix("res://"),
			":",
			info["line"],
			" ",
			info["function"],
			"()]\n"
		]);
	buf = buf.trim_suffix("\n");
	output("red", "" + buf, "🖥️");
	if OS.is_debug_build():
		assert(false, "")

static func warn(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("yellow", "\n" + "⚠️⚠️⚠️⚠️⚠️⚠️ WARNING ⚠️⚠️⚠️⚠️⚠️⚠️" + "\n" + _join([v1,v2,v3,v4,v5,v6,v7,v8]) + "\n======================", "💊")

static func w(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("yellow", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), "⚠️")

static func strong(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("orange", "\n" + "🎆🎆🎆🎆🎆🎆🎆🎆🎆🎆" + "\n" + _join([v1,v2,v3,v4,v5,v6,v7,v8]) + "\n======================", "🎈")

static func o(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("white", _join([v1,v2,v3,v4,v5,v6,v7,v8]), "🐹");

static func temp(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("orange", _join([v1,v2,v3,v4,v5,v6,v7,v8]), "🚮");

static var _timers:Dictionary = {}
static var _timer_id:int = 0;

static func timerStart(name:String) -> int:
	_timer_id += 1;
	_timers[_timer_id] = {
		"name": name,
		"start_time": Time.get_ticks_usec()
	}
	var color = getPair(str(_timer_id))
	outputWithBg(toHex(color["light"]), toHex(color["dark"]), _join([str(_timer_id) + ":", "Timer Started: ", name]), "🕒")
	return _timer_id;

static func timerEnd(id:int, warningTime:int = 1000):
	if _timers.has(id):
		var start_time = _timers[id]["start_time"]
		var end_time = Time.get_ticks_usec()
		var elapsed = float(end_time - start_time) / 1000.0
		var message = "";
		if elapsed > warningTime:
			message =  "Timer Ended: [%s]: [color=black][bgcolor=red][b]%.3f ms[/b][/bgcolor][/color]" % [_timers[id]["name"], elapsed];
		else:
			message = "Timer Ended: [%s]: %.3f ms" % [_timers[id]["name"], elapsed];

		var color = getPair(str(id))
		outputWithBg(toHex(color["light"]), toHex(color["dark"]), _join([str(id) + ":", message]), "🕒")
		_timers.erase(id)
	else:
		outputWithBg("red", "white", str(id) + ": Timer [%s]: Not started" % str(id), "🕒")


static func timerCancel(id:int):
	if _timers.has(id):
		var timerName = _timers[id]["name"]
		_timers.erase(id)
		var color = getPair(str(id))
		outputWithBg(toHex(color["light"]), toHex(color["dark"]), _join(["timer canceled: ", timerName]), "❌")
	else:
		outputWithBg("red", "white", _join(["timer canceled: ", str(id)]), "❌")


# Convenient shorthand methods for backward compatibility
static func red(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("red", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func blue(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("light_blue", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func green(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("light_green", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func pink(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("pink", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func cyan(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("cyan", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func magenta(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("magenta", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func yellow(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("yellow", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func gray(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("gray", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func orange(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("orange", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func brown(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("brown", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func tempRed(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("red", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempBlue(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("light_blue", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempGreen(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("light_green", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempPink(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("pink", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempCyan(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("cyan", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempMagenta(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("magenta", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempYellow(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("yellow", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempGray(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("gray", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempOrange(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("orange", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)
static func tempBrown(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	output("brown", _join([v1,v2,v3,v4,v5,v6,v7,v8]), TEMP_EMOJI)

static func redBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("red", "white", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func blueBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("blue", "white", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func greenBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("light_green", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func pinkBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("pink", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func cyanBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("cyan", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func magentaBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("magenta", "white", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func yellowBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("yellow", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func grayBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("gray", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func orangeBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("orange", "black", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)
static func brownBg(v1=null, v2=null, v3=null, v4=null, v5=null, v6=null, v7=null, v8=null):
	outputWithBg("brown", "white", _join([v1,v2,v3,v4,v5,v6,v7,v8]), MOUSE_EMOJI)

static func outputNoInfo(color:String, message:String, prefix:String = ""):
	if OS.is_debug_build():
		print_rich(prefix + " [color=" + color + "]" + message + "[/color]");

static func outputNoInfoBg(bgColor:String, color:String, message:String, prefix:String=""):
	if OS.is_debug_build():
		print_rich(prefix + " [bgcolor=" + bgColor + "][color=" + color + "][b]" + message + "[/b][/color][/bgcolor]");

static func output(color:String, message:String, emoji:String):
	if OS.is_debug_build():
		print_rich(emoji + _getCaller() + " [color=" + color + "]" + message + "[/color]");

static func outputWithBg(bgColor:String, color:String, message:String, emoji:String):
	if OS.is_debug_build():
		print_rich(emoji + _getCaller() + " [bgcolor=" + bgColor + "][color=" + color + "][b]" + message + "[/b][/color][/bgcolor]");

static func _join(arr):
	var r: Array[String] = [];
	# Handle both Array and variadic arguments
	if arr is Array:
		for e in arr:
			if e != null:
				r.append(str(e))
	else:
		if arr != null:
			r.append(str(arr))
	return " ".join(r)

static func _getCaller() -> String:
	var currentStack = get_stack();
	var info:Dictionary;
	if currentStack.size() < 3:
		return "";

	info = currentStack[3];

	# { "source": "res://scenes/view/view.gd", "function": "enter", "line": 38 }
	var fullPath = ProjectSettings.globalize_path(info["source"]);
	var projectPath = ProjectSettings.globalize_path("res://");
	return (
		"["
		# + "file://"
		+ "./" + fullPath.trim_prefix(projectPath)
		+ ":"
		+ str(info["line"])
		+ " "
		+ info["function"]
		+ "()]"
	);

static func getLight(string:String) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = string.hash()

	var r = rng.randf_range(0.6, 1.0)
	var g = rng.randf_range(0.6, 1.0)
	var b = rng.randf_range(0.6, 1.0)

	return Color(r, g, b, 1.0)

static func getDark(string:String) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = string.hash()

	var r = rng.randf_range(0.0, 0.4)
	var g = rng.randf_range(0.0, 0.4)
	var b = rng.randf_range(0.0, 0.4)

	return Color(r, g, b, 1.0)

static func getPair(string:String) -> Dictionary:
	return {
		"light": getLight(string),
		"dark": getDark(string)
	}

static func toHex(color:Color) -> String:
	return "#%02x%02x%02x" % [color.r8, color.g8, color.b8]
