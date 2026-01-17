extends Node

@onready var child_node := $Node
@onready var grandchild_node := $Node/Node
@onready var empty_node := $EmptyNode
@onready var nest_scene1 := $Scene1
@onready var nest_scene2 := $Scene1/Scene2


func _ready() -> void:
	_test_node_link()


func _test_node_link() -> void:
	CLog.o("=== STARTED CLog Link Tests ===")

	# --- Setup ---
	var node := Node.new()
	node.name = "ScriptNode"
	empty_node.add_child(node)

	var test_scene: PackedScene = preload("res://test_scenes/scene1/scene1.tscn")
	var inst_scene: Node = test_scene.instantiate()
	inst_scene.name = "ScriptScene"
	empty_node.add_child(inst_scene)

	var outside_node: Node = test_scene.instantiate()

	# --- Tests ---

	CLog.c(Color.POWDER_BLUE, "--- DYNAMICALLY ADDED NODES ---")

	CLog.c(Color.WHITE, "1. Instantiate & Add Child (Scene Root)")
	CLog.o("Expect: Open 'scene1.tscn'", inst_scene)
	CLog.o("Expect: Open 'scene1.tscn'", inst_scene.get_path())

	CLog.c(Color.WHITE, "2. Child of Instantiated Scene")
	var inst_child := inst_scene.get_node(^"Scene1Child")
	CLog.o("Expect: Open 'scene1.tscn' -> Focus 'Scene1Child'", inst_child)
	CLog.o("Expect: Open 'scene1.tscn' -> Focus 'Scene1Child'", inst_child.get_path())

	CLog.c(Color.WHITE, "3. Plain Node added by Script")
	CLog.o("Expect: Focus 'EmptyNode/ScriptNode' in CURRENT scene", node)
	CLog.o("Expect: Focus 'EmptyNode/ScriptNode' in CURRENT scene", node.get_path())

	CLog.c(Color.POWDER_BLUE, "\n--- EXISTING NODES (IN SCENE) ---")

	CLog.c(Color.WHITE, "4. Self (Root)")
	CLog.o("Expect: Focus 'Test' in current scene", self)
	CLog.o("Expect: Focus 'Test' in current scene", self.get_path())

	CLog.c(Color.WHITE, "5. Child Node")
	CLog.o("Expect: Focus 'Node'", child_node)
	CLog.o("Expect: Focus 'Node'", child_node.get_path())

	CLog.c(Color.WHITE, "6. Nested Scene Root")
	CLog.o("Expect: Focus 'Scene1' in current scene", nest_scene1)
	CLog.o("Expect: Focus 'Scene1' in current scene", nest_scene1.get_path())

	CLog.c(Color.WHITE, "7. Nested Scene Child (Internal)")
	CLog.o(
		"Expect: Open 'scene1.tscn' -> Focus 'Scene1Child'",
		nest_scene2.get_node(^"Scene1Child"),
	)
	CLog.o(
		"Expect: Open 'scene1.tscn' -> Focus 'Scene1Child'",
		nest_scene2.get_node(^"Scene1Child").get_path(),
	)

	CLog.c(Color.SALMON, "\n--- EDGE CASES ---")

	CLog.c(Color.WHITE, "8. Node Outside Tree")
	CLog.o("Expect: No link or Warning", outside_node)
	CLog.o("Expect: No link or Warning", outside_node.get_path())

	CLog.c(Color.WHITE, "9. Multiple Objects")
	CLog.o("Multiple Args:", child_node, grandchild_node)
	CLog.o("Multiple Args:", child_node.get_path(), grandchild_node.get_path())

	# Cleanup
	outside_node.queue_free()
