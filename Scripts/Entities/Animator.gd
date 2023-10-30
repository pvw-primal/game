class_name Animator
extends AnimationTree

func Attack():
	set("parameters/AttackOS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Damage():
	set("parameters/DamagedOS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func Walk(state: bool):
	if state:
		set("parameters/BIW/blend_amount", 1.0)
	else:
		set("parameters/BIW/blend_amount", 0)
