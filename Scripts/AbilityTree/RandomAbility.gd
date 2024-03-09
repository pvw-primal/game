class_name RandomAbility
extends Resource

enum Stat { HP, POW, MAG, DEF, RES }
enum Colors { Red, Green, Blue }

static var canDetectItem : bool = false
static var canDetectExit : bool = false

static func Get(num : int) -> Array[AbilityTreeData]:
	var abilities : Array[AbilityTreeData] = [ColorStatBuff(Colors.Red), ColorStatBuff(Colors.Green), ColorStatBuff(Colors.Blue)]
	abilities += [LargeSizeStatBuff(), LargeSizeStatBuff(), SmallSizeStatBuff(), SmallSizeStatBuff()]
	abilities += [CritBuff(), Limber(), HardLevel()]
	abilities += [NewEquipment(Items.Rarity.Common), NewEquipment(Items.Rarity.Common), NewEquipment(Items.Rarity.Uncommon), NewEquipment(Items.Rarity.Rare)]
	abilities += [NewItem("Healing Potion"), NewItem("Imbued Wilds"), NewItem("Whetstone Oil"), NewItem("Javelin"), NewItem("Tunneling Tools"), NewItem("Bandage")]
	
	if !canDetectItem:
		abilities += [ItemDetector(), ItemDetector()]
	if !canDetectExit:
		abilities += [ExitDetector(), ExitDetector()]
		
	if Global.options < 5:
		abilities += [MoreOptions(), MoreOptions()]
	else:
		abilities += [LessOptions(), LessOptions()]
	if Global.options > 1:
		abilities += [LessOptions(), LessOptions()]
	else:
		abilities += [MoreOptions(), MoreOptions(), NewEquipment(Items.Rarity.Mythic)]
		
	var a : Array[AbilityTreeData] = []
	for i in range(num):
		var abt : AbilityTreeData = abilities[randi_range(0, abilities.size() - 1)]
		abilities.erase(abt)
		a.append(abt)
	return a
	
static func StatWrap(stat : Stat) -> String:
	match stat:
		Stat.HP: return LogText.WrapColor("[b][i][[/i][/b]HP", Color.SEA_GREEN)
		Stat.POW: return LogText.WrapColor("[b][i]ê[/i][/b]POW", Color.DARK_RED)
		Stat.MAG: return LogText.WrapColor("[b][i]y[/i][/b]MAG", Color.MEDIUM_PURPLE)
		Stat.DEF: return LogText.WrapColor("[b][i]é[/i][/b]DEF", Color.STEEL_BLUE)
		Stat.RES: return LogText.WrapColor("[b][i]À[/i][/b]RES", Color.PALE_VIOLET_RED)
		_: return ""

static func ColorStatBuff(color : Colors = Colors[Colors.keys()[randi_range(0, Colors.size() - 1)]], stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]) -> AbilityTreeData:
	var colors : Array[Color]
	for child in Global.playerMesh.get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		colors = [
			child.get_instance_shader_parameter("replaceR"),
			child.get_instance_shader_parameter("replaceG"),
			child.get_instance_shader_parameter("replaceB")
		]
		break
	
	var name : String
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Become "
	var buff : float
	var c : Color
	match color:
		Colors.Red: 
			name = "Better and Redder"
			buff = 1.5 + colors[0].r + colors[1].r + colors[2].r - colors[0].g - colors[1].g - colors[2].g - colors[0].b - colors[1].b - colors[2].b
			c = Color.FIREBRICK
			desc += LogText.WrapColor("redder", c) + ". \n"
			for i in range(colors.size()):
				colors[i].r += .2
				colors[i].g -= .2
				colors[i].b -= .2
		Colors.Green: 
			name = "Meaner and Greener"
			buff = 1.5 + colors[0].g + colors[1].g + colors[2].g - colors[0].r - colors[1].r - colors[2].r - colors[0].b - colors[1].b - colors[2].b
			c = Color.GREEN
			desc += LogText.WrapColor("greener", c) + ". \n"
			for i in range(colors.size()):
				colors[i].g += .2
				colors[i].r -= .2
				colors[i].b -= .2
		Colors.Blue: 
			name = "Newer and Bluer"
			buff = 1.5 + colors[0].b + colors[1].b + colors[2].b - colors[0].g - colors[1].g - colors[2].g - colors[0].r - colors[1].r - colors[2].r
			c = Color.ROYAL_BLUE
			desc += LogText.WrapColor("bluer", c) + ". \n"
			for i in range(colors.size()):
				colors[i].b += .2
				colors[i].g -= .2
				colors[i].r -= .2
			
	var realBuff : int
	if stat == Stat.HP:
		realBuff = clamp(buff * 3, 2, 9)
		desc += "Gain (2 - 9) " + StatWrap(stat) + " based on how " + LogText.WrapColor(Colors.keys()[color].to_lower(), c) + " you are.\n"
	else:
		realBuff = clamp(buff, 1, 3)
		desc += "Gain (1 - 3) " + StatWrap(stat) + " based on how " + LogText.WrapColor(Colors.keys()[color].to_lower(), c) + " you are.\n"
	desc += "Current " + LogText.WrapColor(Colors.keys()[color].to_lower() + "ness: ", c) + str(realBuff) + ".[/indent]" 
	var ATD : AbilityTreeData = AbilityTreeData.new(name + ": " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += realBuff
			Stat.MAG: e.originalStats.MAG += realBuff
			Stat.DEF: e.originalStats.DEF += realBuff
			Stat.RES: e.originalStats.RES += realBuff
			Stat.HP: 
				e.originalStats.HP += realBuff
				e.originalStats.maxHP += realBuff
		tp.SetColor(colors[0], colors[1], colors[2])
		e.SetColor(colors[0], colors[1], colors[2])
	ATD.color = c
	ATD.SetDifficulty(randi_range(2, 3))
	return ATD

static func LargeSizeStatBuff(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var scale : float = Global.playerMesh.scale.x
	var buff : int = clamp(scale * 6, 2, 9) if stat == Stat.HP else clamp(scale * 2, 1, 3)
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Become [font_size=90]LARGER.[/font_size]"
	desc += "\nGain (2 - 9) " if stat == Stat.HP else "\nGain (1 - 3) "
	desc += StatWrap(stat) + " based on how large you are.\nCurrent largeness: " + str(buff) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Bigger and Better: " + StatWrap(stat), desc)
	scale = clamp(scale + .25, .5, 1.5)
	ATD.OnLevelStart = func(e : Player, tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		e.mesh.scale = Vector3(scale, scale, scale)
		tp.mesh.scale = Vector3(scale, scale, scale)
	ATD.color = Color.GOLDENROD
	ATD.SetDifficulty(randi_range(3, 4))
	return ATD
	
static func SmallSizeStatBuff(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var scale : float = Global.playerMesh.scale.x
	var buff : int = clamp((2 - scale) * 6, 2, 9) if stat == Stat.HP else clamp((2 - scale) * 2, 1, 3)
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Become [font_size=25]smaller.[/font_size]"
	desc += "\nGain (2 - 9) " if stat == Stat.HP else "\nGain (1 - 3) "
	desc += StatWrap(stat) + " based on how small you are.\nCurrent teenyness: " + str(buff) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Fun-sized: " + StatWrap(stat), desc)
	scale = clamp(scale - .25, .5, 1.5)
	ATD.OnLevelStart = func(e : Player, tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		e.mesh.scale = Vector3(scale, scale, scale)
		tp.mesh.scale = Vector3(scale, scale, scale)
	ATD.color = Color.INDIAN_RED
	ATD.SetDifficulty(randi_range(3, 4))
	return ATD
	
static func MoreOptions(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var buff : int = 3 if stat == Stat.HP else 1
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Gain 1 additional option whenever you select a new skill.\n"
	desc += "Gain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Branching Paths: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		Global.options += 1
	ATD.color = Color.DARK_SLATE_GRAY
	ATD.SetDifficulty(randi_range(3, 4))
	return ATD
	
static func LessOptions(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var buff : int = 6 if stat == Stat.HP else 2
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Get 1 less option whenever you select a new skill.\n"
	desc += "Gain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Myopic Bargain: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		Global.options -= 1
	ATD.color = Color.DARK_OLIVE_GREEN
	ATD.SetDifficulty(2)
	return ATD

static func NewEquipment(rarity : Items.Rarity = Items.Rarity[Items.Rarity.keys()[randi_range(0, Items.Rarity.size() - 1)]], focus : bool = randi_range(0, 1), stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var buff : int = 3 if stat == Stat.HP else 1
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Get a random " + LogText.WrapColor(Items.Rarity.keys()[rarity].to_lower(), Items.RarityColor(rarity)) + " "
	desc += "focus." if focus else "weapon."
	desc += "\nGain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Loot n' Scoot: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		for i in range(Global.lastSlot + 1):
			if Global.inventory[i] == null:
				Global.inventory[i] = Items.RandomEquipment(false, rarity, focus)
				break
	ATD.SetDifficulty(randi_range(1 + int(rarity), 2 + int(rarity)))
	return ATD

static func NewItem(itemName : String, stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var item : Item = Items.items[itemName]
	var buff : int = 3 if stat == Stat.HP else 1
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Get a " + LogText.WrapColor(itemName, Items.RarityColor(item.rarity)) + "."
	desc += "\nGain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Finder's Keepers: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		for i in range(Global.lastSlot + 1):
			if Global.inventory[i] == null:
				Global.inventory[i] = item
				break
	ATD.item = item.mesh
	ATD.SetDifficulty(randi_range(1 + int(item.rarity), 2 + int(item.rarity)))
	return ATD

static func ExitDetector(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var buff : int = 3 if stat == Stat.HP else 1
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]At the start of a floor, you know the direction to an exit.\n"
	desc += "Gain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Pathfinder: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		e.OnFloorStart.connect(RandomAbility.ExitDetection)
		RandomAbility.canDetectExit = true
	ATD.color = Color.DARK_VIOLET
	ATD.SetDifficulty(randi_range(3, 4))
	return ATD
	
static func ExitDetection(e : Player):
	var exits = e.gridmap.exits.keys()
	var exitPos = exits[randi_range(0, exits.size() - 1)]
	
	var xDiff = exitPos.x - e.gridPos.x
	var yDiff = exitPos.y - e.gridPos.y
	
	var dir : String = ""
	if abs(xDiff) > abs(yDiff):
		if xDiff < 0:
			dir = "east"
		else:
			dir = "west"
	else:
		if yDiff < 0:
			dir = "south"
		else:
			dir = "north"
		
	e.text.AddLine(e.GetLogName() + " sensed an exit to the " + dir + "!\n")

static func CritBuff(critBonus : float = .1):
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Gain " + str(critBonus * 100) + "% " + LogText.WrapColor("[b][i]œ[/i][/b]CRIT", Color.ORANGE_RED) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Practiced Precision", desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		e.originalStats.CRIT += critBonus
		
	ATD.color = Color.ORANGE_RED
	ATD.SetDifficulty(randi_range(3, 4))
	return ATD
	
static func ItemDetector(stat : Stat = Stat[Stat.keys()[randi_range(0, Stat.size() - 1)]]):
	var buff : int = 3 if stat == Stat.HP else 1
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]At the start of a floor, you know the number of items on that level, and you know the direction to a random item.\n"
	desc += "Gain " + str(buff) + " " + StatWrap(stat) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Treasure Hunter: " + StatWrap(stat), desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		match stat:
			Stat.POW: e.originalStats.POW += buff
			Stat.MAG: e.originalStats.MAG += buff
			Stat.DEF: e.originalStats.DEF += buff
			Stat.RES: e.originalStats.RES += buff
			Stat.HP: 
				e.originalStats.HP += buff
				e.originalStats.maxHP += buff
		e.OnFloorStart.connect(RandomAbility.ItemDetection)
		RandomAbility.canDetectItem = true
	ATD.color = Color.WEB_PURPLE
	ATD.SetDifficulty(2)
	return ATD
	
static func ItemDetection(e : Player):
	var itemPositions = e.gridmap.items.keys()
	var itemPos = itemPositions[randi_range(0, itemPositions.size() - 1)]
	var item : Item = e.gridmap.items[itemPos].items[0]
	
	var xDiff = itemPos.x - e.gridPos.x
	var yDiff = itemPos.y - e.gridPos.y
	
	var dir : String = ""
	if abs(xDiff) > abs(yDiff):
		if xDiff < 0:
			dir = "east"
		else:
			dir = "west"
	else:
		if yDiff < 0:
			dir = "south"
		else:
			dir = "north"
		
	e.text.AddLine(e.GetLogName() + " sensed " + str(e.gridmap.items.size() - 1) + " items on this floor!\n")
	e.text.AddLine(e.GetLogName() + " sensed a " + item.GetLogName() + " to the " + dir + "!\n")

static func Limber():
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Gain immunity to Paralysis.\n"
	desc += "Gain 1 " + StatWrap(Stat.DEF) + " and 1 " + StatWrap(Stat.RES) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Limber", desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		e.originalStats.DEF += 1
		e.originalStats.RES += 1
		e.immune["Paralysis"] = null
	ATD.color = Color.LIGHT_YELLOW
	ATD.SetDifficulty(3)
	return ATD
	
static func HardLevel():
	var desc : String = "[b][i][font_size=25]![/font_size][/i][/b][indent]Fight for your life.\n"
	desc += "Gain 3 " + StatWrap(Stat.POW) + " and 3 " + StatWrap(Stat.MAG) + ".[/indent]"
	var ATD : AbilityTreeData = AbilityTreeData.new("Faustian Bargain", desc)
	ATD.OnLevelStart = func(e : Player, _tp : AbilityTreePlayer):
		e.originalStats.POW += 3
		e.originalStats.MAG += 3
	ATD.color = Color.CRIMSON
	ATD.SetDifficulty(8)
	return ATD
