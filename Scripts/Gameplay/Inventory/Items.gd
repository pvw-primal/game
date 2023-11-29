class_name Items
extends Node

static var Modifier : Array[String] = ["Blitz", "Bold", "Bludgeon", "Bleed", "Reach", "Runed", "Cleave", "Crush"] 
static var Aspect : Array[String] = ["Fire", "Frost", "Earth", "Air", "Force", "Lightning", "Radiant", "Shadow"]

static func RandomModifier(prof : Classes.Proficiency = Classes.Proficiency.None):
	var r : int
	if prof == Classes.Proficiency.WeaponBasic:
		r = randi_range(0, 3)
	elif prof == Classes.Proficiency.WeaponMartial:
		r = randi_range(4, Modifier.size() - 1)
	else:
		r = randi_range(0, Modifier.size() - 1)
#	if mod == "Runed":
#		mod = RandomAspect() + "-" + mod
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

static func RandomEquipment():
	var proficiency : Classes.Proficiency
	var prefix : String
	var m : Move
	var n : String
	
	if randi_range(0, 1) == 0:
		proficiency = Classes.Proficiency.FocusAdvanced if randf_range(0, 1) > .7 else Classes.Proficiency.FocusBasic
		prefix = RandomAspect(proficiency)
		m = Move.DefaultMagical()
		n = "Focus"
	else:
		proficiency = Classes.Proficiency.WeaponMartial if randf_range(0, 1) > .7 else Classes.Proficiency.WeaponBasic
		prefix = RandomModifier(proficiency)
		m = Move.DefaultPhysical()
		n = "Weapon"
	
	var i = Item.new(prefix + " " + n, "A piece of equipment.", "")
	i.SetEquipment(m, proficiency, { prefix:null })
	return i

static func RandomItem():
	var chance = randf_range(0, 1)
	if chance > .8:
		return RandomEquipment()
	elif chance > .5:
		return items[randomItems[randi_range(0, randomItems.size() - 1)]]
	else:
		return items[randomMaterials[randi_range(0, randomMaterials.size() - 1)]]

static var items : Dictionary = {}
static var randomItems = ["Healing Potion", "Paralysis Draught", "Flamefroth Tincture", "Javelin", "Fibrous Net", "Tunneling Tools", "Salvaging Kit"]
static var randomMaterials = ["Russ Talon", "Eidolon Mass", "Charshroom", "Fulminating Gravel", "Bonder's Bulb", "Pestail"]

func _ready():
	LoadItems()
	
	var escape = func(e : Entity, _t : Entity):
		await e.gridmap.controller.NextLevel()
	var escapeMove = Move.new("Escape", escape)
	escapeMove.noTargets = true
	escapeMove.playAnimation = false
	Add(Item.new("Tunneling Tools", "Use to descend to the next level.", "Basically cheating.", null, escapeMove, "Use", true))
	
	var x = func(e : Entity, t : Entity):
		var placePos = e.facingPos if e.gridmap.GetMapPos(e.facingPos) != -2 else e.gridPos
		var numitems : int
		if t == null:
			numitems = randi_range(2, 3) if randf_range(0, 1) > .2 else 4
		else: 
			numitems = randi_range(1, 3)
		var possibleItems = ["Russ Talon", "Charshroom", "Fulminating Gravel", "Bonder's Bulb"]
		for i in range(numitems):
			var foundItem = randi_range(0, possibleItems.size() - 1)
			e.text.AddLine("Salvaged " + possibleItems[foundItem] + "!\n")
			e.gridmap.PlaceItem(placePos, items[possibleItems[foundItem]])
		if t != null:
			t.AddStatus(Status.Bleed(), 2)
			t.AddStatus(Status.Disarm(), 2)
			e.text.AddLine(t.Name + " was lacerated while salvaging!\n")
	var salvageMove = Move.new("Salvaging Kit", x)
	salvageMove.noTargets = true
	Add(Item.new("Salvaging Kit", "Salvage materials from the environment or from a creature.", "", null, salvageMove, "Salvage", true))
	items["Salvaging Kit"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Machining)
	items["Salvaging Kit"].crafting.recipe = ["Adhesive", "Fiber", "Sharp"] as Array[String]
	
func Add(i : Item):
	Items.items[i.name] = i
	
func LoadItems():
	var data : Dictionary = Loader.GetAllItems()
	for i in data.keys():
		var itemData = data[i]
		var texture = load(itemData["icon"]) if "icon" in itemData && itemData["icon"] != null else null
		var item = Item.new(itemData["name"], itemData["description"], itemData["flavor"], texture)
		if "move" in itemData:
			item.move = LoadMove(itemData)
			item.moveTooltip = itemData["move"]["useTooltip"]
		if "consumable" in itemData:
			item.consumable = itemData["consumable"]
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
	var m = Move.new(itemData["name"])
	
	if "damage" in itemData["move"]["effects"]:
		m.magic = itemData["move"]["effects"]["damage"]["magic"]
	if "heal" in itemData["move"]["effects"]:
		m.attackEffects =  func(e : Entity, _d : Entity = null):
			var healAmount : int = int((itemData["move"]["effects"]["heal"]["amount"] / 100) * e.stats.maxHP) if itemData["move"]["effects"]["heal"]["amountType"] == "%" else itemData["move"]["effects"]["heal"]["amount"]
			e.text.AddLine(e.Name + " healed for " + str(e.Heal(healAmount)) + " HP!\n") 
	if "debuff" in itemData["move"]["effects"]:
		m.attackEffects = func(e : Entity, t : Entity):
			t.AddStatus(Status.status[itemData["move"]["effects"]["debuff"]["type"]], itemData["move"]["effects"]["debuff"]["duration"])
			e.text.AddLine(t.Name + " " + itemData["move"]["message"] + "\n")
	if "tileEffect" in itemData["move"]["effects"]:
		m.attackEffects = func(e : Entity, _t : Entity):
			e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.GetTileEffect(itemData["move"]["effects"]["tileEffect"]["type"]), e)
			e.text.AddLine(e.Name + " " + itemData["move"]["message"] + "\n")
		
	
	if "playAnimation" in itemData["move"]:
		m.playAnimation = itemData["move"]["playAnimation"]
	if "manualEndTurn" in itemData["move"]:
		m.manualEndTurn = itemData["move"]["manualEndTurn"]
	if "noTargets" in itemData["move"]:
		m.noTargets = itemData["move"]["noTargets"]
	if "reveals" in itemData["move"]:
		m.reveals = itemData["move"]["reveals"]
	
	if "projectile" in itemData["move"]["effects"]:
		m.projectileSprite = load(itemData["move"]["effects"]["projectile"]["icon"]) if "icon" in itemData["move"]["effects"]["projectile"] else load(itemData["icon"])
		var p : Move = Move.DefaultProjectile(m, itemData["move"]["effects"]["projectile"]["range"])
		return p
	return m











