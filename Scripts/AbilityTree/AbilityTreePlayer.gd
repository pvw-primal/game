class_name AbilityTreePlayer
extends Node3D

var speed : float = 0
const SPEED_U : float = .4
const SPEED_D : float = .2
const MAX_SPEED : float = 3.5
var targetPos : Vector3 = position
var moving : bool = false

var mesh : Node3D
var animator : Animator

@onready var map : TreeGridMap = get_node("/root/root/GridMap")

func init():
	if Global.playerMesh == null:
		var s = preload("res://Assets/Enemy/Cinch/Cinch.tscn")
		mesh = s.instantiate()
		add_child(mesh)
		SetColor(Color.MEDIUM_PURPLE, Color.REBECCA_PURPLE, Color.REBECCA_PURPLE)
	else:
		mesh = Global.playerMesh
		mesh.name = "Mesh"
		add_child(mesh)
	animator = get_node("Mesh/AnimationTree")
	mesh.rotation_degrees.y = 90

func _process(delta):
	if targetPos.x > map.limitsX.y || targetPos.x < map.limitsX.x || targetPos.z > map.limitsY.y || targetPos.z < map.limitsY.x:
		targetPos = position
		animator.Walk(false)
		moving = false
		speed = 0
	else:
		position = position.lerp(targetPos, speed * delta / 2)
		position = position.move_toward(targetPos, speed * delta / 1.5)
	
	if moving:
		if speed < MAX_SPEED:
			speed += SPEED_U
		if targetPos == position:
			animator.Walk(false)
			moving = false
	elif speed > 0:
		speed -= SPEED_D
	var dir : Vector3 = Vector3(0, 1, 0)
	if Input.is_action_pressed("MoveUpLeft") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveLeft")):
		dir = Vector3(1, 0,  1)
	elif Input.is_action_pressed("MoveUpRight") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveRight")):
		dir = Vector3(-1, 0,  1)
	elif Input.is_action_pressed("MoveDownLeft") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveLeft")):
		dir = Vector3(1, 0, -1)
	elif Input.is_action_pressed("MoveDownRight") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveRight")):
		dir = Vector3(-1, 0, -1)
	elif Input.is_action_pressed("MoveUp"):
		dir = Vector3(0, 0, 1)
	elif Input.is_action_pressed("MoveLeft"):
		dir = Vector3(1, 0, 0)
	elif Input.is_action_pressed("MoveDown"):
		dir = Vector3(0, 0, -1)
	elif Input.is_action_pressed("MoveRight"):
		dir = Vector3(-1, 0, 0)
	if dir.y < 1:
		moving = true
		animator.Walk(true)
		targetPos = position + (dir * .5)
		Rotate(targetPos)
		
func Rotate(pos : Vector3):
	mesh.rotation.y = (Vector2(pos.x, position.z) - Vector2(position.x, pos.z)).angle()

func SetColor(cR : Color, cG : Color, cB: Color):
	for child in mesh.get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		child.set_instance_shader_parameter("replaceR", cR)
		child.set_instance_shader_parameter("replaceG", cG)
		child.set_instance_shader_parameter("replaceB", cB)
		
func SetSize(s : float = randf_range(.8, 1.2)):
	mesh.scale = Vector3(s, s, s)
