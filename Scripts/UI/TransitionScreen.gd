class_name TransitionScreen
extends Sprite2D

@onready var transitiontext : Label = get_node("Label")
@onready var timer : Timer = get_node("Timer")

signal ScreenVisible
signal ScreenNotVisible

const WAIT_TIME : float = 1
const FADE_SPEED : float = 2

var shouldVisible = false
var fullyVisible = false

func _process(delta):
	if shouldVisible && !fullyVisible:
		modulate.a += delta * FADE_SPEED
		if modulate.a >= 1:
			ScreenVisible.emit()
			fullyVisible = true
	elif !shouldVisible && visible && modulate.a > 0:
		modulate.a -= delta * FADE_SPEED
		if modulate.a <= 0:
			visible = false
			ScreenNotVisible.emit()

func Wait(time : float):
	timer.one_shot = true
	timer.start(time)
	await timer.timeout
