class_name SkillUI
extends Sprite2D

@onready var skills : Array[SkillIconUI] = [get_node("CDBar2") as SkillIconUI, get_node("CDBar3") as SkillIconUI, get_node("CDBar4") as SkillIconUI, get_node("CDBar5") as SkillIconUI]
@onready var HPBar : ProgressBar = get_node("HPBar")
@onready var HPText : Label = get_node("HPBar/HPText")

var player : Player

func _ready():
	for i in range(skills.size()):
		if i >= player.moves.size():
			skills[i].UpdateCooldown(0, 1)
			continue
		if player.moves[i].icon != null:
			skills[i].icon.texture = player.moves[i].icon
	player.HPChange.connect(UpdateHP)
	UpdateHP(player.stats.HP, player.stats.maxHP)

func init():
	for i in range(skills.size()):
		if i >= player.moves.size():
			skills[i].UpdateCooldown(0, 1)
			continue
		if player.moves[i].icon != null:
			skills[i].icon.texture = player.moves[i].icon
	UpdateHP(player.stats.HP, player.stats.maxHP)

func UpdateAll():
	for i in range(skills.size()):
		if i >= player.moves.size():
			skills[i].UpdateCooldown(0, 1)
			continue
		skills[i].UpdateCooldown(player.cooldown[i], player.moves[i].cooldown)

func UpdateSkill(id : int, cooldown : int):
	skills[id].UpdateCooldown(cooldown, player.moves[id].cooldown)
	
func UpdateHP(currentHP : int, maxHP : int):
	HPBar.max_value = maxHP
	HPBar.value = currentHP
	HPText.text = str(currentHP) + "Û" + str(maxHP)
	
