class_name StatusUI
extends Sprite3D

const SHOW_TIME : float = 1
var time : float = 0

var current = 0
var icons : Array[Texture2D] = []

func _process(delta):
	if time > 0:
		time -= delta
	else:
		current = current + 1 if current + 1 < icons.size() else 0
		texture = icons[current]
		time = SHOW_TIME
		
func Disable():
	texture = null
	time = SHOW_TIME
	set_process(false)
	
func Enable():
	texture = icons[0]
	set_process(true)
