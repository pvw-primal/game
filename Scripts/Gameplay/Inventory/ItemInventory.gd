class_name ItemInventory
extends Node3D

var itemMesh

var item : Item
var uses : int
var mesh : Node3D

func init(pos : Vector3):
	itemMesh = load("res://Assets/Items/Drops/Chest.tscn")
	item = null
	mesh = null
	position = pos
		
func ChangeItem(i : Item, animate : bool = true, u : int = -1):
	if i == null:
		Remove()
		return
	if item != null:
		mesh.queue_free()
	item = i
	if i.consumable && u == -2:
		uses = i.maxUses
	elif u > 0:
		uses = u
	var im = i.mesh if i.mesh != null else itemMesh
	mesh = im.instantiate()
	if item.topdown:
		mesh.rotation_degrees = Vector3(-35, randf_range(-1, 7), -92)
		mesh.position.y = i.invHeight
		mesh.rotation_degrees.z += item.invRotation
	else:
		mesh.rotation_degrees = Vector3(0, randf_range(-1, 7), randf_range(-1, 7))
		mesh.position.y = i.invHeight
	add_child(mesh)
	if animate:
		var anim : ItemAnimator = mesh.get_node("AnimationTree")
		anim.Drop()
		
func Remove():
	item = null
	if mesh != null:
		mesh.queue_free()
		mesh = null
	uses = -1
