class_name Items
extends Node

static var Modifier : Array[String] = ["Blitz", "Bold", "Bludgeon", "Bleed", "Reach", "Runed", "Cleave", "Crush"] 
static var Aspect : Array[String] = ["Fire", "Frost", "Earth", "Air", "Force", "Lightning", "Radiant", "Shadow"]

enum Rarity { Common, Uncommon, Rare, Mythic }

static func RandomModifier(prof : Classes.Proficiency = Classes.Proficiency.None):
	var r : int
	if prof == Classes.Proficiency.WeaponBasic:
		r = randi_range(0, 3)
	elif prof == Classes.Proficiency.WeaponMartial:
		r = randi_range(4, Modifier.size() - 1)
	else:
		r = randi_range(0, Modifier.size() - 1)
	return Modifier[r]
		
static func RandomAspect(prof : Classes.Proficiency = Classes.Proficiency.None):
	var r : int
	if prof == Classes.Proficiency.FocusBasic:
		r = randi_range(0, 3)
	elif prof == Classes.Proficiency.FocusAdvanced:
		r = randi_range(4, Aspect.size() - 1)
	else:
		r = randi_range(0, Aspect.size() - 1)
	return Aspect[r]

static func GetModifierDescription(prefix : String):
	if prefix == "Blitz":
		return "Blitz weapons have a chance to do more damage if you moved last turn."
	elif prefix == "Bold":
		return "Bold weapons have a chance to do more damage if you attacked last turn."
	elif prefix == "Bludgeon":
		return "Bludgeon weapons have a chance to penetrate the enemy's defense."
	elif prefix == "Bleed":
		return "Bleed weapons have a chance to inflict bleeding, dealing damage over time."
	elif prefix == "Reach":
		return "Reach weapons have a small chance to attack with 1 extra range."
	elif prefix == "Runed":
		return "Runed weapons have a chance to do increased magic damage."
	elif prefix == "Cleave":
		return "Cleave weapons have a chance to attack adjacent enemies."
	elif prefix == "Crush":
		return "Crush weapons have a chance to stun, depending on the enemy's remaining health."
	else:
		return "An unmodified piece of equipment."

static func GetAspectDescription(prefix : String):
	if prefix == "Fire":
		return "Fire foci have a chance to inflict burning, dealing damage over time."
	elif prefix == "Frost":
		return "Frost foci have a chance to inflict frostbite, reducing enemies' POW and MAG."
	elif prefix == "Air":
		return "Air foci have a small chance to attack with 1 extra range."
	elif prefix == "Earth":
		return "Earth foci have a chance to inflict bleeding, dealing damage over time."
	elif prefix == "Lightning":
		return "Lightning foci have a chance to stun, depending on the enemy's remaining health."
	elif prefix == "Force":
		return "Force foci have a chance to do increased damage."
	elif prefix == "Shadow":
		return "Shadow foci have a chance to penetrate the enemy's defense."
	elif prefix == "Radiant":
		return "Radiant foci have a chance to heal for a percentage of the damage dealt."
	else:
		return "An unmodified piece of equipment."
		
static func RandomRarity() -> Rarity:
	var chance : float = randf_range(0, 100)
	if chance <= 1:
		return Rarity.Mythic
	elif chance <= 7:
		return Rarity.Rare
	elif chance <= 57:
		return Rarity.Uncommon
	else:
		return Rarity.Common

static func WeaponProficiencyFromRarity(rarity : Rarity) -> Classes.Proficiency:
	if rarity == Rarity.Common:
		return Classes.Proficiency.WeaponBasic
	elif rarity == Rarity.Uncommon:
		return Classes.Proficiency.WeaponMartial if randf_range(0, 1) > .6 else Classes.Proficiency.WeaponBasic
	else:
		return Classes.Proficiency.WeaponMartial if randi_range(0, 1) == 0 else Classes.Proficiency.WeaponBasic

static func FocusProficiencyFromRarity(rarity : Rarity) -> Classes.Proficiency:
	if rarity == Rarity.Common:
		return Classes.Proficiency.FocusBasic
	elif rarity == Rarity.Uncommon:
		return Classes.Proficiency.FocusAdvanced if randf_range(0, 1) > .6 else Classes.Proficiency.FocusBasic
	else:
		return Classes.Proficiency.FocusAdvanced if randi_range(0, 1) == 0 else Classes.Proficiency.FocusBasic
		
static func CritChanceFromRarity(rarity : Rarity, focus : bool) -> float:
	var additive = 0.0 if focus else 0.02
	if rarity == Rarity.Common:
		return (floorf(randf_range(3, 6)) / 100) + additive
	elif rarity == Rarity.Uncommon:
		return (floorf(randf_range(8, 10)) / 100) + additive
	elif rarity == Rarity.Rare:
		return (floorf(randf_range(10, 13)) / 100) + additive
	else:
		return .15 + additive
		

static func RandomEquipment(random : bool = false, r : Rarity = Rarity.Common, focus : bool = false, p : String = ""):
	var proficiency : Classes.Proficiency
	var prefix : String
	var m : Move
	var n : String
	var rarity : Rarity = r if !random else RandomRarity()
	var crit : float
	
	var description
	
	var prefixes
	var suffixes
	var own
	var single
	
	var flavor = ""
	if (!random && focus) || (random && randi_range(0, 1) == 1):
		proficiency = FocusProficiencyFromRarity(rarity) 
		prefix = RandomAspect(proficiency) if p == "" else p
		description = GetAspectDescription(prefix)
		m = Move.DefaultMagical()
		crit = CritChanceFromRarity(rarity, true)
		
		prefixes = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Prefix"]
		if rarity == Rarity.Mythic:
			var flavors = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["FlavorFull"]
			flavor = flavors[randi_range(0, flavors.size() - 1)]
			suffixes = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Suffix"]
			own = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Owner"]
			single = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Single"]
		else:
			suffixes = equipmentData["Focus"]["Rarity"][Rarity.keys()[rarity]]["Suffix"]
			own = []
			single = []
	else:
		proficiency = WeaponProficiencyFromRarity(rarity)
		prefix = RandomModifier(proficiency) if p == "" else p
		description = GetModifierDescription(prefix)
		m = Move.DefaultPhysical()
		crit = CritChanceFromRarity(rarity, false)
		
		if rarity == Rarity.Mythic:
			var flavors = equipmentData["Weapon"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["FlavorFull"]
			flavor = flavors[randi_range(0, flavors.size() - 1)]
			own = equipmentData["Weapon"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Owner"]
			single = equipmentData["Weapon"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Single"]
		else:
			own = []
			single = []
		
		prefixes = equipmentData["Weapon"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Prefix"]
		suffixes = equipmentData["Weapon"]["Rarity"][Rarity.keys()[rarity]]["Modifiers"][prefix]["Suffix"]
		
		
	if single.size() > 0 && randi_range(0, 2) == 0:
		n = single[randi_range(0, single.size() - 1)]
	else:
		n = own[randi_range(0, own.size() - 1)] + " " if own.size() > 0 else ""
		n += prefixes[randi_range(0, prefixes.size() - 1)]
		n += " " + suffixes[randi_range(0, suffixes.size() - 1)] if n != "" else suffixes[randi_range(0, suffixes.size() - 1)]
		
	var i = Equipment.new(n, description, flavor)
	i.rarity = rarity
	i.SetEquipment(m, proficiency, { prefix:null }, crit)
	return i

static func RarityColor(rarity : Rarity):
	if rarity == Rarity.Common:
		return Color.WHITE_SMOKE
	elif rarity == Rarity.Uncommon:
		return Color.LIGHT_BLUE
	elif rarity == Rarity.Rare:
		return Color.REBECCA_PURPLE
	else:
		return Color.GOLD
		
static func ChangePrefixName(e : Equipment, prefix : String = "Modified"):
	if e.rarity == Rarity.Mythic || e.modified:
		return
	var suffix : String = e.name.get_slice(" ", 1) if e.name.get_slice_count(" ") == 2 else e.name
	var prefixes = equipmentData["Focus"]["Rarity"][Rarity.keys()[e.rarity]]["Modifiers"][prefix]["Prefix"] if e.move.magic else equipmentData["Weapon"]["Rarity"][Rarity.keys()[e.rarity]]["Modifiers"][prefix]["Prefix"]
	e.name = prefixes[randi_range(0, prefixes.size() - 1)] + " " + suffix
	e.move.name = e.GetLogName()
	e.modified = true

static var items : Dictionary = {}
static var equipmentData : Dictionary

func _ready():
	equipmentData = Loader.GetEquipmentData()
	var escape = func(e : Entity, _t : Entity):
		await e.gridmap.controller.NextLevel()
	var escapeMove = Move.new("Escape", escape)
	escapeMove.noTargets = true
	escapeMove.playAnimation = false
	Move.moves["Escape"] = escapeMove
	
	var x = func(e : Entity, t : Entity):
		var placePos = e.facingPos if e.gridmap.GetMapPos(e.facingPos) != -2 else e.gridPos
		var numitems : int
		var possibleItems
		var salvageTarget = t != null && t.Type != "Ally" && e.Type == "Player"
		if !salvageTarget:
			possibleItems = e.gridmap.controller.level.materials
			numitems = randi_range(2, 3) if randf_range(0, 1) > .2 else 4
		else:
			possibleItems = Loader.GetEnemyData(t.Name)["drops"]
			numitems = randi_range(1, 3)
		
		possibleItems += ["Shiny Scrap", "Heavy Scrap", "Light Scrap", "Sharp Scrap"]
		for i in range(numitems):
			var foundItem = randi_range(0, possibleItems.size() - 1)
			e.text.AddLine("Salvaged " + possibleItems[foundItem] + "!\n")
			e.gridmap.PlaceItem(placePos, items[possibleItems[foundItem]])
		if salvageTarget:
			t.AddStatus(Status.Bleed(), 2)
			t.AddStatus(Status.Disarm(), 2)
			e.text.AddLine(t.GetLogName() + " was lacerated while salvaging!\n")
	var salvageMove = Move.new("Salvage", x)
	salvageMove.noTargets = true
	Move.moves["Salvage"] = salvageMove
	
	LoadItems()
	
func Add(i : Item):
	Items.items[i.name] = i
	
func LoadItems():
	var data : Dictionary = Loader.GetAllItems()
	for i in data.keys():
		var itemData = data[i]
		var mesh = load(itemData["mesh"]) if "mesh" in itemData && itemData["mesh"] != null else null
		var item = Item.new(itemData["name"], itemData["description"], itemData["flavor"], mesh)
		item.rarity = itemData["rarity"] as Rarity if "rarity" in itemData else Rarity.Common
		if "move" in itemData:
			item.move = LoadMove(itemData)
			item.moveTooltip = itemData["move"]["useTooltip"]
		if "consumable" in itemData:
			item.consumable = true
			item.maxUses = itemData["consumable"]
		if "topdown" in itemData:
			item.topdown = itemData["topdown"]
		if "invHeight" in itemData:
			item.invHeight = itemData["invHeight"]
		if "invRotation" in itemData:
			item.invRotation = itemData["invRotation"]
		if "recipe" in itemData:
			for r in itemData["recipe"]:
				item.crafting.recipe.append(r)
		if "requires" in itemData:
			#temporary solution
			if itemData["requires"][0] == "Alchemy":
				item.crafting.requires = Classes.GetClassNum(Classes.BaseClass.Alchemy) 
			elif itemData["requires"][0] == "Machining":
				item.crafting.requires = Classes.GetClassNum(Classes.BaseClass.Machining)
		if "tags" in itemData:
			for tag in itemData["tags"]:
				item.crafting.tags[tag] = null
		Add(item)

func LoadMove(itemData) -> Move:
	if "custom" in itemData["move"]:
		return Move.moves[itemData["move"]["custom"]]
		
	var m = Move.new(itemData["name"])
	var effects : Callable
	
	
	if "heal" in itemData["move"]["effects"]:
		effects =  func(e : Entity, _d : Entity = null):
			var healAmount : int = int((itemData["move"]["effects"]["heal"]["amount"] / 100) * e.stats.maxHP) if itemData["move"]["effects"]["heal"]["amountType"] == "%" else itemData["move"]["effects"]["heal"]["amount"]
			e.text.AddLine(e.GetLogName() + " healed for " + str(e.Heal(healAmount)) + " HP!\n") 
	if "debuff" in itemData["move"]["effects"]:
		effects = func(e : Entity, t : Entity):
			t.AddStatus(Status.status[itemData["move"]["effects"]["debuff"]["type"]], itemData["move"]["effects"]["debuff"]["duration"])
			if "message" in itemData["move"]:
				e.text.AddLine(t.GetLogName() + " " + itemData["move"]["message"] + "\n")
			t.animator.Damage()
	if "buff" in itemData["move"]["effects"]:
		effects = func(e : Entity, _t : Entity):
			e.AddStatus(Status.status[itemData["move"]["effects"]["buff"]["type"]], itemData["move"]["effects"]["buff"]["duration"])
			if "message" in itemData["move"]:
				e.text.AddLine(e.GetLogName() + " " + itemData["move"]["message"] + "\n")
	if "tileEffect" in itemData["move"]["effects"]:
		effects = func(e : Entity, _t : Entity):
			e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.GetTileEffect(itemData["move"]["effects"]["tileEffect"]["type"]), e)
			if "message" in itemData["move"]:
				e.text.AddLine(e.GetLogName() + " " + itemData["move"]["message"] + "\n")
				
	m.attackEffects = effects
	if "damage" in itemData["move"]["effects"]:
		m.magic = itemData["move"]["effects"]["damage"]["magic"]
		#this function is not used for non-projectile versions of moves
		effects = func(attacker : Entity, defender : Entity):
			var damage : int = Stats.GetDamage(attacker.stats, defender.stats, itemData["move"]["effects"]["damage"]["magic"])
			attacker.text.AddLine(attacker.GetLogName() + " attacked " + defender.GetLogName() + " with " + itemData["name"] +  " for " + LogText.GetDamageNum(damage, m.magic) + " damage!" + "\n")
			defender.animator.Damage()
			defender.TakeDamage(damage, attacker)
			
	if "playAnimation" in itemData["move"]:
		m.playAnimation = itemData["move"]["playAnimation"]
	if "manualEndTurn" in itemData["move"]:
		m.manualEndTurn = itemData["move"]["manualEndTurn"]
	if "noTargets" in itemData["move"]:
		m.noTargets = itemData["move"]["noTargets"]
	if "reveals" in itemData["move"]:
		m.reveals = itemData["move"]["reveals"]
	
	if "projectile" in itemData["move"]["effects"]:
		var projectileMesh = load(itemData["move"]["effects"]["projectile"]["mesh"]) if "mesh" in itemData["move"]["effects"]["projectile"] else load("res://Assets/Items/Machining/Javelin.tscn")
		var p : Move = Move.DefaultProjectile(projectileMesh, effects, itemData["move"]["effects"]["projectile"]["range"])
		return p
	return m











