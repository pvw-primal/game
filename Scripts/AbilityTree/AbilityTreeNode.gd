class_name AbilityTreeNode
extends Node3D

@onready var sprite : Sprite3D = get_node("Sprite3D")

var from : Array[AbilityTreeNode]
var to : Array[AbilityTreeNode]

var data : AbilityTreeData

func _ready():
	if data != null:
		sprite.texture = data.icon

func _init(d : AbilityTreeData = AbilityTreeData.new()):
	from = []
	to = []
	data = d
