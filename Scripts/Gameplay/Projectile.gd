class_name Projectile
extends Node3D

var targetPos : Vector3
var speed : float
var moving : bool

var move : Move
var atk : Entity
var def : Entity

func init(attacker : Entity, destination : Vector3, Speed : float, mesh : PackedScene, m : Move = null, defender : Entity = null):
	var model = mesh.instantiate()
	add_child(model)
	position = Vector3(attacker.position.x, position.y, attacker.position.z)
	rotation.y = attacker.mesh.rotation.y - (3 * PI / 4)
	targetPos = destination
	speed = Speed
	moving = true
	move = m
	atk = attacker
	def = defender
	
func _process(delta):
	if moving:
		position = position.lerp(targetPos, delta * speed / 2)
		position = position.move_toward(targetPos, delta * speed / 2)
		if position.is_equal_approx(targetPos):
			moving = false
			Complete()

func Complete():
	visible = false
	if move != null:
		await move.Use(atk, def)
		await atk.Wait(.65)
	atk.endTurn.emit()
	queue_free()
	
