class_name MovesUI
extends Control

@onready var description : RichTextLabel = get_node("Description")
@onready var border : NinePatchRect = get_node("Description/NinePatchRect")

var wrote : bool = false

func _ready():
	description.resized.connect(ChangeBorder)

func DisplayMoves(p : Player):
	if wrote:
		return
	var desc : String = "[indent]"
	for i in range(p.moves.size()):
		desc += "\n[img=64x64]" + p.moves[i].icon.resource_path + "[/img] " + p.moves[i].name + " -\n[indent]" + p.moves[i].description + "[/indent]"
	for i in range(p.classE.passives.size()):
		if p.classE.passives[i].internal:
			continue
		desc += "\n[b][i][font_size=25]m[/font_size][/i][/b] " + p.classE.passives[i].name + " (Passive) -\n[indent]" + p.classE.passives[i].description + "[/indent]"
	description.text = desc + "\n [/indent] "
	wrote = true
	
func ChangeBorder():
	border.size = description.size
