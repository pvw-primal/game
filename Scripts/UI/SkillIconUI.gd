class_name SkillIconUI
extends ProgressBar

@onready var text : Label = get_node("CD")
@onready var icon : Sprite2D = get_node("SkillIcon")

func UpdateCooldown(cooldown : int, maxcooldown : int):
	if cooldown == 0:
		text.visible = false
	else:
		text.visible = true
		text.text = str(cooldown)
	max_value = maxcooldown
	value = cooldown
