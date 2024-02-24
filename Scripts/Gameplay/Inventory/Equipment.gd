class_name Equipment
extends Item

var prefixes : Dictionary
var requiredProf : Classes.Proficiency = Classes.Proficiency.None
var critChance : float
var modified : bool = false

func SetEquipment(m : Move, prof : Classes.Proficiency, pf : Dictionary = {}, crit : float = 0):
	move = m
	requiredProf = prof
	move.name = GetLogName()
	prefixes = pf
	critChance = crit
	equipment = true

func GetDescription(_u : int = -1) -> String:
	var rs = "[indent][color=#" + Items.RarityColor(rarity).to_html() + "][b]"
	@warning_ignore("integer_division")
	rs += "[font_size=" + str((1100 / name.length())) + "]" + name + ":[/font_size]" if name.length() >= 20 else name + ":"
	rs += "[/b]"
	var num = 0
	rs += "[font_size=28]\n" + Items.Rarity.keys()[rarity]
	if prefixes.size() > 0:
		rs += " "
	for mod in prefixes.keys():
		rs += mod
		if num < prefixes.size() - 1:
			rs += ", "
		num += 1
	rs += " focus[/font_size]" if move.magic else " weapon[/font_size]"
	rs += "\n[font_size=32]CRIT: " + str(critChance * 100) + "%[/font_size][/color]\n"
	rs += "\n" + description
	if flavor != "":
		rs += "\n\n[i][font_size=24]" + flavor + "[/font_size][/i]"
	rs += "\n [/indent]"
	return rs

func Use(e : Entity, t : Entity, bonusCrit : float = 0):
	if randf() < critChance + bonusCrit:
		if move.magic:
			await Equipment.FocusCrit(e, t, self)
		else:
			await Equipment.WeaponCrit(e, t, self)
		e.endTurn.emit()
	else:
		await move.Use(e, t)

static func WeaponCrit(e : Entity, t : Entity, equipped : Equipment, movename = "", startingMod : float = 1):
	var mods : Dictionary = equipped.prefixes
	var targets : Array[Entity] = []
	if movename == "":
		movename = equipped.move.name
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
	if targets.size() < 1:
		e.animator.Attack()
		e.OnMoveUse.emit(e, null, movename)
		return
		
	e.text.AddLine(e.GetLogName() + " CRIT!\n")
	var additiveMod : float = startingMod
	if "Blitz" in mods:
		if e.lastAction == Move.ActionType.move:
			additiveMod += .4
		else:
			additiveMod += .1
	elif "Bold" in mods:
		if e.lastAction != Move.ActionType.move:
			additiveMod += .2
		else:
			additiveMod += .1
	if "Runed" in mods:
		additiveMod += .3
	
	await e.Wait(.3)
	for i in range(targets.size()):
		if "Bleed" in mods:
			targets[i].AddStatus(Status.Bleed(), 2)
		if "Crush" in mods:
			targets[i].AddStatus(Status.Stun(), 1)
		var damage = Stats.GetDamage(e.stats, targets[i].stats, false, 2) if "Bludgeon" in mods else Stats.GetDamage(e.stats, targets[i].stats)
		damage *= additiveMod
		e.Rotate(targets[i].gridPos)
		e.animator.Attack()
		if i > 0:
			e.text.AddLine(e.GetLogName() + " cleaved " + targets[i].GetLogName() + " with " + movename +  " for " + LogText.GetDamageNum(int(damage / 2)) + " damage!" + "\n")
			targets[i].animator.Damage()
			targets[i].TakeDamage(int(damage / 2), e)
		else:
			e.text.AddLine(e.GetLogName() + " attacked " + targets[i].GetLogName() + " with " + movename +  " for " + LogText.GetDamageNum(int(damage)) + " damage!" + "\n")
			targets[i].animator.Damage()
			targets[i].TakeDamage(damage, e)
		await e.Wait(.5)
	if is_instance_valid(targets[0]):
		e.OnMoveUse.emit(e, targets[0], movename)
	else:
		e.OnMoveUse.emit(e, null, movename)

static func FocusCrit(e : Entity, t : Entity, equipped : Equipment, movename = "", startingMod : float = 1):
	var mods : Dictionary = equipped.prefixes
	var additiveMod : float = startingMod
	var waittime = 0
	if movename == "":
		movename = equipped.move.name
	if t == null:
		if "Air" in mods:
			waittime = .5
			var target = e.CheckDirection(e.facingPos - e.gridPos, 2)
			if target[1] != null:
				t = target[1]
	elif !e.gridmap.NoCorners(e.gridPos, t.gridPos):
		e.animator.Attack()
		e.OnMoveUse.emit(e, null, movename)
		return
	
	if t == null:
		e.animator.Attack()
		e.OnMoveUse.emit(e, null, movename)
		return
		
	e.text.AddLine(e.GetLogName() + " CRIT!\n")
	await e.Wait(.3)
	if "Fire" in mods:
		t.AddStatus(Status.Burning(), 2)
	if "Frost" in mods:
		t.AddStatus(Status.Frost(), 3)
	if "Earth" in mods:
		t.AddStatus(Status.Bleed(), 3)
	if "Force" in mods:
		additiveMod += .2
	if "Lightning" in mods:
		t.AddStatus(Status.Paralysis(), 1)
	var damage = Stats.GetDamage(e.stats, t.stats, true, 2) if "Shadow" in mods else Stats.GetDamage(e.stats, t.stats, true)
	damage *= additiveMod
	e.text.AddLine(e.GetLogName() + " attacked " + t.GetLogName() + " with " + movename +  " for " + LogText.GetDamageNum(int(damage), true) + " damage!" + "\n")
	e.animator.Attack()
	await e.Wait(equipped.move.waittime)
	t.animator.Damage()
	t.TakeDamage(damage, e)
	if waittime > 0:
		await e.Wait(waittime)
	if "Radiant" in mods:
		var heal : int = e.Heal(ceili(.25 * damage))
		if heal > 0:
			e.text.AddLine("The radiant light healed " + e.GetLogName() + " for " + LogText.GetHealNum(heal) + " HP!" + "\n")
	if is_instance_valid(t):
		e.OnMoveUse.emit(e, t, movename)
	else:
		e.OnMoveUse.emit(e, null, movename)






