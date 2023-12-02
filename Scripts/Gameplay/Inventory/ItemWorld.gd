#class_name ItemWorld
#extends Sprite3D
#
#@onready var bundlesprite = load("res://Assets/Items/Bundle.png")
#
#var items : Array[Item]
#
#func init(i : Array[Item], pos : Vector3):
#	items = i
#	position = pos
#	texture = items[0].texture if items.size() < 2 && items[0].texture != null else bundlesprite
#
#func AddItem(i : Item):
#	items.append(i)
#	texture = bundlesprite

class_name ItemWorld
extends Node3D

@onready var itemMesh = preload("res://Assets/Items/Alchemy/HealingPotion.tscn")

var items : Array[Item]

func init(i : Array[Item], pos : Vector3):
	items = i
	position = pos
	for j in items:
		var im = j.mesh if j.mesh != null else itemMesh
		var item : Node3D = im.instantiate()
		var multiplier = items.size() if items.size() < 2 else 5
		item.position = Vector3(randf_range(-.1 * multiplier, .1 * multiplier), 0, randf_range(-.1 * multiplier, .1 * multiplier))
		add_child(item)
	
func AddItem(i : Item):
	items.append(i)
	var im = i.mesh if i.mesh != null else itemMesh
	var item : Node3D = im.instantiate()
	var multiplier = items.size() if items.size() < 2 else 5
	item.position = Vector3(randf_range(-.1 * multiplier, .1 * multiplier), 0, randf_range(-.1 * multiplier, .1 * multiplier))
	add_child(item)
