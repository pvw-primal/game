class_name ItemAnimator
extends AnimationTree

func Drop():
	set("parameters/DropOS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
