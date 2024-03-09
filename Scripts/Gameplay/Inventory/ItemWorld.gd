class_name ItemWorld
extends Node3D

static var itemMesh = preload("res://Assets/Items/Drops/Chest.tscn")

var items : Array[Item]
var useMeta : Dictionary

func init(i : Item, pos : Vector3, uses : int = -1):
	items = []
	position = pos
	AddItem(i, uses)
			
func AddItem(i : Item, uses : int = -1):
	items.append(i)
	if i.consumable && uses == -2:
		if i.maxUses > 1:
			useMeta[items.size() - 1] = i.maxUses
	elif uses > 0:
		useMeta[items.size() - 1] = uses
	var im = i.mesh if i.mesh != null else itemMesh
	var item : Node3D = im.instantiate()
	var multiplier = items.size() if items.size() < 2 else 5
	item.position = Vector3(randf_range(-.1 * multiplier, .1 * multiplier), 0, randf_range(-.1 * multiplier, .1 * multiplier))
	item.rotation.y = randf_range(0, 2 * PI)
	add_child(item)
	var anim : ItemAnimator = item.get_node("AnimationTree")
	anim.Drop()
	
func PopItem() -> Item:
	get_child(items.size() - 1).queue_free()
	return items.pop_back()

func PopUseMeta() -> int:
	var uses = useMeta[items.size() - 1] if items.size() - 1 in useMeta else -1
	useMeta.erase(items.size() - 1)
	return uses
