extends Node2D

func _ready() -> void:
	_test_output()
	_test_err()
	_test_c()
	_test_warn()
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


func _test_timer():
	var timer1_id = CLog.timer_start("timer1")

	await get_tree().create_timer(2).timeout
	var timer2_id = CLog.timer_start("timer2")
	CLog.timer_end(timer1_id)

	await get_tree().create_timer(1).timeout
	CLog.timer_cancel(timer2_id)
	await get_tree().create_timer(1).timeout
	CLog.timer_end(timer2_id)
