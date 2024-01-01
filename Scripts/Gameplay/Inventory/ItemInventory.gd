class_name ItemInventory
extends Node3D

var itemMesh

var item : Item
var mesh : Node3D

func init(pos : Vector3):
	itemMesh = load("res://Assets/Items/Drops/Chest.tscn")
	item = null
	mesh = null
	position = pos
		
func ChangeItem(i : Item, animate : bool = true):
	if item != null:
		mesh.queue_free()
	item = i
	var im = i.mesh if i.mesh != null else itemMesh
	mesh = im.instantiate()
	if item.topdown:
		mesh.rotation_degrees = Vector3(-35, randf_range(-1, 7), -92)
		mesh.position.y = .235
	else:
		mesh.rotation_degrees = Vector3(0, randf_range(-1, 7), randf_range(-1, 7))
		mesh.position.y = 0
	add_child(mesh)
	if animate:
		var anim : ItemAnimator = mesh.get_node("AnimationTree")
		anim.Drop()
		
func Remove():
	item = null
	mesh.queue_free()
	mesh = null
