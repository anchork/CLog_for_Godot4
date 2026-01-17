extends Node

@export var value: int = 0
@onready var scene1_child := $Scene1Child
@onready var scene1_grandchild := $Scene1Child/Scene1Grandchild


func _ready() -> void:
	CLog.c(Color.AQUA, "\n--- CHILD SCENE READY ---")
	CLog.c(Color.ANTIQUE_WHITE, "owner:", self.owner)
	CLog.c(Color.MEDIUM_AQUAMARINE, "1. Expect: Open test.tscn:", self.scene_file_path)
	CLog.o("<PATH>", self.get_path())
	CLog.o("<ID>", self)
	CLog.c(Color.ANTIQUE_WHITE, "2. Expect: Open scene1.tscn:", self.scene_file_path)
	CLog.o("<PATH>", scene1_child.get_path())
	CLog.o("<ID>", scene1_child)
	CLog.c(Color.ANTIQUE_WHITE, "3. Expect: Open scene1.tscn:", self.scene_file_path)
	CLog.o("<PATH>", scene1_grandchild.get_path())
	CLog.o("<ID>", scene1_grandchild)
