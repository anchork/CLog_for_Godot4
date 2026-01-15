extends Node2D

@onready var child_node = $Node
@onready var grandchild_node = $Node/Node
@onready var great_grandchild_node = $Node/Node/Node

func _ready() -> void:
	_test_output()
	_test_err()
	_test_c()
	_test_warn()
	_test_v()
	_test_timer()


func _test_output():
	CLog.o("test")
	
	CLog.o("node path jump 1:", child_node.get_path())
	CLog.o("node path jump 2:", grandchild_node.get_path())
	CLog.o("node path jump 3:", great_grandchild_node.get_path())
	CLog.o("node path jump 4:", child_node.get_path(), "node path jump 4")
	
	CLog.o("node path jump multiple:", child_node.get_path(), child_node.get_path(), child_node.get_path())
	CLog.o("node path jump broken:", str(child_node.get_path()) + str(child_node.get_path()))
	
	CLog.o("node id jump 1:", child_node)
	CLog.o("node id jump 2:", grandchild_node)
	CLog.o("node id jump 3:", great_grandchild_node)
	CLog.o("node id jump 4:", child_node, "node id jump 4")
	CLog.o("node id jump multiple:", child_node, child_node, child_node)
	CLog.o("node id jump broken:", str(child_node) + str(child_node))
	
	# spam same message.
	for i in range(100):
		CLog.o("test")


func _physics_process(_delta: float) -> void:
	CLog.once(StringName(get_path()), "once")


func _test_err():
	CLog.e("error message")
	CLog.e("error node_path jump", child_node.get_path())
	CLog.e("error node_id jump", grandchild_node)

func _test_c():
	CLog.c(Color.ROYAL_BLUE, "color print")
	CLog.c(Color.ORANGE, "color node_path jump", child_node.get_path())
	CLog.c(Color.CYAN, "color node_id jump", grandchild_node)

func _test_warn():
	CLog.w("waring")
	CLog.w("waring node_path jump", child_node.get_path())
	CLog.w("waring node_id jump", grandchild_node)
	
func _test_v():
	CLog.v("verbose")
	CLog.v("verbose node_path jump", child_node.get_path())
	CLog.v("verbose node_id jump", grandchild_node)


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
