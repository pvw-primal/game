class_name LogText
extends RichTextLabel

const FADE_SPEED : float = .5
const TEXT_FADEOUT : float = 7

var fade : bool = true
var countdown : float = 0
var showing : bool = false

func _ready():
	mouse_entered.connect(Focus)

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
		
func AddLine(line : String):
	Focus()
	append_text(line)
	
func Focus():
	modulate.a = 1
	fade = false
	countdown = TEXT_FADEOUT
	showing = true

static func GetDamageNum(damage : int, magic = false) -> String:
	return "[b][i][font_size=25]y" + str(damage) + "[/font_size][/i][/b]" if magic else "[b][i][font_size=25]ê" + str(damage) + "[/font_size][/i][/b]"
	
static func GetHealNum(healing : int) -> String:
	return "[b][i][font_size=25]" + str(healing) + "[/font_size][/i][/b]"
