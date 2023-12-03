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
		item.rotation.y = randi_range(0, 360)
		add_child(item)
		var anim : ItemAnimator = item.get_node("AnimationTree")
		anim.Drop()
	
func AddItem(i : Item):
	items.append(i)
	var im = i.mesh if i.mesh != null else itemMesh
	var item : Node3D = im.instantiate()
	var multiplier = items.size() if items.size() < 2 else 5
	item.position = Vector3(randf_range(-.1 * multiplier, .1 * multiplier), 0, randf_range(-.1 * multiplier, .1 * multiplier))
	item.rotation.y = randi_range(0, 360)
	add_child(item)
	var anim : ItemAnimator = item.get_node("AnimationTree")
	anim.Drop()
	
func PopItem() -> Item:
	get_child(items.size() - 1).queue_free()
	return items.pop_back()
