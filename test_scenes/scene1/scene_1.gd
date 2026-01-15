extends Node

@export var value:int = 0
@onready var scene1_child = $Scene1Child
@onready var scene1_grandchild = $Scene1Child/Scene1Child2
func _ready() -> void:
	CLog.o("self node_path jump", self.name, self.get_path())
	CLog.o("self node_id jump", self.name, self)
	CLog.o("child scene node_path jump", self.name, scene1_child.get_path())
	CLog.o("child scene node_id jump", self.name, scene1_grandchild)
