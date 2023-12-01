class_name MonoClasses
extends Node

func _ready():
	Status.InitStatus()
	
	var shamanMove = Move.new("Unleash Elements", Shaman1)
	shamanMove.playAnimation = false
	shamanMove.manualEndTurn = true
	shamanMove.noTargets = true
	shamanMove.cooldown = 3
	shamanMove.manualCooldown = true
	shamanMove.icon = preload("res://Assets/Icons/Move/Shaman.png")
	Class.new("Shaman", [shamanMove], Classes.GetClassNum(Classes.BaseClass.Shamanism), Classes.GetProfNum(Classes.Proficiency.FocusBasic))
	
	var arcanaApply = Move.new("Aspected Blast", Arcana1Apply)
	arcanaApply.playAnimation = false
	arcanaApply.manualEndTurn = true
	arcanaApply.RemoveCheck()
	arcanaApply.magic = true
	arcanaApply.waittime = .1
	var Arcana1 = func (e : Entity, t : Entity):
		if e.equipped == -1:
			e.endTurn.emit()
			return
		var mods : Dictionary = e.inventory[e.equipped].prefixes
		var r = 3 if "Air" in mods else 2
		var def = e.CheckDirection(e.facingPos - e.gridPos, r) if t == null else [t.gridPos, t]
		
		if def[1] == null:
			e.gridmap.SpawnProjectile(e, def[0], 3, preload("res://Assets/Items/Sword.png"))
		else:
			e.gridmap.SpawnProjectileTarget(e, def[1], arcanaApply, 3, preload("res://Assets/Items/Sword.png"))
	var arcanistMove = Move.new("Aspected Blast", Arcana1)
	arcanistMove.manualEndTurn = true
	arcanistMove.noTargets = true
	arcanistMove.cooldown = 3
	Class.new("Arcanist", [arcanistMove], Classes.GetClassNum(Classes.BaseClass.Arcana), Classes.GetProfNum(Classes.Proficiency.FocusBasic, Classes.Proficiency.FocusAdvanced), [], false, true)
	
	var fighterMove = Move.new("Skilled Strike", Arms1)
	fighterMove.noTargets = true
	fighterMove.cooldown = 2
	fighterMove.icon = preload("res://Assets/Icons/Move/Fighter.png")
	Class.new("Fighter", [fighterMove], Classes.GetClassNum(Classes.BaseClass.Arms), Classes.GetProfNum(Classes.Proficiency.WeaponBasic, Classes.Proficiency.WeaponMartial), [], false, true)
	
	var rogueMove = Move.new("Stealth", Technique1)
	rogueMove.playAnimation = false
	rogueMove.noTargets = true
	rogueMove.reveals = false
	rogueMove.cooldown = 3
	rogueMove.icon = preload("res://Assets/Icons/Move/Rogue.png")
	Class.new("Rogue", [rogueMove], Classes.GetClassNum(Classes.BaseClass.Technique), Classes.GetProfNum(Classes.Proficiency.WeaponBasic))
	
	var tamerMove = Move.new("Tame", Beastmastery1)
	tamerMove.playAnimation = false
	tamerMove.noTargets = true
	tamerMove.cooldown = 1
	tamerMove.icon = preload("res://Assets/Icons/Move/Tamer.png")
	Class.new("Tamer", [tamerMove], Classes.GetClassNum(Classes.BaseClass.Beastmastery), Classes.GetProfNum(Classes.Proficiency.WeaponBasic, Classes.Proficiency.FocusBasic))
	
	var craft : Array[String] = ["Healing Potion", "Paralysis Draught", "Flamefroth Tincture"]
	var alchemyMove = Move.new("Brew", Alchemy1)
	alchemyMove.playAnimation = false
	alchemyMove.manualEndTurn = true
	alchemyMove.noTargets = true
	alchemyMove.reveals = false
	Class.new("Alchemist", [alchemyMove], Classes.GetClassNum(Classes.BaseClass.Alchemy), Classes.GetProfNum(Classes.Proficiency.WeaponBasic, Classes.Proficiency.Tool), craft, true)
	
	var craft2 : Array[String] = ["Salvaging Kit", "Fibrous Net", "Javelin"]
	var machiningMove = Move.new("Tinker", Machining1)
	machiningMove.playAnimation = false
	machiningMove.manualEndTurn = true
	machiningMove.noTargets = true
	machiningMove.reveals = false
	Class.new("Mechanist", [machiningMove], Classes.GetClassNum(Classes.BaseClass.Machining), Classes.GetProfNum(Classes.Proficiency.WeaponBasic, Classes.Proficiency.Tool), craft2, true)
	

#SHAMANISM
var ShamanOptions : Array[String] = ["Fire", "Frost", "Earth", "Air"]
func Shaman1(e : Entity, _t = null):
	if e.Type == "Player":
		e.option.OptionSelected.connect(ShamanAttack)
		e.option.Open(ShamanOptions)
	else:
		ShamanAttack(e, 0)
		
func ShamanAttack(e : Entity, id : int):
	if e.Type == "Player":
		e.option.OptionSelected.disconnect(ShamanAttack)
		if id == -1:
			e.Start.call_deferred()
			return
	if id == 0:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Fire, e)
		e.text.AddLine(e.Name + " ignited the ground!\n")
	elif id == 1:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Frost, e)
		e.text.AddLine(e.Name + " froze the ground!\n")
	elif id == 2:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Earth, e)
		e.text.AddLine(e.Name + " reinforced the earth!\n")
	elif id == 3:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Air, e)
		e.text.AddLine(e.Name + " called the wind!\n")
	e.animator.Attack()
	e.StartCooldownName(Classes.GetClass(Classes.BaseClass.Shamanism).moves[0].name)
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

#ARCANA
func Arcana1Apply (e : Entity, t : Entity):
	var mods : Dictionary = e.inventory[e.equipped].prefixes
	var additiveMod = 1
	if "Fire" in mods:
		t.AddStatus(Status.Burning(), 2)
	if "Frost" in mods:
		t.AddStatus(Status.Frost(), 3)
	if "Earth" in mods:
		t.AddStatus(Status.Bleed(), 3)
	if "Force" in mods:
		additiveMod += .2
	if "Lightning" in mods && randf_range(0, 1) < .2:
		t.AddStatus(Status.Paralysis(), 1)
	var damage = Stats.GetDamage(e.stats, t.stats, false, 2) if "Shadow" in mods else Stats.GetDamage(e.stats, t.stats)
	damage *= additiveMod
	e.text.AddLine(e.Name + " attacked " + t.Name + " with " + "Aspected Blast" +  " for " + str(int(damage)) + " damage!" + "\n")
	t.TakeDamage(damage, e)
	if "Radiant" in mods:
		e.Heal(damage * .25)
		e.text.AddLine("The radiant light healed " + e.Name + " for " + str(int(damage * .25)) + " HP!" + "\n")
		
#ARMS
func Arms1(e : Entity, t : Entity):
	if e.equipped == -1:
		return
	var mods : Dictionary = e.inventory[e.equipped].prefixes
	var targets : Array[Entity] = []
	if t != null && e.gridmap.NoCorners(e.gridPos, t.gridPos):
		targets.append(t)
	elif "Reach" in mods:
		var target = e.CheckDirection(e.facingPos - e.gridPos, 2)
		if target[1] != null:
			targets.append(target[1])
	if "Cleave" in mods:
		var adj = e.AdjacentTiles()
		adj.shuffle()
		var additional = 0
		for pos in adj:
			var entity = e.GetEntity(pos)
			if entity != null && entity not in targets:
				targets.append(entity)
				additional += 1
				if additional >= 2:
					break
				
	var additiveMod : float = 1
	if "Blitz" in mods && e.lastAction == Move.ActionType.move:
		additiveMod += .4
	elif "Bold" in mods && e.lastAction != Move.ActionType.move:
		additiveMod += .2
	if "Runed" in mods:
		additiveMod += .2
	
	await e.Wait(.3)
	for i in range(targets.size()):
		if "Bleed" in mods:
			targets[i].AddStatus(Status.Bleed(), 2)
		if "Crush" in mods && randf_range(0, 1) < .2:
			targets[i].AddStatus(Status.Stun(), 1)
		var damage = Stats.GetDamage(e.stats, targets[i].stats, false, 2) if "Bludgeon" in mods else Stats.GetDamage(e.stats, targets[i].stats)
		damage *= additiveMod
		if i > 0:
			damage /= 2
			e.text.AddLine(e.Name + " cleaved " + targets[i].Name + " with " + "Skilled Strike" +  " for " + str(int(damage)) + " damage!" + "\n")
		else:
			e.text.AddLine(e.Name + " attacked " + targets[i].Name + " with " + "Skilled Strike" +  " for " + str(int(damage)) + " damage!" + "\n")
		targets[i].animator.Damage()
		targets[i].TakeDamage(damage, e)
	await e.Wait(.65)
	
#TECHNIQUE
func Technique1(e : Entity, _t = null):
	e.AddStatus(Status.Stealth(), 3)
	e.text.AddLine(e.Name + " hid in the shadows!\n")

#BEASTMASTERY
func Beastmastery1(e : Entity, t : Entity):
	if e.Type != "Player":
		return
		
	if e.allies.size() > 0:
		for ally in e.allies:
			ally.targetEntity = e
		return
		
	if t == null:
		return
	
	if t.Type == "AI":
		if TameChance(t):
			e.text.AddLine(t.Name + " was tamed!\n")
			t.Type = "Ally"
			t.Name = "Ally " + t.Name
			e.allies.append(t)
			t.gridmap.minimap.Reveal(t.gridPos)
		else:
			e.text.AddLine("Tame failed!\n")

func TameChance(t : Entity):
	var chance = randf_range(0, .5)
	var percentHealth = float(t.stats.HP) / float(t.stats.maxHP)
	var chanceIncrease = (1 - percentHealth)
	return (chance + chanceIncrease) > .5
	
#ALCHEMY
func Alchemy1(e : Entity, _t = null):
	if e.Type == "Player":
		var disabled : Array[int] = []
		var desc : Array[String] = []
		var items = Classes.GetClass(Classes.BaseClass.Alchemy).canCraft
		for i in range(items.size()):
			var cc = Items.items[items[i]].crafting.CanCraft(e)
			desc.append(Items.items[items[i]].description + "\n")
			if cc.size() <= 0:
				disabled.append(i)
				desc[i] += "Missing ingredients."
		desc.append("Close the menu.")
		e.option.OptionSelected.connect(CraftAlchemy)
		e.option.Open(Classes.GetClass(Classes.BaseClass.Alchemy).canCraft, disabled, 250, desc, 200)


func CraftAlchemy(e : Entity, id : int):
	if e.Type == "Player":
		e.option.OptionSelected.disconnect(CraftAlchemy)
		if id == -1:
			e.Start.call_deferred()
			return
	var item = Items.items[Classes.GetClass(Classes.BaseClass.Alchemy).canCraft[id]]
	var remove = item.crafting.CanCraft(e)
	remove.sort()
	var removed = 0
	for i in remove:
		e.inventory.remove_at(i - removed)
		removed += 1
	e.text.AddLine(e.name + " brewed 1 " + item.name + ".\n")
	e.inventory.append(item)
	e.endTurn.emit()
	
#MACHINING
func Machining1(e : Entity, _t = null):
	if e.Type == "Player":
		var disabled : Array[int] = []
		var desc : Array[String] = []
		var items = Classes.GetClass(Classes.BaseClass.Machining).canCraft
		for i in range(items.size()):
			var cc = Items.items[items[i]].crafting.CanCraft(e)
			desc.append(Items.items[items[i]].description + "\n")
			if cc.size() <= 0:
				disabled.append(i)
				desc[i] += "Missing materials."
		desc.append("Close the menu.")
		e.option.OptionSelected.connect(CraftMachining)
		e.option.Open(Classes.GetClass(Classes.BaseClass.Machining).canCraft, disabled, 250, desc, 350)


func CraftMachining(e : Entity, id : int):
	if e.Type == "Player":
		e.option.OptionSelected.disconnect(CraftMachining)
		if id == -1:
			e.Start.call_deferred()
			return
	var item = Items.items[Classes.GetClass(Classes.BaseClass.Machining).canCraft[id]]
	var remove = item.crafting.CanCraft(e)
	remove.sort()
	var removed = 0
	for i in remove:
		e.inventory.remove_at(i - removed)
		removed += 1
	e.text.AddLine(e.name + " crafted 1 " + item.name + ".\n")
	e.inventory.append(item)
	e.endTurn.emit()
