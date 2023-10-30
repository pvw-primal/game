class_name TextScroll
extends ScrollContainer

const FADE_SPEED : float = .5
const TEXT_FADEOUT : float = 7

var maxLength = 0
var fade : bool = true
var countdown : float = 0
var showing : bool = false

@onready var scroll = get_v_scroll_bar()
@onready var label : Label = get_node("Label")

func _ready():
	scroll.changed.connect(Changed)
	mouse_entered.connect(Focus)
	maxLength = scroll.max_value

func _process(delta):
	if showing && fade:
		modulate.a -= FADE_SPEED * delta
		if modulate.a <= 0:
			showing = false
	
	if countdown > 0:
		countdown -= delta
	elif !fade:
		countdown = 0
		fade = true
	
func Changed():
	if maxLength != scroll.max_value:
		maxLength = scroll.max_value
		scroll_vertical = maxLength
		
func AddLine(line : String):
	Focus()
	label.text += "  " + line
	
func Focus():
	modulate.a = 1
	fade = false
	countdown = TEXT_FADEOUT
	showing = true
