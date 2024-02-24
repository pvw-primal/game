class_name StatsUI
extends Control

const BUFFED_COLOR : Color = Color.FOREST_GREEN
const DEBUFFED_COLOR : Color = Color.FIREBRICK

@onready var desc : RichTextLabel = get_node("Description")
@onready var border : NinePatchRect = get_node("Description/NinePatchRect")

var changed : bool = true

func _ready():
	desc.resized.connect(ChangeBorder)

func DisplayStats(entities : Array):
	if changed:
		desc.clear()
		var player : Player = entities[0]
		desc.append_text("\n\t" + player.Name + ":\n")
		
		var bonusCrit = 0 if player.equipped == -1 else player.GetItem(player.equipped).critChance
		desc.append_text(AppendStats(player.stats, player.originalStats, true, bonusCrit))
		
		for i in range(1, entities.size()):
			desc.append_text(AppendEntityStats(entities[i]))
			
		changed = false

func AppendStats(stats : Stats, originalStats : Stats, showCrit : bool = false, bonusCrit : float = 0) -> String:
	var statString = "[indent]" + LogText.WrapColor("[b][i][[/i][/b]HP: ", Color.SEA_GREEN) + "[b][i]" + str(stats.HP) + "Û" + str(stats.maxHP) + "[/i][/b]\n"
	statString += LogText.WrapColor("[b][i]ê[/i][/b]POW: ", Color.DARK_RED) + "[b][i]" + GetStatNum(stats.POW, originalStats.POW) + "[/i][/b]\t\t"
	statString += LogText.WrapColor("[b][i]y[/i][/b]MAG: ", Color.MEDIUM_PURPLE) + "[b][i]"  + GetStatNum(stats.MAG, originalStats.MAG) + "[/i][/b]\n"
	statString += LogText.WrapColor("[b][i]é[/i][/b]DEF: ", Color.STEEL_BLUE) + "[b][i]"  + GetStatNum(stats.DEF, originalStats.DEF) + "[/i][/b]\t\t"
	statString += LogText.WrapColor("[b][i]À[/i][/b]RES: ", Color.PALE_VIOLET_RED) + "[b][i]"  + GetStatNum(stats.RES, originalStats.RES) + "[/i][/b]\n"
	if showCrit:
		var crit : String = str((stats.CRIT + bonusCrit) * 100) + "%"
		if !is_equal_approx(stats.CRIT, originalStats.CRIT):
			crit = "[color=#" + BUFFED_COLOR.to_html() + "]" + str((stats.CRIT + bonusCrit) * 100) + "%[/color]" if stats.CRIT > originalStats.CRIT else "[color=#" + DEBUFFED_COLOR.to_html() + "]" + str((stats.CRIT + bonusCrit) * 100) + "%[/color]"
		statString += LogText.WrapColor("[b][i]œ[/i][/b]CRIT: ", Color.ORANGE_RED) + "[b][i]" + crit + "[/i][/b]\n"
	return statString + "[/indent]\n"

func AppendEntityStats(entity : Entity):
	return "\t" + entity.Name + ":\n" + AppendStats(entity.stats, entity.originalStats)

func GetStatNum(current : int, base : int):
	if current == base:
		return str(current)
	return "[color=#" + BUFFED_COLOR.to_html() + "]" + str(current) + "[/color]" if current > base else "[color=#" + DEBUFFED_COLOR.to_html() + "]" + str(current) + "[/color]"

func ChangeBorder():
	border.size = desc.size
