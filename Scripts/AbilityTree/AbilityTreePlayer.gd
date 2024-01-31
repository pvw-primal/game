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



func _ready():
	var s = load("res://Assets/Enemy/MortalPester/MortalPester.tscn")
	mesh = s.instantiate()
	add_child(mesh)
	animator = get_node("Mesh/AnimationTree")

func _process(delta):
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

