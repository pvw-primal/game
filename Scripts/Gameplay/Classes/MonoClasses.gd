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
	shamanMove.manualOnMoveUse = true
	shamanMove.icon = preload("res://Assets/Icons/Move/Shaman.png")
	Move.moves["Unleash Elements"] = shamanMove
	
	var arcanistMove = Move.new("Aspected Blast", Arcana1)
	arcanistMove.manualEndTurn = true
	arcanistMove.noTargets = true
	arcanistMove.cooldown = 5
	arcanistMove.icon = preload("res://Assets/Icons/Move/Arcanist.png")
	Move.moves["Aspected Blast"] = arcanistMove
	
	var fighterMove = Move.new("Skilled Strike", Arms1)
	fighterMove.playAnimation = false
	fighterMove.manualOnMoveUse = true
	fighterMove.noTargets = true
	fighterMove.cooldown = 2
	fighterMove.icon = preload("res://Assets/Icons/Move/Fighter.png")
	Move.moves["Skilled Strike"] = fighterMove
	
	var rogueMove = Move.new("Stealth", Technique1)
	rogueMove.playAnimation = false
	rogueMove.noTargets = true
	rogueMove.reveals = false
	rogueMove.cooldown = 4
	rogueMove.icon = preload("res://Assets/Icons/Move/Rogue.png")
	Move.moves["Stealth"] = rogueMove
	
	var tamerMove = Move.new("Tame", Beastmastery1)
	tamerMove.playAnimation = false
	tamerMove.noTargets = true
	tamerMove.cooldown = 1
	tamerMove.icon = preload("res://Assets/Icons/Move/Tamer.png")
	Move.moves["Tame"] = tamerMove
	var tamerPassive = Passive.new("Forgotten Bond", TamerOnPassiveApply, TamerOnPassiveRemove, true)
	Passive.passives["Forgotten Bond"] = tamerPassive
	
	var alchemyMove = Move.new("Brew", Alchemy1)
	alchemyMove.playAnimation = false
	alchemyMove.manualEndTurn = true
	alchemyMove.noTargets = true
	alchemyMove.reveals = false
	alchemyMove.cooldown = 1
	alchemyMove.manualCooldown = true
	alchemyMove.manualOnMoveUse = true
	alchemyMove.icon = preload("res://Assets/Icons/Move/Alchemy.png")
	Move.moves["Brew"] = alchemyMove
	
	var machiningMove = Move.new("Tinker", Machining1)
	machiningMove.playAnimation = false
	machiningMove.manualEndTurn = true
	machiningMove.noTargets = true
	machiningMove.reveals = false
	machiningMove.cooldown = 1
	machiningMove.manualCooldown = true
	machiningMove.manualOnMoveUse = true
	machiningMove.icon = preload("res://Assets/Icons/Move/Machining.png")
	Move.moves["Tinker"] = machiningMove
	
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
		e.text.AddLine(e.GetLogName() + " ignited the ground!\n")
	elif id == 1:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Frost, e)
		e.text.AddLine(e.GetLogName() + " froze the ground!\n")
	elif id == 2:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Earth, e)
		e.text.AddLine(e.GetLogName() + " reinforced the earth!\n")
	elif id == 3:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Air, e)
		e.text.AddLine(e.GetLogName() + " called the wind!\n")
	e.animator.Attack()
	e.StartCooldownName("Unleash Elements")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.OnMoveUse.emit(e, null, "Unleash Elements")
	e.endTurn.emit()

#ARCANA
func Arcana1(g : Entity, t : Entity):
	if g.equipped == -1 || g.Type != "Player":
		return
	var e : Player = g
	var mods : Dictionary = e.GetItem(e.equipped).prefixes
	var r = 3 if "Air" in mods else 2
	var def = e.CheckDirection(e.facingPos - e.gridPos, r) if t == null else [t.gridPos, t]
	
	if def[1] == null:
		e.gridmap.SpawnProjectile(e, def[0], 3, preload("res://Assets/Moves/AspectedBlast.tscn"))
	else:
		e.gridmap.SpawnProjectileTarget(e, def[1], Arcana1Apply, 3, preload("res://Assets/Moves/AspectedBlast.tscn"))
		
func Arcana1Apply (g : Entity, t : Entity):
	if g.equipped == -1 || g.Type != "Player":
		return
	var e : Player = g
	var mods : Dictionary = e.GetItem(e.equipped).prefixes
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
	var damage = Stats.GetDamage(e.stats, t.stats, true, 2) if "Shadow" in mods else Stats.GetDamage(e.stats, t.stats, true)
	damage *= additiveMod
	e.text.AddLine(e.GetLogName() + " attacked " + t.GetLogName() + " with " + "Aspected Blast" +  " for " + LogText.GetDamageNum(int(damage), true) + " damage!" + "\n")
	t.animator.Damage()
	t.TakeDamage(damage, e)
	if "Radiant" in mods:
		e.Heal(damage * .25)
		e.text.AddLine("The radiant light healed " + e.GetLogName() + " for " + LogText.GetHealNum(int(damage * .25)) + " HP!" + "\n")
		
#ARMS
func Arms1(g : Entity, t : Entity):
	if g.Type != "Player":
		return
	var e : Player = g
	if e.equipped == -1:
		return
	await Equipment.WeaponCrit(e, t, e.inventoryUI.inventory[e.equipped].item, "Skilled Strike")
	
#TECHNIQUE
func Technique1(e : Entity, _t = null):
	e.AddStatus(Status.Stealth(), 3)
	e.text.AddLine(e.GetLogName() + " hid in the shadows!\n")

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
			t.nameColor = Color.LIME_GREEN
			t.Name = "Ally " + t.Name
			e.text.AddLine(t.GetLogName() + " was tamed!\n")
			t.Type = "Ally"
			e.allies.append(t)
			t.gridmap.minimap.Reveal(t.gridPos)
			t.tamer = e
			e.OnTame.emit(e, t)
		else:
			e.text.AddLine("Tame failed!\n")

func TameChance(t : Entity):
	var chance = randf_range(0, .5)
	var percentHealth = float(t.stats.HP) / float(t.stats.maxHP)
	var chanceIncrease = (1 - percentHealth)
	return (chance + chanceIncrease) > .5

func TamerOnPassiveApply(e : Entity):
	if e.Type == "Player":
		e.OnAllyDeath.connect(TamerOnAllyDeath)

func TamerOnPassiveRemove(e : Entity):
	if e.Type == "Player":
		e.OnAllyDeath.disconnect(TamerOnAllyDeath)

func TamerOnAllyDeath(p : Player, _e : Entity):
	p.StartCooldownName("Tame", 9)
	p.skillUI.UpdateAll()

#ALCHEMY
func Alchemy1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var e : Player = g
	e.action = false
	e.inventoryUI.craftCompleted.connect(CraftAlchemy)
	e.inventoryUI.CraftingOpen(e.classE.craftBrew)

func CraftAlchemy(e : Entity, item : Item):
	if e.Type == "Player":
		e.inventoryUI.craftCompleted.disconnect(CraftAlchemy)
		if item == null:
			return
		else:
			e.action = true
	e.text.AddLine(e.GetLogName() + " brewed 1 " + item.GetLogName() + ".\n")
	e.inventoryUI.AddItem(item)
	e.StartCooldownName("Brew")
	e.OnMoveUse.emit(e, null, "Brew")
	e.endTurn.emit()
	
#MACHINING
func Machining1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var e : Player = g
	e.action = false
	e.inventoryUI.craftCompleted.connect(CraftMachining)
	e.inventoryUI.CraftingOpen(e.classE.craftTinker)

func CraftMachining(e : Entity, item : Item):
	if e.Type == "Player":
		e.inventoryUI.craftCompleted.disconnect(CraftMachining)
		if item == null:
			return
		else:
			e.action = true
	e.text.AddLine(e.GetLogName() + " crafted 1 " + item.GetLogName() + ".\n")
	e.inventoryUI.AddItem(item)
	e.StartCooldownName("Tinker")
	e.OnMoveUse.emit(e, null, "Tinker")
	e.endTurn.emit()
