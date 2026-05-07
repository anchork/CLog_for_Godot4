extends Control

@onready var rich_text_label:RichTextLabel = $Panel/RichTextLabel
var _count:int = 0
func _ready() -> void:
	_test_output()
	_test_err()
	_test_c()
	_test_warn()
	_test_v()
	_test_timer()
	_test_inline_rich_text_label()
	_test_o_stack_offset()
	_test_c_stack_offset()
	_test_o_stack_offset_arr()
	_test_c_stack_offset_arr()


func _test_output() -> void:
	CLog.o("test")

	for i in range(100):
		CLog.o("spam message")


func _physics_process(_delta: float) -> void:
	CLog.once(StringName(get_path()), "once")
	if _count < 20:
		_count += 1
		CLog.o("output 20 times")


func _test_err() -> void:
	CLog.e("error message")


func _test_c() -> void:
	CLog.c(Color.ROYAL_BLUE, "color print")


func _test_warn() -> void:
	CLog.w("waring")


func _test_v() -> void:
	CLog.v("verbose")


func _test_timer() -> void:
	var timer1_id := CLog.timer_start("timer1")
	var timer2_id := CLog.timer_start("timer2")
	var timer3_id := CLog.timer_start("timer3")
	var timer4_id := CLog.timer_start("timer4")
	var timer5_id := CLog.timer_start("timer5")

	CLog.timer_cancel(timer5_id)
	CLog.timer_cancel(timer3_id)

	await get_tree().create_timer(1).timeout

	CLog.timer_end(timer5_id)
	CLog.timer_end(timer4_id)
	var timer6_id := CLog.timer_start("timer6")
	var timer7_id := CLog.timer_start("timer7")
	CLog.timer_end(timer3_id)
	var timer8_id := CLog.timer_start("timer8")
	CLog.timer_end(timer2_id)
	CLog.timer_end(timer1_id)

	CLog.timer_end(timer8_id)
	CLog.timer_end(timer7_id)
	CLog.timer_end(timer6_id)

	var timer9_id := CLog.timer_start("timer9")
	await get_tree().create_timer(0.1).timeout
	CLog.timer_end(timer9_id)
	CLog.timer_cancel(timer9_id)

func _test_inline_rich_text_label() -> void:
	rich_text_label.append_text(CLog.o("normal text"))
	rich_text_label.append_text(CLog.w("warning text"))
	rich_text_label.append_text(CLog.e("error text"))
	rich_text_label.append_text(CLog.v("verbose text"))

func _test_o_stack_offset() -> void:
	var wrapper1:Callable = (
		func(message:String) -> void:
			CLog.o_stack_offset(1, [message])
	)

	wrapper1.call("output: @_text_o_stack_offset")

	CLog.o_stack_offset(-1, ["output: @o_stack_offset()"])

	CLog.o_stack_offset(100, ["output: UNKNOWN CALLER"])
	
func _test_o_stack_offset_arr() -> void:
	var wrapper1:Callable = (
		func(message:String) -> void:
			CLog.o_stack_offset_arr(1, [message])
	)

	wrapper1.call("output: @_text_o_stack_offset_arr")

	CLog.o_stack_offset_arr(-1, ["output: @o_stack_offset_arr()"])
	CLog.o_stack_offset_arr(100, ["output: UNKNOWN CALLER"])
	
	
func _test_c_stack_offset() -> void:
	var wrapper1:Callable = (
		func(message:String) -> void:
			CLog.c_stack_offset(1, Color.CYAN, [message])
	)

	wrapper1.call("output: @_text_c_stack_offset")

	CLog.c_stack_offset(-1, Color.CYAN, ["output: @c_stack_offset()"])

	CLog.c_stack_offset(100, Color.CYAN, ["output: UNKNOWN CALLER"])
	
func _test_c_stack_offset_arr() -> void:
	var wrapper1:Callable = (
		func(message:String) -> void:
			CLog.c_stack_offset_arr(1, Color.CYAN, [message])
	)

	wrapper1.call("output: @_text_c_stack_offset_arr")

	CLog.c_stack_offset_arr(-1, Color.CYAN, ["output: @c_stack_offset_arr()"])

	CLog.c_stack_offset_arr(100, Color.CYAN, ["output: UNKNOWN CALLER"])
	
