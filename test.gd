extends Node2D

func _ready() -> void:
	_test_output()
	_test_err()
	_test_c()
	_test_warn()
	_test_v()
	_test_timer()


func _test_output():
	CLog.o("test")

	# spam same message.
	for i in range(100):
		CLog.o("test")


func _physics_process(_delta: float) -> void:
	CLog.once(StringName(get_path()), "once")


func _test_err():
	CLog.e("error message")


func _test_c():
	CLog.c(Color.ROYAL_BLUE, "color print")


func _test_warn():
	CLog.w("waring")
	
func _test_v():
	CLog.v("verbose")


func _test_timer():
	var timer1_id = CLog.timer_start("timer1")
	var timer2_id = CLog.timer_start("timer2")
	var timer3_id = CLog.timer_start("timer3")
	var timer4_id = CLog.timer_start("timer4")
	var timer5_id = CLog.timer_start("timer5")

	CLog.timer_cancel(timer5_id)
	CLog.timer_cancel(timer3_id)

	await get_tree().create_timer(1).timeout

	CLog.timer_end(timer5_id)
	CLog.timer_end(timer4_id)
	var timer6_id = CLog.timer_start("timer6")
	var timer7_id = CLog.timer_start("timer7")
	CLog.timer_end(timer3_id)
	var timer8_id = CLog.timer_start("timer8")
	CLog.timer_end(timer2_id)
	CLog.timer_end(timer1_id)

	CLog.timer_end(timer8_id)
	CLog.timer_end(timer7_id)
	CLog.timer_end(timer6_id)

	var timer9_id = CLog.timer_start("timer9")
	await get_tree().create_timer(0.1).timeout
	CLog.timer_end(timer9_id)
	CLog.timer_cancel(timer9_id)
