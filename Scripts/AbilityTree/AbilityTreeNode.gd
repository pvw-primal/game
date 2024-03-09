class_name AbilityTreeNode
extends Node3D

static var itemMesh = preload("res://Assets/Items/Drops/Chest.tscn")
@onready var sprite : Sprite3D = get_node("Sprite3D")
@onready var sphere : MeshInstance3D = get_node("MeshInstance3D")

var from : Array[AbilityTreeNode]
var to : Array[AbilityTreeNode]

var data : AbilityTreeData

func _ready():
	if data != null:
		if data.icon != null:
			sprite.texture = data.icon
			sphere.visible = false
		elif data.color != Color.BLACK:
			sphere.visible = true
			sphere.set_instance_shader_parameter("color", data.color)
		else:
			sphere.visible = false
			var im = data.item if data.item != null else itemMesh
			var item : Node3D = im.instantiate()
			item.rotation_degrees.y = -90.0 if data.item == null else randf_range(0, 360)
			add_child(item)
			var anim : ItemAnimator = item.get_node("AnimationTree")
			anim.Drop()
			

func _init(d : AbilityTreeData = AbilityTreeData.new()):
	from = []
	to = []
	data = d
