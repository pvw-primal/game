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
	cutthroatMove.cooldown = 2
	cutthroatMove.noTargets = true
	cutthroatMove.icon = preload("res://Assets/Icons/Move/Cutthroat.png")
	Move.moves["Ambush"] = cutthroatMove
	Passive.passives["Sneak Attack"] = Passive.new("Sneak Attack", CutthroatPassiveApply, CutthroatPassiveRemove)
	
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
	
	Passive.passives["Combat Ingenuity"] = Passive.new("Combat Ingenuity", ArtificerPassiveApply, ArtificerPassiveRemove)
	
	Classes.LoadAllClasses()

#DRUID
#druid stat swapping is untested, test in detail when stat screen is implemented!
func Druid1(e : Entity, _t = null):
	if e.Type != "Player" || e.allies.size() < 1:
		e.text.AddLine(e.Name + " has no ally to shapeshare with!\n")
		return
		
	var transformMesh : Node3D = e.classE.classVariables["transformMesh"]
	if e.classE.classVariables["notOriginal"]:
		#assumes transformMesh has been initialized already
		e.mesh.get_node("Armature").visible = true
		transformMesh.visible = false
		e.animator = e.mesh.get_node("AnimationTree")
		e.originalStats = e.classE.classVariables["originalOriginalStats"]
		e.classE.classVariables["notOriginal"] = false
		e.text.AddLine(e.Name + " returned to their true form!\n")
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
		e.text.AddLine(e.Name + " assumed " + e.allies[0].Name + "'s form!\n")

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
		e.text.AddLine(e.Name + " was forced into their true form after " + t.Name + "'s death!\n")
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
		message = e.Name + " ate a charshroom and felt stronger!\n"
	elif item.name == "Windeelion":
		effect = Status.MagicBuff()
		message = e.Name + " ate a windeelion and felt more powerful!\n"
	elif item.name == "Pebblepod":
		effect = Status.DefenseBuff()
		message = e.Name + " ate a pebblepod and felt tougher!\n"
	elif item.name == "Tarrime Bloom":
		effect = Status.ResistenceBuff()
		message = e.Name + " ate a tarrime bloom and felt more resistant!\n"
	
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
		e.text.AddLine(e.Name + " attacked " + t.Name + " with Ambush for " + str(damage) + " damage!" + "\n")
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
			e.text.AddLine(e.Name + " cleaved " + targets[i].Name + " with Ambush for " + str(int(damage / 2)) + " damage!" + "\n")
			targets[i].animator.Damage()
			targets[i].TakeDamage(int(damage / 2), e)
		else:
			e.text.AddLine(e.Name + " ambushed " + targets[i].Name + " for " + str(int(damage)) + " damage!" + "\n")
			targets[i].animator.Damage()
			targets[i].TakeDamage(damage, e)
		await e.Wait(.5)

func CutthroatOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && e.equippedMove != null && movename == e.equippedMove.name && "Stealth" in e.statuses.keys():
		var damage : int = int(Stats.GetDamage(e.stats, t.stats) / 2)
		if damage <= 0:
			damage = 1
		e.text.AddLine(t.Name + " was surprised and took " + str(damage) + " damage!\n")
		t.TakeDamage(damage, e)

func CutthroatPassiveApply(e : Entity):
	e.OnMoveUse.connect(CutthroatOnMoveUse)
	
func CutthroatPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(CutthroatOnMoveUse)

#RANGER
func Ranger1(e : Entity, t : Entity):
	var def = e.CheckDirection(e.facingPos - e.gridPos, 5) if t == null else [t.gridPos, t]
	if def[1] == null:
		e.gridmap.SpawnProjectile(e, def[0], 3, preload("res://Assets/Items/Alchemy/HealingPotion.tscn"))
	else:
		e.gridmap.SpawnProjectileTarget(e, def[1], RangerApply, 3, preload("res://Assets/Items/Alchemy/HealingPotion.tscn"))

func RangerApply(e : Entity, t : Entity):
	var damage = int(Stats.GetDamage(e.stats, t.stats) / 2)
	e.text.AddLine(t.Name + " was marked for " + str(damage) + " damage!\n")
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
		g.text.AddLine(g.Name + " has no weapon equipped to coat!\n")
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
	e.text.AddLine(e.Name + " applyed a " + item.name + " to their weapon!\n")
	e.OnMoveUse.emit(e, null, "Weapon Coating")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

func BlighterOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && e.equippedMove != null && movename == e.equippedMove.name && e.classE.classVariables["coatMove"] != null:
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
	e.text.AddLine(e.Name + " attacked " + t.Name + " with Pilfer for " + str(damage) + " damage!" + "\n")
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
			e.text.AddLine(e.Name + " stole " + item.name + "!\n")
		t.RemoveItemAt(removeSpot)
		
func ThiefPassiveApply(e : Entity):
	e.OnMoveUse.connect(ThiefOnMoveUse)
	
func ThiefPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ThiefOnMoveUse)

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
	
	
	
	
	
	
