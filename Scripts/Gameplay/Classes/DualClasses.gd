class_name DualClasses
extends Node

func _ready():
	var druidMove = Move.new("Shapeshare", Druid1)
	druidMove.playAnimation = false
	druidMove.noTargets = true
	druidMove.cooldown = 5
	druidMove.icon = preload("res://Assets/Icons/Move/Druid.png")
	Move.moves["Shapeshare"] = druidMove
	Passive.passives["True to Form"] = Passive.new("True to Form", DruidPassiveApply, DruidPassiveRemove, true)
	
	var herbalistMove = Move.new("Forager's Bounty", Herbalist1)
	herbalistMove.playAnimation = false
	herbalistMove.manualEndTurn = true
	herbalistMove.noTargets = true
	herbalistMove.cooldown = 4
	herbalistMove.manualCooldown = true
	herbalistMove.icon = preload("res://Assets/Icons/Move/Herbalist.png")
	Move.moves["Forager's Bounty"] = herbalistMove
	
	var cutthroatMove = Move.new("Ambush", Cutthroat1)
	cutthroatMove.playAnimation = false
	cutthroatMove.cooldown = 2
	cutthroatMove.noTargets = true
	cutthroatMove.icon = preload("res://Assets/Icons/Move/Cutthroat.png")
	Move.moves["Ambush"] = cutthroatMove
	Passive.passives["Sneak Attack"] = Passive.new("Sneak Attack", CutthroatPassiveApply, CutthroatPassiveRemove)
	
	var wardenMove = Move.new("Wild Composure", Warden1)
	wardenMove.playAnimation = false
	wardenMove.cooldown = 9
	wardenMove.noTargets = true
	wardenMove.icon = preload("res://Assets/Icons/Move/Warden.png")
	Move.moves["Wild Composure"] = wardenMove
	Passive.passives["Combative Adaptation"] = Passive.new("Combative Adaptation", WardenPassiveApply, WardenPassiveRemove)
	
	var tunerMove = Move.new("Tune Up", Tuner1)
	tunerMove.playAnimation = false
	tunerMove.cooldown = 3
	tunerMove.noTargets = true
	tunerMove.icon = preload("res://Assets/Icons/Move/Tuner.png")
	Move.moves["Tune Up"] = tunerMove
	
	var rangerMove = Move.new("Hunter's Mark", Ranger1)
	rangerMove.manualEndTurn = true
	rangerMove.noTargets = true
	rangerMove.cooldown = 4
	rangerMove.icon = preload("res://Assets/Icons/Move/Ranger.png")
	Move.moves["Hunter's Mark"] = rangerMove
	Passive.passives["Shadow's Shadow"] = Passive.new("Shadow's Shadow", RangerPassiveApply, RangerPassiveRemove)
	
	var blighterMove = Move.new("Weapon Coating", Blighter1)
	blighterMove.playAnimation = false
	blighterMove.manualEndTurn = true
	blighterMove.noTargets = true
	blighterMove.cooldown = 9
	blighterMove.manualCooldown = true
	blighterMove.reveals = false
	blighterMove.icon = preload("res://Assets/Icons/Move/Blighter.png")
	Move.moves["Weapon Coating"] = blighterMove
	Passive.passives["Poison Proficiency"] = Passive.new("Poison Proficiency", BlighterPassiveApply, BlighterPassiveRemove)
	
	var thiefMove = Move.new("Pilfer", Thief1)
	thiefMove.cooldown = 2
	thiefMove.icon = preload("res://Assets/Icons/Move/Thief.png")
	Move.moves["Pilfer"] = thiefMove
	Passive.passives["Pickpocketing"] = Passive.new("Pickpocketing", ThiefPassiveApply, ThiefPassiveRemove)
	
	var scavengerMove = Move.new("Scour", Scavenger1)
	scavengerMove.noTargets = true
	scavengerMove.cooldown = 6
	scavengerMove.icon = preload("res://Assets/Icons/Move/Scavenger.png")
	Move.moves["Scour"] = scavengerMove
	Passive.passives["Resourcefulness"] = Passive.new("Resourcefulness", ScavengerPassiveApply, ScavengerPassiveRemove)
	
	Passive.passives["Combat Ingenuity"] = Passive.new("Combat Ingenuity", ArtificerPassiveApply, ArtificerPassiveRemove)
	
	Classes.LoadAllClasses()



#DRUID
#druid stat swapping is untested, test in detail when stat screen is implemented!
func Druid1(e : Entity, _t = null):
	if e.Type != "Player" || e.allies.size() < 1:
		e.text.AddLine(e.GetLogName() + " has no ally to shapeshare with!\n")
		return
		
	var transformMesh : Node3D = e.classE.classVariables["transformMesh"]
	if e.classE.classVariables["notOriginal"]:
		#assumes transformMesh has been initialized already
		e.mesh.get_node("Armature").visible = true
		transformMesh.visible = false
		e.animator = e.mesh.get_node("AnimationTree")
		e.originalStats = e.classE.classVariables["originalOriginalStats"]
		e.classE.classVariables["notOriginal"] = false
		e.text.AddLine(e.GetLogName() + " returned to their true form!\n")
	else:
		if transformMesh == null:
			transformMesh = e.allies[0].mesh.duplicate()
			transformMesh.rotation = Vector3.ZERO
			e.mesh.add_child(transformMesh)
			e.classE.classVariables["transformMesh"] = transformMesh
		e.mesh.get_node("Armature").visible = false
		transformMesh.visible = true
		e.animator = transformMesh.get_node("AnimationTree")
		e.originalStats = e.allies[0].originalStats
		e.classE.classVariables["notOriginal"] = true
		e.text.AddLine(e.GetLogName() + " assumed " + e.allies[0].Name + "'s form!\n")

func DruidPassiveApply(e : Entity):
	e.classE.classVariables["originalMesh"] = e.mesh
	e.classE.classVariables["originalOriginalStats"] = e.originalStats
	e.classE.classVariables["transformMesh"] = null
	e.classE.classVariables["notOriginal"] = false
	if e.Type == "Player":
		e.OnAllyDeath.connect(DruidOnAllyDeath)

func DruidPassiveRemove(e : Entity):
	e.classE.classVariables.erase("originalMesh")
	e.classE.classVariables.erase("originalOriginalStats")
	if e.classE.classVariables["transformMesh"] != null:
		e.classE.classVariables["transformMesh"].queue_free()
	e.classE.classVariables.erase("transformMesh")
	if e.classE.classVariables["notOriginal"]:
		e.mesh.get_node("Armature").visible = true
		e.animator = e.mesh.get_node("AnimationTree")
	e.classE.classVariables.erase("notOriginal")
	if e.Type == "Player":
		e.OnAllyDeath.disconnect(DruidOnAllyDeath)

func DruidOnAllyDeath(e : Player, t : Entity):
	if e.classE.classVariables["notOriginal"]:
		e.mesh.get_node("Armature").visible = true
		e.animator = e.mesh.get_node("AnimationTree")
		e.classE.classVariables["notOriginal"] = false
		e.text.AddLine(e.GetLogName() + " was forced into their true form after " + t.Name + "'s death!\n")
	if e.classE.classVariables["transformMesh"] != null:
		e.classE.classVariables["transformMesh"].queue_free()
		e.classE.classVariables["transformMesh"] = null
	
#HERBALIST
func Herbalist1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var items : Dictionary = {"Charshroom" : "Heat courses through your body, granting a POW buff when consumed.",
	"Windeelion" : "The refreshing taste focuses your mind, granting a MAG buff when consumed.",
	"Pebblepod" : "Reinforcing energies can be felt from the pods, granting a DEF buff when consumed.",
	"Tarrime Bloom" : "Sharp bitterness keeps you steadfast, granting a RES buff when consumed."}
	var e : Player = g
	e.action = false
	e.inventoryUI.craftCompleted.connect(HerbalistAttack)
	e.inventoryUI.PickerOpen(items)
	
func HerbalistAttack(e : Entity, item : Item):
	if e.Type == "Player":
		e.inventoryUI.craftCompleted.disconnect(HerbalistAttack)
		if item == null:
			return
		else:
			e.action = true
			
	var effect : Status
	var message : String
	if item.name == "Charshroom":
		effect = Status.AttackBuff()
		message = e.GetLogName() + " ate a charshroom and felt stronger!\n"
	elif item.name == "Windeelion":
		effect = Status.MagicBuff()
		message = e.GetLogName() + " ate a windeelion and felt more powerful!\n"
	elif item.name == "Pebblepod":
		effect = Status.DefenseBuff()
		message = e.GetLogName() + " ate a pebblepod and felt tougher!\n"
	elif item.name == "Tarrime Bloom":
		effect = Status.ResistenceBuff()
		message = e.GetLogName() + " ate a tarrime bloom and felt more resistant!\n"
	
	e.StartCooldownName("Forager's Bounty")
	e.AddStatus(effect, 3)
	e.text.AddLine(message)
	e.OnMoveUse.emit(e, null, "Forager's Bounty")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

#CUTTHROAT
func Cutthroat1(e : Entity, t : Entity):
	if e.equipped == -1:
		return
	if "Stealth" not in e.statuses:
		if t == null:
			return
		var damage = Stats.GetDamage(e.stats, t.stats)
		e.text.AddLine(e.GetLogName() + " attacked " + t.GetLogName() + " with Ambush for " + LogText.GetDamageNum(damage) + " damage!" + "\n")
		e.animator.Attack()
		await e.Wait(e.inventoryUI.inventory[e.equipped].item.move.waittime)
		t.animator.Damage()
		t.TakeDamage(damage, e)
		if is_instance_valid(t):
			e.OnMoveUse.emit(e, t, "Ambush")
		else:
			e.OnMoveUse.emit(e, null, "Ambush")
		return
	await Equipment.WeaponCrit(e, t, e.inventoryUI.inventory[e.equipped].item, "Ambush")

func CutthroatOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && e.equipped != 1 && movename == e.inventoryUI.inventory[e.equipped].item.move.name && "Stealth" in e.statuses.keys():
		var damage : int = int(Stats.GetDamage(e.stats, t.stats) / 2)
		if damage <= 0:
			damage = 1
		e.text.AddLine(t.GetLogName() + " was surprised and took " + LogText.GetDamageNum(damage) + " damage!\n")
		t.TakeDamage(damage, e)

func CutthroatPassiveApply(e : Entity):
	e.OnMoveUse.connect(CutthroatOnMoveUse)
	
func CutthroatPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(CutthroatOnMoveUse)

#WARDEN
func Warden1(e : Entity, _t : Entity):
	e.AddStatus(Status.SureCrit(), 10)
	if e.allies.size() > 0:
		e.allies[0].AddStatus(Status.SureCrit(), 10)
		e.text.AddLine(e.GetLogName() + " and " + e.allies[0].GetLogName() + " gained composure!\n")
	else:
		e.text.AddLine(e.GetLogName() + " gained composure!\n")

func WardenOnMoveUse(e : Entity, _t : Entity, movename : String):
	if "SureCrit" in e.statuses.keys() && e.equipped != 1 && movename == e.inventoryUI.inventory[e.equipped].item.move.name:
		e.RemoveStatus("SureCrit")

func WardenTameMove(e : Entity, t : Entity):
	if t == null:
		return
	if e.tamer.equipped == -1:
		await e.tamer.classE.classVariables[e.Name + "originalMove"].Use(e, t)
		return
	var chance = 1.1 if "SureCrit" in e.statuses.keys() else e.tamer.stats.CRIT + e.tamer.inventoryUI.inventory[e.tamer.equipped].item.critChance
	if randf() < chance:
		e.RemoveStatus("SureCrit")
		if e.tamer.inventoryUI.inventory[e.tamer.equipped].item.move.magic:
			await Equipment.FocusCrit(e, t, e.tamer.inventoryUI.inventory[e.tamer.equipped].item, e.moves[0].name)
		else:
			await Equipment.WeaponCrit(e, t, e.tamer.inventoryUI.inventory[e.tamer.equipped].item, e.moves[0].name)
	else:
		await e.tamer.classE.classVariables[e.Name + "originalMove"].Use(e, t)
		
func WardenOnTame(e : Entity, t : Entity):
	e.classE.classVariables[t.Name + "originalMove"] = t.moves[0]
	var newMove : Move = Move.new(t.moves[0].name, WardenTameMove)
	newMove.playAnimation = false
	t.moves[0] = newMove
	
func WardenOnAllyDeath(e : Entity, t : Entity):
	e.classE.classVariables.erase(t.Name + "originalMove")

func WardenPassiveApply(e : Entity):
	e.OnMoveUse.connect(WardenOnMoveUse)
	e.OnTame.connect(WardenOnTame)
	e.OnAllyDeath.connect(WardenOnAllyDeath)
	
func WardenPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(WardenOnMoveUse)
	e.OnTame.disconnect(WardenOnTame)
	e.OnAllyDeath.disconnect(WardenOnAllyDeath)
	#this solution will NOT work for Warden + Summoner, look into better solution
	for ally in e.allies:
		ally.moves[0] = e.classE.classVariables[ally.Name + "originalMove"]
		e.classE.classVariables.erase(ally.Name + "originalMove")
		
#TUNER
func Tuner1(e : Entity, _t : Entity):
	var healing = e.stats.CRIT
	if e.equipped != -1:
		healing += e.inventoryUI.inventory[e.equipped].item.critChance
	healing = floorf(e.stats.maxHP * healing)
	var actualHeal : int = e.Heal(healing)
	if actualHeal > 0:
		e.text.AddLine(e.GetLogName() + " was tuned up for " + LogText.GetHealNum(actualHeal) + " HP!\n")

#RANGER
func Ranger1(e : Entity, t : Entity):
	var def = e.CheckDirection(e.facingPos - e.gridPos, 5) if t == null else [t.gridPos, t]
	if def[1] == null:
		e.gridmap.SpawnProjectile(e, def[0], 5, preload("res://Assets/Moves/HuntersMark.tscn"))
	else:
		e.gridmap.SpawnProjectileTarget(e, def[1], RangerApply, 5, preload("res://Assets/Moves/HuntersMark.tscn"))

func RangerApply(e : Entity, t : Entity):
	var damage = int(Stats.GetDamage(e.stats, t.stats) / 2)
	e.text.AddLine(t.GetLogName() + " was marked for " + LogText.GetDamageNum(damage) + " damage!\n")
	t.AddStatus(Status.DefResDebuff(), 3)
	t.animator.Damage()
	t.TakeDamage(damage)
	
func RangerOnMoveUse(e : Entity, _t : Entity, movename : String):
	if e.Type == "Player" && e.allies.size() > 0 && movename == "Stealth":
		e.allies[0].AddStatus(Status.Stealth(), 3)

func RangerPassiveApply(e : Entity):
	e.OnMoveUse.connect(RangerOnMoveUse)
	
func RangerPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(RangerOnMoveUse)

#BLIGHTER
func Blighter1(g : Entity, _t : Entity):
	if g.equipped == -1:
		g.text.AddLine(g.GetLogName() + " has no weapon equipped to coat!\n")
		g.OnMoveUse.emit(g, null, "Weapon Coating")
		g.endTurn.emit()
		return
	var items : Dictionary = {"Flamefroth Tincture" : "Ingesting half the tincture and coating a weapon with the rest seems to be more efficient than either method on their own.",
	"Paralysis Draught" : "With how effective the draught is on its own, applying it to a weapon is a no-brainer.",
	"Blighter's Brew" : "Turn any weapon into a spiky maker of pincushions."}
	var e : Player = g
	e.action = false
	e.inventoryUI.craftCompleted.connect(BlighterAttack)
	e.inventoryUI.PickerOpen(items)

func BlighterAttack(e : Entity, item : Item):
	if e.Type == "Player":
		e.inventoryUI.craftCompleted.disconnect(BlighterAttack)
		if item == null:
			return
		else:
			e.action = true
			
	e.classE.classVariables["coatMove"] = item.move
	e.classE.classVariables["coatUses"] = 2
	e.StartCooldownName("Weapon Coating")
	e.text.AddLine(e.GetLogName() + " applyed a " + item.name + " to their weapon!\n")
	e.OnMoveUse.emit(e, null, "Weapon Coating")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

func BlighterOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && e.equipped != 1 && movename == e.inventoryUI.inventory[e.equipped].item.move.name && e.classE.classVariables["coatMove"] != null:
		e.classE.classVariables["coatMove"].attackEffects.call(e, t)
		e.classE.classVariables["coatUses"] -= 1
		if e.classE.classVariables["coatUses"] <= 0:
			e.classE.classVariables["coatMove"] = null

func BlighterPassiveApply(e : Entity):
	e.OnMoveUse.connect(BlighterOnMoveUse)
	e.classE.classVariables["coatMove"] = null
	e.classE.classVariables["coatUses"] = 0
	
func BlighterPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(BlighterOnMoveUse)
	e.classE.classVariables.erase("coatMove")
	e.classE.classVariables.erase("coatUses")

#THIEF
func Thief1(e : Entity, t : Entity):
	var pierce : int = 2 if t.inventory.size() == 0 else 0
	var damage : int = Stats.GetDamage(e.stats, t.stats, false, pierce)
	e.text.AddLine(e.GetLogName() + " attacked " + t.GetLogName() + " with Pilfer for " + LogText.GetDamageNum(damage) + " damage!" + "\n")
	t.TakeDamage(damage, e)
	
func ThiefOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && e.equippedMove != null && movename == e.equippedMove.name && "Stealth" in e.statuses.keys() && t.inventory.size() > 0:
		var removeSpot = randi_range(0, t.inventory.size() - 1)
		var item : Item = t.inventory[removeSpot]
		if e.IsInventoryFull():
			e.gridmap.PlaceItem(t.gridPos, item)
			e.text.AddLine(item.name + " fell to the floor!\n")
		else:
			e.inventoryUI.AddItem(item)
			e.text.AddLine(e.GetLogName() + " stole " + item.name + "!\n")
		t.RemoveItemAt(removeSpot)
		
func ThiefPassiveApply(e : Entity):
	e.OnMoveUse.connect(ThiefOnMoveUse)
	
func ThiefPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ThiefOnMoveUse)

#SCAVENGER
func Scavenger1(g : Entity, t : Entity):
	if g.Type != "Player":
		return
	var e : Player = g
	var tame : Entity = e.allies[0] if e.allies.size() > 0 else null
	var itemchance : float = 0
	var potentialItems
	if t != null && t.Type != "Ally":
		itemchance = .15
		potentialItems = Loader.GetEnemyData(t.Name)["drops"]
		var pierce = 0
		if tame != null:
			tame.animator.Attack()
			tame.Rotate(t.gridPos)
			itemchance += .1
			pierce = 2
		var damage : int = Stats.GetDamage(e.stats, t.stats, false, pierce)
		e.text.AddLine(e.GetLogName() + " scoured " + t.GetLogName() + " for " + LogText.GetDamageNum(damage) + " damage!" + "\n")
		t.animator.Damage()
		t.TakeDamage(damage, e)
	else:
		potentialItems = e.gridmap.level.materials
		if tame != null:
			tame.animator.Attack()
			tame.Rotate(e.facingPos)
			itemchance = .05
	
	if randf_range(0, 1) < itemchance:
		e.text.AddLine(e.GetLogName() + " found an item while scavenging!\n")
		var placePos = e.facingPos if e.gridmap.GetMapPos(e.facingPos) != -2 else e.gridPos
		e.gridmap.PlaceItem(placePos, Items.items[potentialItems[randi_range(0, potentialItems.size() - 1)]])
	else:
		e.text.AddLine(e.GetLogName() + " didn't find anything!\n")

func ScavengerPassiveApply(e : Entity):
	if "notConsumeMaterialPassives" in e.classE.classVariables:
		e.classE.classVariables["notConsumeMaterialPassives"] += 1
		e.classE.classVariables["notConsumeMaterialChance"] += .15
	else:
		e.classE.classVariables["notConsumeMaterialPassives"] = 1
		e.classE.classVariables["notConsumeMaterialChance"] = .15
		
func ScavengerPassiveRemove(e : Entity):
	e.classE.classVariables["notConsumeMaterialPassives"] -= 1
	e.classE.classVariables["notConsumeMaterialChance"] -= .15
	if e.classE.classVariables["notConsumeMaterialPassives"] < 1:
		e.classE.classVariables.erase("notConsumeMaterialChance")
		e.classE.classVariables.erase("notConsumeMaterialPassives")
		
#ARTIFICER
func ArtificerOnMoveUse(e : Entity, _t : Entity, movename : String):
	if movename == "Tinker":
		e.AddStatus(Status.AttackBuff(), 3)
		e.AddStatus(Status.DefenseBuff(), 3)
		return
	elif movename == "Brew":
		e.AddStatus(Status.MagicBuff(), 3)
		e.AddStatus(Status.ResistenceBuff(), 3)
		
func ArtificerPassiveApply(e : Entity):
	e.OnMoveUse.connect(ArtificerOnMoveUse)
	
func ArtificerPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ArtificerOnMoveUse)
	
	
	
	
	
	
