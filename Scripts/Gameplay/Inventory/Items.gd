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
	elif chance > .6:
		return items[randomItems[randi_range(0, randomItems.size() - 1)]]
	else:
		return items[randomMaterials[randi_range(0, randomMaterials.size() - 1)]]

static var items : Dictionary = {}
static var randomItems = ["Healing Potion", "Paralysis Draught", "Flamefroth Tincture", "Javelin", "Fibrous Net", "Tunneling Tools", "Salvaging Kit"]
static var randomMaterials = ["Russ Talon", "Eidolon Mass", "Charshroom", "Fulminating Gravel", "Bonder's Bulb"]

func _ready():
	var eat = func(e : Entity, _t = null):
		e.text.AddLine(e.Name + " healed for " + str(e.Heal(5)) + " HP!") 
	var move = Move.new("Drink", eat)
	move.playAnimation = false
	move.noTargets = true
	move.reveals = false
	Add(Item.new("Healing Potion", "Restores 5HP.", "The taste and temperature varies drastically, seemingly adapting to the consumer's current needs and preferences.", null, move, "Drink", true))
	items["Healing Potion"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Alchemy)
	items["Healing Potion"].crafting.recipe = ["Reagent", "Healing"] as Array[String]
	
	var para = func(e : Entity, t : Entity):
		t.AddStatus(Status.Paralysis(), 4)
		e.text.AddLine(t.Name + " was paralyzed!\n") 
	var paraMove = Move.new("Paralysis Draught", para)
	Add(Item.new("Paralysis Draught", "Paralyze a foe!", "Skin exposure causes profound numbness and impaired motor control, rendering the recipient effectively immobile.", null, paraMove, "Throw", true))
	items["Paralysis Draught"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Alchemy)
	items["Paralysis Draught"].crafting.recipe = ["Reagent", "Paralysis"] as Array[String]
	
	var fire = func(e : Entity, _t : Entity = null):
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Fire, e)
	var fireMove = Move.new("Flamefroth Tincture", fire)
	fireMove.noTargets = true
	Add(Item.new("Flamefroth Tincture", "Breathe fire in an area.", "Though highly effective, frequent use incinerates phlegm and other particulates in the throat, causing embers and ash to accumulate around the mouth.", null, fireMove, "Drink", true))
	items["Flamefroth Tincture"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Alchemy)
	items["Flamefroth Tincture"].crafting.recipe = ["Reagent", "Fire"] as Array[String]
	
	var javelinMove = Move.DefaultPhysical()
	javelinMove.projectileSprite = preload("res://Assets/Items/Javelin.png")
	javelinMove.name = "Javelin"
	var javelin = Move.DefaultProjectile(javelinMove)
	Add(Item.new("Javelin", "Throw to deal damage at a distance.", "", javelinMove.projectileSprite, javelin, "Throw", true))
	items["Javelin"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Machining)
	items["Javelin"].crafting.recipe = ["Adhesive", "Sharp"] as Array[String]
	
	var n = func(e : Entity, t : Entity):
		t.AddStatus(Status.Paralysis(), 3)
		e.text.AddLine(t.Name + " was ensnared!\n") 
	var netMove = Move.new("Fibrous Net", n)
	netMove.projectileSprite = preload("res://Assets/Items/Net.png")
	var net = Move.DefaultProjectile(netMove)
	Add(Item.new("Fibrous Net", "Throw to ensnare a creature, preventing movement.", "", netMove.projectileSprite, net, "Throw", true))
	items["Fibrous Net"].crafting.requires = Classes.GetClassNum(Classes.BaseClass.Machining)
	items["Fibrous Net"].crafting.recipe = ["Adhesive", "Fiber"] as Array[String]
	
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

	Add(Item.new("Russ Talon", "A claw shorn from a Russ. The marrow can be used as a base for potions.", ""))
	items["Russ Talon"].crafting.tags = { "Reagent":null, "Sharp":null }
	Add(Item.new("Eidolon Mass", "The indigestable remains left after an Eidolon's elemental meal. Has a number of unique uses."))
	items["Eidolon Mass"].crafting.tags = { "Reagent":null, "Fire":null, "Adhesive":null, "Sharp":null }
	
	Add(Item.new("Charshroom", "The fibrous, carbon-rich mycelium of these mushrooms is highly flammable. The cloud of spores they release is indistinguishable from smoke.", ""))
	items["Charshroom"].crafting.tags = { "Fire":null, "Fiber":null }
	Add(Item.new("Fulminating Gravel", "Built-up arcane and static energies within this sediment make for a number of potential applications.", ""))
	items["Fulminating Gravel"].crafting.tags = { "Paralysis":null, "Adhesive":null }
	Add(Item.new("Bonder's Bulb", "These small, stringy plants release a sap that was once used as a type of glue."))
	items["Bonder's Bulb"].crafting.tags = { "Adhesive":null, "Fiber":null }
	
func Add(i : Item):
	Items.items[i.name] = i
