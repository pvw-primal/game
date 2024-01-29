class_name AirTile
extends Node3D

const POS_MULT : float = .3

var quadrant : int

func _ready():
	quadrant = 0
	get_child(0).animation_finished.connect(Play0)
	Play0()
	get_child(1).animation_finished.connect(Play1)
	Play1()
	get_child(2).animation_finished.connect(Play2)
	Play2()
	get_child(3).animation_finished.connect(Play3)
	Play3()
	get_child(4).animation_finished.connect(Play4)
	Play4()
	
func Play0():
	get_child(0).play("Wind" + str(randi_range(0, 4)))
	get_child(0).position = QuadrantPos()
	
func Play1():
	get_child(1).play("Wind" + str(randi_range(0, 4)))
	get_child(1).position = QuadrantPos()
	
func Play2():
	get_child(2).play("Wind" + str(randi_range(0, 4)))
	get_child(2).position = QuadrantPos()
	
func Play3():
	get_child(3).play("Wind" + str(randi_range(0, 4)))
	get_child(3).position = QuadrantPos()
	
func Play4():
	get_child(4).play("Wind" + str(randi_range(0, 4)))
	get_child(4).position = QuadrantPos()

func QuadrantPos() -> Vector3:
	if quadrant == 0:
		quadrant = 1
		return Vector3(randf_range(0, POS_MULT), randf_range(0, POS_MULT), randf_range(-POS_MULT, 0))
	elif quadrant == 1:
		quadrant = 2
		return Vector3(randf_range(0, -POS_MULT), randf_range(0, POS_MULT), randf_range(-POS_MULT, 0))
	elif quadrant == 2:
		quadrant = 3
		return Vector3(randf_range(0, POS_MULT), randf_range(0, -POS_MULT), randf_range(-POS_MULT, 0))
	else:
		quadrant = 0
		return Vector3(randf_range(0, -POS_MULT), randf_range(0, -POS_MULT), randf_range(-POS_MULT, 0))
