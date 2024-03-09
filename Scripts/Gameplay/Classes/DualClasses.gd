class_name DualClasses
extends Node

func _ready():
	var sorcererMove = Move.new("Sorcery", Sorcerer1)
	sorcererMove.playAnimation = false
	sorcererMove.manualEndTurn = true
	sorcererMove.noTargets = true
	sorcererMove.cooldown = 4
	sorcererMove.manualCooldown = true
	sorcererMove.manualOnMoveUse = true
	sorcererMove.icon = preload("res://Assets/Icons/Move/Sorcerer.png")
	sorcererMove.description = "Place a Force, Lightning, Radiant, or Shadow field effect."
	Move.moves["Sorcery"] = sorcererMove
	var sorcererPassive = Passive.new("Specialized Evocation", SorcererPassiveApply, SorcererPassiveRemove)
	sorcererPassive.description = "Placing a field effect that shares an aspect with your equipped focus using Unleash Elements or Sorcery lowers that skill's cooldown by 1."
	Passive.passives["Specialized Evocation"] = sorcererPassive
	
	var outcastMove = Move.new("Honed Ferocity", Outcast1)
	outcastMove.playAnimation = false
	outcastMove.noTargets = true
	outcastMove.cooldown = 4
	outcastMove.icon = preload("res://Assets/Icons/Move/Outcast.png")
	outcastMove.description = "Gain 50% CRIT. If you are in a field effect, spread a debuff to all nearby enemies."
	Move.moves["Honed Ferocity"] = outcastMove
	var outcastPassive = Passive.new("Natural Armor", OutcastPassiveApply, OutcastPassiveRemove)
	outcastPassive.description = "Gain immunity to Burning and Frostbite."
	Passive.passives["Natural Armor"] = outcastPassive
	
	var wildenMove = Move.new("Smokescreen", Wilden1)
	wildenMove.noTargets = true
	wildenMove.cooldown = 4
	wildenMove.icon = preload("res://Assets/Icons/Move/Wilden.png")
	wildenMove.description = "Place a Smoke field effect. (Smoke has no effects on its own.)"
	Move.moves["Smokescreen"] = wildenMove
	var wildenPassive = Passive.new("Wild Cloak", WildenPassiveApply, WildenPassiveRemove)
	wildenPassive.description = "Entering a field effect consumes it and grants a buff depending on the type consumed."
	Passive.passives["Wild Cloak"] = wildenPassive
	
	var druidMove = Move.new("Shapeshare", Druid1)
	druidMove.playAnimation = false
	druidMove.noTargets = true
	druidMove.cooldown = 5
	druidMove.icon = preload("res://Assets/Icons/Move/Druid.png")
	druidMove.description = "Shapeshift into a copy of your tame. If any of their stats are higher than yours, gain them. Activate again to change back."
	Move.moves["Shapeshare"] = druidMove
	Passive.passives["True to Form"] = Passive.new("True to Form", DruidPassiveApply, DruidPassiveRemove, true)
	
	var herbalistMove = Move.new("Forager's Bounty", Herbalist1)
	herbalistMove.playAnimation = false
	herbalistMove.manualEndTurn = true
	herbalistMove.noTargets = true
	herbalistMove.cooldown = 2
	herbalistMove.manualCooldown = true
	herbalistMove.icon = preload("res://Assets/Icons/Move/Herbalist.png")
	herbalistMove.description = "Eat a gathered plant, gaining a significant buff to a stat depending on the plant eaten."
	Move.moves["Forager's Bounty"] = herbalistMove
	var herbalistPassive = Passive.new("Herbology")
	herbalistPassive.description = "Brew gains the ability to craft Blooming Brews, which grow plants in areas with field effects."
	Passive.passives["Herbology"] = herbalistPassive
	var bloommove = Move.new("Blooming Brew", HerbalistItem)
	bloommove.noTargets = true
	Move.moves["Blooming Brew"] = bloommove
	
	var totemcarverMove = Move.new("Whittle Carve", Totemcarver1)
	totemcarverMove.cooldown = 4
	totemcarverMove.icon = preload("res://Assets/Icons/Move/Totemcarver.png")
	totemcarverMove.description = "Attack with a carving tool; enemies struck have a chance to drop material, totems struck spread field effects."
	Move.moves["Whittle Carve"] = totemcarverMove
	var totemcarverItemMove = Move.new("Totemic Surge", TotemcarverItemMove)
	totemcarverItemMove.playAnimation = false
	totemcarverItemMove.noTargets = true
	Move.moves["Totemic Surge"] = totemcarverItemMove
	var totemcarverPassive = Passive.new("Totemcraft")
	totemcarverPassive.description = "Tinker gains the ability to craft Totems, immobile structures that spread field effects."
	Passive.passives["Totemcraft"] = totemcarverPassive
	
	var warcasterMove = Move.new("Expert's Stance", WarCaster1)
	warcasterMove.playAnimation = false
	warcasterMove.noTargets = true
	warcasterMove.cooldown = 3
	warcasterMove.manualEndTurn = true
	warcasterMove.manualOnMoveUse = true
	warcasterMove.manualCooldown = true
	warcasterMove.icon = preload("res://Assets/Icons/Move/WarCaster.png")
	warcasterMove.description = "Quickly swap from a weapon to a focus or vice versa. (Does not use action.)"
	Move.moves["Expert's Stance"] = warcasterMove
	var warcasterPassive = Passive.new("All-Rounder", WarCasterPassiveApply, WarCasterPassiveRemove)
	warcasterPassive.description = "While using a focus, Skilled Strike grants a MAG buff. While using a weapon, Aspected Blast grants a POW buff."
	Passive.passives["All-Rounder"] = warcasterPassive
	
	var tricksterMove = Move.new("Invoke Duplicity", Trickster1)
	tricksterMove.playAnimation = false
	tricksterMove.noTargets = true
	tricksterMove.reveals = true
	tricksterMove.cooldown = 8
	tricksterMove.icon = preload("res://Assets/Icons/Move/Trickster.png")
	tricksterMove.description = "Summon an illusion that distracts foes."
	Move.moves["Invoke Duplicity"] = tricksterMove
	var tricksterPassive = Passive.new("Impersonal Mischief", TricksterPassiveApply, TricksterPassiveRemove)
	tricksterPassive.description = "Using Stealth while facing an enemy teleports behind them. (Nothing personnel.)"
	Passive.passives["Impersonal Mischief"] = tricksterPassive
	
	var summonerMove = Move.new("Summon", Summoner1)
	summonerMove.playAnimation = false
	summonerMove.noTargets = true
	summonerMove.cooldown = 4
	summonerMove.icon = preload("res://Assets/Icons/Move/Summoner.png")
	summonerMove.description = "Recall your active tame for another, which attacks immediately if able."
	Move.moves["Summon"] = summonerMove
	var summonerPassive = Passive.new("Pocket Conjuring", SummonerPassiveApply, SummonerPassiveRemove)
	summonerPassive.description = "You can have up to 2 tames. (Only 1 can be active at a time.)"
	Passive.passives["Pocket Conjuring"] = summonerPassive
	
	var transmuterMove = Move.new("Conversion Alchemy", Transmuter1)
	transmuterMove.playAnimation = false
	transmuterMove.manualEndTurn = true
	transmuterMove.noTargets = true
	transmuterMove.cooldown = 3
	transmuterMove.manualCooldown = true
	transmuterMove.icon = preload("res://Assets/Icons/Move/Transmuter.png")
	transmuterMove.description = "Transmute a material into earthen spikes or soothing shadow."
	Move.moves["Conversion Alchemy"] = transmuterMove
	var transmuterItemMove = Move.new("Transmuter's Stone", TransmuterItemMove)
	transmuterItemMove.playAnimation = false
	transmuterItemMove.noTargets = true
	transmuterItemMove.manualEndTurn = true
	transmuterItemMove.manualCooldown = true
	Move.moves["Transmuter's Stone"] = transmuterItemMove
	var transmuterPassive = Passive.new("Equivalent Exchange")
	transmuterPassive.description = "Brew gains the ability to craft Transmuter's Stones, which convert weapons or foci into materials."
	Passive.passives["Equivalent Exchange"] = transmuterPassive
	
	var enchanterMove = Move.new("Disenchanting Surge", Enchanter1)
	enchanterMove.playAnimation = false
	enchanterMove.manualOnMoveUse = true
	enchanterMove.noTargets = true
	enchanterMove.cooldown = 1
	enchanterMove.icon = preload("res://Assets/Icons/Move/Enchanter.png")
	enchanterMove.description = "Strip your equipped foci of all aspects, dealing increased damage for each."
	Move.moves["Disenchanting Surge"] = enchanterMove
	var enchanterItemMove = Move.new("Change Aspect", ChangeAspect1)
	enchanterItemMove.playAnimation = false
	enchanterItemMove.noTargets = true
	enchanterItemMove.manualEndTurn = true
	enchanterItemMove.manualCooldown = true
	Move.moves["Change Aspect"] = enchanterItemMove
	var enchanterPassive = Passive.new("Aspect Enchantment")
	enchanterPassive.description = "Foci can have 2 aspects rather than 1. Tinker gains the ability to craft Enchanted Attuners, which can add basic foci aspects."
	Passive.passives["Aspect Enchantment"] = enchanterPassive
	
	var cutthroatMove = Move.new("Ambush", Cutthroat1)
	cutthroatMove.playAnimation = false
	cutthroatMove.cooldown = 2
	cutthroatMove.noTargets = true
	cutthroatMove.icon = preload("res://Assets/Icons/Move/Cutthroat.png")
	cutthroatMove.description = "Strike from the shadows. If attacking from Stealth, this is a guaranteed CRIT."
	Move.moves["Ambush"] = cutthroatMove
	var cutPassive = Passive.new("Sneak Attack", CutthroatPassiveApply, CutthroatPassiveRemove)
	cutPassive.description = "Regular attacking from Stealth deals additional magic damage."
	Passive.passives["Sneak Attack"] = cutPassive
	
	var wardenMove = Move.new("Wild Composure", Warden1)
	wardenMove.playAnimation = false
	wardenMove.cooldown = 9
	wardenMove.noTargets = true
	wardenMove.icon = preload("res://Assets/Icons/Move/Warden.png")
	wardenMove.description = "You and your tame's next regular attack is a guaranteed CRIT."
	Move.moves["Wild Composure"] = wardenMove
	var wardenPassive = Passive.new("Combative Adaptation", WardenPassiveApply, WardenPassiveRemove)
	wardenPassive.description = "Your tames gain the ability to CRIT. The chance and effect are the same as yours."
	Passive.passives["Combative Adaptation"] = wardenPassive
	
	var tunerMove = Move.new("Tune Up", Tuner1)
	tunerMove.playAnimation = false
	tunerMove.cooldown = 3
	tunerMove.noTargets = true
	tunerMove.icon = preload("res://Assets/Icons/Move/Tuner.png")
	tunerMove.description = "Heal a percentage of your health equal to your CRIT chance."
	Move.moves["Tune Up"] = tunerMove
	var tunerPassive = Passive.new("Synthetic Honing")
	tunerPassive.description = "Brew gains the ability to craft Whetstone Oil, which increases CRIT chance by 50% for the next 3 turns."
	Passive.passives["Synthetic Honing"] = tunerPassive
	
	var weaponsmithMove = Move.new("Abrading Assault", Weaponsmith1)
	weaponsmithMove.playAnimation = false
	weaponsmithMove.manualOnMoveUse = true
	weaponsmithMove.noTargets = true
	weaponsmithMove.cooldown = 1
	weaponsmithMove.icon = preload("res://Assets/Icons/Move/Weaponsmith.png")
	weaponsmithMove.description = "Erode your weapon of all modifiers, dealing damage for each."
	Move.moves["Abrading Assault"] = weaponsmithMove
	var weaponsmithItemMove = Move.new("Change Modifier", ChangeModifier1)
	weaponsmithItemMove.playAnimation = false
	weaponsmithItemMove.noTargets = true
	weaponsmithItemMove.manualEndTurn = true
	weaponsmithItemMove.manualCooldown = true
	Move.moves["Change Modifier"] = weaponsmithItemMove
	var wsPassive = Passive.new("Modulation")
	wsPassive.description = "Weapons can have 2 modifiers rather than 1. Tinker gains the ability to craft Smithing Gear, which can add basic weapon modifiers."
	Passive.passives["Modulation"] = wsPassive
	
	var rangerMove = Move.new("Hunter's Mark", Ranger1)
	rangerMove.manualEndTurn = true
	rangerMove.noTargets = true
	rangerMove.cooldown = 4
	rangerMove.icon = preload("res://Assets/Icons/Move/Ranger.png")
	rangerMove.description = "Shoot an arrow, inflicting a debuff to DEF and RES for 3 turns."
	Move.moves["Hunter's Mark"] = rangerMove
	var rangerPassive = Passive.new("Shadow's Shadow", RangerPassiveApply, RangerPassiveRemove)
	rangerPassive.description = "Whenever you gain Stealth, your tame also gains Stealth."
	Passive.passives["Shadow's Shadow"] = rangerPassive
	
	var blighterMove = Move.new("Weapon Coating", Blighter1)
	blighterMove.playAnimation = false
	blighterMove.manualEndTurn = true
	blighterMove.noTargets = true
	blighterMove.cooldown = 9
	blighterMove.manualCooldown = true
	blighterMove.reveals = false
	blighterMove.icon = preload("res://Assets/Icons/Move/Blighter.png")
	blighterMove.description = "Coat a weapon with a brew, applying its effects to the next 2 weapon attacks. (Only 1 coating can be applied at a time.)"
	Move.moves["Weapon Coating"] = blighterMove
	var blighterPassive = Passive.new("Poison Proficiency", BlighterPassiveApply, BlighterPassiveRemove)
	blighterPassive.description = "Brew gains the ability to craft Blighter's Brews, which deal 3 true damage."
	Passive.passives["Poison Proficiency"] = blighterPassive
	Move.moves["Blighter's Brew"] = Move.new("Blighter's Brew", BlighterItem)
	
	var thiefMove = Move.new("Pilfer", Thief1)
	thiefMove.cooldown = 2
	thiefMove.icon = preload("res://Assets/Icons/Move/Thief.png")
	thiefMove.description = "Strike, dealing additional damage if the enemy's inventory is empty."
	Move.moves["Pilfer"] = thiefMove
	var thiefPassive = Passive.new("Pickpocketing", ThiefPassiveApply, ThiefPassiveRemove)
	thiefPassive.description = "Attacking from Stealth steals an item from the enemy's inventory."
	Passive.passives["Pickpocketing"] = thiefPassive
	
	var imbuerMove = Move.new("Renewed Vigor", Imbuer1)
	imbuerMove.cooldown = 2
	imbuerMove.icon = preload("res://Assets/Icons/Move/Imbuer.png")
	imbuerMove.description = "Lash out, extending the duration of stat buffs on you and your tame when striking enemies."
	Move.moves["Renewed Vigor"] = imbuerMove
	var imbuerPassive = Passive.new("Alchemical Bond", ImbuerPassiveApply, ImbuerPassiveRemove)
	imbuerPassive.description = "Brew gains the ability to craft Imbued Wilds, which heal and grant random stat buffs."
	Passive.passives["Alchemical Bond"] = imbuerPassive
	var imbuerItemMove = Move.new("Imbued Wilds", ImbuerItemMove)
	imbuerItemMove.noTargets = true
	imbuerItemMove.playAnimation = false
	Move.moves["Imbued Wilds"] = imbuerItemMove
	
	var scavengerMove = Move.new("Scour", Scavenger1)
	scavengerMove.noTargets = true
	scavengerMove.cooldown = 6
	scavengerMove.icon = preload("res://Assets/Icons/Move/Scavenger.png")
	scavengerMove.description = "Search for resources with your tame, potentially finding hidden items."
	Move.moves["Scour"] = scavengerMove
	var scavengerPassive = Passive.new("Resourcefulness", ScavengerPassiveApply, ScavengerPassiveRemove)
	scavengerPassive.description = "Materials have a chance to not be consumed when crafting."
	Passive.passives["Resourcefulness"] = scavengerPassive
	
	var artificerMove = Move.new("Mechanical User", Artificer1)
	artificerMove.playAnimation = false
	artificerMove.manualEndTurn = true
	artificerMove.noTargets = true
	artificerMove.cooldown = 9
	artificerMove.manualCooldown = true
	artificerMove.icon = preload("res://Assets/Icons/Move/Artificert.png")
	artificerMove.description = "Construct a simulacrum of yourself, which can use consumable items."
	Move.moves["Mechanical User"] = artificerMove
	var artificerPassive = Passive.new("Combat Ingenuity", ArtificerPassiveApply, ArtificerPassiveRemove)
	artificerPassive.description = "Tinker grants a DEF and RES buff on use, and Brew grants a POW and MAG buff on use."
	Passive.passives["Combat Ingenuity"] = artificerPassive
	
	Classes.LoadAllClasses()

#SORCERER
var SorcererOptions : Array[String] = ["Force", "Lightning", "Radiant", "Shadow"]
func Sorcerer1(e : Entity, _t = null):
	if e.Type == "Player":
		e.option.OptionSelected.connect(SorcererAttack)
		e.option.Open(SorcererOptions)
	else:
		SorcererAttack(e, 0)
		
func SorcererAttack(e : Entity, id : int):
	if e.Type == "Player":
		e.option.OptionSelected.disconnect(SorcererAttack)
		if id == -1:
			e.Start.call_deferred()
			return
	if id == 0:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Force, e)
		e.text.AddLine(e.GetLogName() + " intensified gravity!\n")
	elif id == 1:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Lightning, e)
		e.text.AddLine(e.GetLogName() + " charged the area!\n")
	elif id == 2:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Radiant, e)
		e.text.AddLine(e.GetLogName() + " sanctified the ground!\n")
	elif id == 3:
		e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Shadow, e)
		e.text.AddLine(e.GetLogName() + " summoned darkness!\n")
	e.animator.Attack()
	e.StartCooldownName("Sorcery")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.OnMoveUse.emit(e, null, "Sorcery")
	e.endTurn.emit()

func SorcererOnMoveUse(e : Entity, _t : Entity, movename : String):
	if e.Type == "Player" && (movename == "Sorcery" || movename == "Unleash Elements") && e.equipped != -1 && e.facingPos in e.gridmap.tileEffects:
		var equipped : Equipment = e.GetItem(e.equipped)
		var effect : TileEffect.Effect = e.gridmap.tileEffects[e.facingPos].effect
		if TileEffect.Effect.keys()[effect] in equipped.prefixes:
			e.StartCooldownName(movename, Move.moves[movename].cooldown - 1)

func SorcererPassiveApply(e : Entity):
	e.OnMoveUse.connect(SorcererOnMoveUse)

func SorcererPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(SorcererOnMoveUse)

#OUTCAST
func Outcast1(e : Entity, _t = null):
	e.AddStatus(Status.CritBuff(), 3)
	e.text.AddLine(e.GetLogName() + " focused their ferocity!\n")
	if e.gridPos not in e.gridmap.tileEffects:
		return
	var effect : TileEffect.Effect = e.gridmap.tileEffects[e.gridPos].effect
	var status : Status
	var message : String
	match effect:
		TileEffect.Effect.Fire:
			status = Status.Burning()
			message = " were scorched!\n"
		TileEffect.Effect.Frost:
			status = Status.Frost()
			message = " were frozen over!\n"
		TileEffect.Effect.Earth:
			status = Status.Bleed()
			message = " were bombarded by earth!\n"
		TileEffect.Effect.Air:
			status = Status.DefResDebuff()
			message = " were buffeted by the wind!\n"
		_:
			status = Status.Paralysis()
			message = " were petrified with arcane power!\n"
	var show : bool = false
	for pos in e.AdjacentTiles():
		var entity : Entity = e.GetEntity(pos)
		if entity != null && entity.Type == "AI":
			show = true
			entity.AddStatus(status, 3)
	if show:
		e.text.AddLine(e.GetLogName() + "'s surroundings" + message)
	e.gridmap.RemoveTileEffect(e.gridPos)
	
func OutcastPassiveApply(e : Entity):
	e.immune["Burning"] = null
	e.immune["Frostbite"] = null

func OutcastPassiveRemove(e : Entity):
	#reevaluate if/when new immunities are added
	e.immune.erase("Burning")
	e.immune.erase("Frostbite")
	
#WILDEN
func Wilden1(e : Entity, _t = null):
	e.gridmap.PlaceTileEffect(e.facingPos, TileEffect.Effect.Smoke, e)

func WildenOnEnterTileEffect(e : Entity, effect : TileEffect.Effect):
	if e.classE.classVariables["WildenCooldown"] <= 0:
		var status : Status
		var duration : int
		match effect:
			TileEffect.Effect.Air:
				status = Status.Air()
				duration = 4
			TileEffect.Effect.Earth:
				status = Status.Earth()
				duration = 4
			_:
				status = Status.Stealth()
				duration = 2
		e.AddStatus(status, duration)
		e.text.AddLine(e.GetLogName() + " cloaked themselves with " + TileEffect.Effect.keys()[effect] + " to gain " + status.name + "!\n")
		e.classE.classVariables["WildenCooldown"] = 6
		e.gridmap.RemoveTileEffect(e.gridPos)
	
func WildenOnTurnStart(e : Entity):
	if e.classE.classVariables["WildenCooldown"] > 0:
		e.classE.classVariables["WildenCooldown"] -= 1

func WildenPassiveApply(e : Entity):
	e.classE.classVariables["WildenCooldown"] = 0
	e.OnEnterTileEffect.connect(WildenOnEnterTileEffect)
	e.OnTurnStart.connect(WildenOnTurnStart)

func WildenPassiveRemove(e : Entity):
	e.classE.classVariables.erase("WildenCooldown")
	e.OnEnterTileEffect.disconnect(WildenOnEnterTileEffect)
	e.OnTurnStart.disconnect(WildenOnTurnStart)

#DRUID
func Druid1(e : Entity, _t = null):
	if e.Type != "Player" || e.allies.size() < 1:
		e.text.AddLine(e.GetLogName() + " has no ally to shapeshare with!\n")
		return
		
	var transformMesh : Node3D = e.classE.classVariables["transformMesh"]
	var hp : int = e.stats.HP
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
		e.originalStats = Stats.Highest(e.originalStats, e.allies[0].originalStats)
		e.classE.classVariables["notOriginal"] = true
		e.text.AddLine(e.GetLogName() + " assumed " + e.allies[0].Name + "'s form!\n")
	e.stats.HP = hp
	e.UpdateStats()

func DruidPassiveApply(e : Entity):
	e.classE.classVariables["originalMesh"] = e.mesh
	e.classE.classVariables["originalOriginalStats"] = e.originalStats
	e.classE.classVariables["transformMesh"] = null
	e.classE.classVariables["notOriginal"] = false
	
	e.OnAllyDeath.connect(DruidOnAllyDeath)
	e.OnLevelStart.connect(DruidOnLevelStart)
	e.OnLevelEnd.connect(DruidOnLevelEnd)

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
	
	e.OnAllyDeath.disconnect(DruidOnAllyDeath)

func DruidOnAllyDeath(e : Player, t : Entity):
	if e.classE.classVariables["notOriginal"]:
		e.originalStats = e.classE.classVariables["originalOriginalStats"]
		e.mesh.get_node("Armature").visible = true
		e.animator = e.mesh.get_node("AnimationTree")
		e.classE.classVariables["notOriginal"] = false
		e.text.AddLine(e.GetLogName() + " was forced into their true form after " + t.GetLogName() + "'s death!\n")
	if e.classE.classVariables["transformMesh"] != null:
		e.classE.classVariables["transformMesh"].queue_free()
		e.classE.classVariables["transformMesh"] = null

func DruidOnLevelStart(e : Player):
	e.classE.classVariables["originalMesh"] = e.mesh
	e.classE.classVariables["originalOriginalStats"] = e.originalStats
	e.classE.classVariables["transformMesh"] = null
	e.classE.classVariables["notOriginal"] = false
	
func DruidOnLevelEnd(e : Player):
	if e.classE.classVariables["notOriginal"]:
		e.originalStats = e.classE.classVariables["originalOriginalStats"]
		e.mesh.get_node("Armature").visible = true
		e.animator = e.mesh.get_node("AnimationTree")
		e.classE.classVariables["notOriginal"] = false
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
		message = e.GetLogName() + " ate a windeelion and felt sharper!\n"
	elif item.name == "Pebblepod":
		effect = Status.DefenseBuff()
		message = e.GetLogName() + " ate a pebblepod and felt tougher!\n"
	elif item.name == "Tarrime Bloom":
		effect = Status.ResistenceBuff()
		message = e.GetLogName() + " ate a tarrime bloom and felt more resistant!\n"
	
	e.StartCooldownName("Forager's Bounty")
	e.AddStatus(effect, 7)
	e.text.AddLine(message)
	e.OnMoveUse.emit(e, null, "Forager's Bounty")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

func HerbalistItem (e : Entity, t : Entity):
	if e.gridmap.GetMapPos(e.facingPos) == -2 || e.facingPos not in e.gridmap.tileEffects:
		return
	var te : TileEffect = e.gridmap.tileEffects[e.facingPos]
	var numItems : int = randi_range(2, 3) if randf_range(0, 1) < .8 else 4
	var item : Item
	var effect : Status
	var duration : int
	var message : String
	if te.effect == TileEffect.Effect.Fire:
		item = Items.items["Charshroom"]
		effect = Status.status["Burning"]
		duration = 2
		message = "Charshrooms grew from the ashes!\n"
	elif te.effect == TileEffect.Effect.Frost:
		item = Items.items["Tarrime Bloom"]
		effect = Status.status["Frostbite"]
		duration = 3
		message = "Tarrime Blooms sprouted through the frost!\n"
	elif te.effect == TileEffect.Effect.Air:
		item = Items.items["Windeelion"]
		effect = Status.status["Disarm"]
		duration = 2
		message = "Windeelions sprouted through the breeze!\n"
	elif te.effect == TileEffect.Effect.Earth:
		item = Items.items["Pebblepod"]
		effect = Status.status["Bleed"]
		duration = 5
		message = "Pebblepods took root in the earth!\n"
		
	for i in range(numItems):
		e.gridmap.PlaceItem(e.facingPos, item)
	if t != null:
		t.AddStatus(effect, duration)
	e.text.AddLine(message)
	e.gridmap.RemoveTileEffect(e.facingPos)

#TOTEMCARVER
func Totemcarver1(e : Entity, t : Entity):
	if t == null:
		return
	elif t.Type == "Structure":
		if t.structureName == "Totem" && t.gridPos in t.gridmap.tileEffects:
			var effect : TileEffect.Effect = t.gridmap.tileEffects[t.gridPos].effect
			for pos in t.AdjacentTiles():
				if pos == e.gridPos && (effect == TileEffect.Effect.Fire || effect == TileEffect.Effect.Frost):
					continue
				t.gridmap.PlaceTileEffect(pos, effect, e)
			e.text.AddLine(e.GetLogName() + " whittled a totem, spreading " + TileEffect.Effect.keys()[effect] +  "!\n")
	elif t.Type == "AI":
		var damage : int = Stats.GetDamage(e.stats, t.stats, false)
		t.animator.Damage()
		if randf_range(0, 1) < .05:
			var potentialItems = Loader.GetEnemyData(t.Name)["drops"]
			e.text.AddLine(e.GetLogName() + " carved an item from " + t.GetLogName() + " for " + LogText.GetDamageNum(damage, false) + " damage!\n")
			t.gridmap.PlaceItem(t.gridPos, Items.items[potentialItems[randi_range(0, potentialItems.size() - 1)]], -2)
		else:
			e.text.AddLine(e.GetLogName() + " carved " + t.GetLogName() + " for " + LogText.GetDamageNum(damage, false) + " damage!\n")
		t.TakeDamage(damage, e)

func TotemcarverStructureBehavior(e : Structure):
	if e.gridPos not in e.gridmap.tileEffects:
		return
	var adj = e.AdjacentTiles()
	e.gridmap.PlaceTileEffect(adj[randi_range(0, adj.size() - 1)], e.gridmap.tileEffects[e.gridPos].effect, e.own)

func TotemcarverItemMove(e : Entity, _t = null):
	if e.gridmap.GetMapPos(e.facingPos) != -1:
		e.text.AddLine("The totem can't be placed there!\n")
		return
	var s : Structure = e.gridmap.turnhandler.entityhandler.SpawnStructure(e.facingPos, e, "Totem", load("res://Assets/Items/Machining/TotemStructure.tscn").instantiate(), TotemcarverStructureBehavior, Stats.new(10, 0, 0, 0, 0, false, true))
	s.immune["Frostbite"] = null
	s.immune["Burning"] = null
	e.text.AddLine(e.GetLogName() + " created a totem!\n")
	e.OnMoveUse.emit(e, null, "Totem")

#WAR CASTER
func WarCaster1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var e : Player = g
	var criteria : Array[Callable]
	var critDesc : Array[String]
	if e.equipped == -1:
		criteria = [WarCasterEquipCriteria]
		critDesc = ["Select a weapon or focus."]
	else:
		if !e.GetItem(e.equipped).move.magic:
			criteria = [WarCasterFocusCriteria]
			critDesc = ["Select a focus."]
		else:
			criteria = [WarCasterWeaponCriteria]
			critDesc = ["Select a weapon."]
	
	e.action = false
	e.inventoryUI.pickingComplete.connect(WarCasterPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func WarCasterFocusCriteria(i : Item, _last : Item):
	if i != null && i.equipment && i.move.magic:
		return "Valid focus.\n  "
	else:
		return null
		
func WarCasterWeaponCriteria(i : Item, _last : Item):
	if i != null && i.equipment && !i.move.magic:
		return "Valid weapon.\n  "
	else:
		return null
		
func WarCasterEquipCriteria(i : Item, _last : Item):
	if i != null && i.equipment:
		return "Valid equippable.\n  "
	else:
		return null

func WarCasterPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(WarCasterPickComplete)
	if ids.size() < 1:
		return
	e.inventoryUI.Equip(ids[0])
	e.OnMoveUse.emit(e, null, "Expert's Stance")
	e.StartCooldownName("Expert's Stance")
	e.skillUI.UpdateAll()
	#this move does not end turn intentionally
	
func WarCasterOnMoveUse(e : Entity, _t : Entity, movename : String):
	if e.Type != "Player" || e.equipped == -1:
		return
	var magic = e.GetItem(e.equipped).move.magic
	if movename == "Skilled Strike" && magic:
		e.AddStatus(Status.MagicBuff(), 4)
	elif movename == "Aspected Blast" && !magic:
		e.AddStatus(Status.AttackBuff(), 4)

func WarCasterPassiveApply(e : Entity):
	e.OnMoveUse.connect(WarCasterOnMoveUse)

func WarCasterPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(WarCasterOnMoveUse)

#TRICKSTER
func Trickster1(e : Entity, _t = null):
	if e.gridmap.GetMapPos(e.facingPos) != -1:
		e.text.AddLine("A duplicate can't be summoned there!\n")
		return
	e.gridmap.turnhandler.entityhandler.SpawnStructure(e.facingPos, e, "Duplicate", e.mesh, TricksterStructureBehavior, Stats.new(5, 0, 0, 0, 0, false, true), [Color.BLACK, Color.DARK_GRAY, Color.DARK_GRAY], 6)
	e.text.AddLine(e.GetLogName() + " summoned a duplicate of themselves!\n")

func TricksterStructureBehavior(e : Structure):
	e.RandomRotate(e.gridPos)
	if randf_range(0, 1) < .6:
		for pos in e.AdjacentTiles():
			var entity : Entity = e.GetEntity(pos)
			if entity != null && entity.Type == "AI":
				entity.targetEntity = e
				entity.targetGridPos = e.gridPos
				entity.targetGridPosChanged = true
		e.animator.Attack()
	else:
		e.animator.Damage()

func TricksterOnMoveUse(e : Entity, t : Entity, movename : String):
	if movename == "Stealth" && t != null:
		var pos = (2 * (e.facingPos - e.gridPos)) + e.gridPos
		if e.gridmap.GetMapPos(pos) == -1:
			e.SnapPosition(pos)
			e.text.AddLine(e.GetLogName() + " teleported behind " + t.GetLogName() + "!\n")
			
func TricksterPassiveApply(e : Entity):
	e.OnMoveUse.connect(TricksterOnMoveUse)

func TricksterPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(TricksterOnMoveUse)
	
#SUMMONER
func Summoner1(e : Entity, t : Entity):
	if e.allies.size() < 2:
		e.text.AddLine(e.GetLogName() + " didn't have enough tames to swap!\n")
		return
	var tame1 : Entity = e.allies[0]
	var tame2 : Entity = e.allies[1]
	
	tame1.visible = false
	
	e.turnhandler.Entities[tame1.entityNum] = tame2
	if is_instance_valid(tame1.targetEntity):
		tame2.Target(tame1.targetEntity)
	tame2.SnapPosition(tame1.gridPos)
	tame2.visible = true
	
	e.allies[0] = tame2
	e.allies[1] = tame1
	
	var target : Entity = t if t != null && t.Type == "AI" else null
	if t == null:
		for pos in tame2.AdjacentTiles():
			var entity : Entity = e.GetEntity(pos)
			if entity != null && entity.Type == "AI":
				target = entity
				break
	e.text.AddLine(tame2.GetLogName() + " was summoned to replace " + tame1.GetLogName() + "!\n")
	if target != null:
		tame2.Rotate(target.gridPos)
		if target != e:
			await tame2.moves[0].Use(tame2, target)

func SummonerOnTame(e : Player, t : Entity):
	if e.allies.size() > 1:
		e.text.AddLine(t.GetLogName() + " vanished into reserves, ready to be summoned!\n")
		t.visible = false
		e.gridmap.SetMapPos(t.gridPos, -1)
		e.gridmap.Pathfinding.set_point_weight_scale(t.gridPos, 1)
		e.turnhandler.RemoveEntity(t.entityNum)
		t.entityNum = e.allies[0].entityNum
		for ally in e.allies:
			if ally.targetEntity == t:
				ally.Target(e)
		
func SummonerOnTameDeath(e : Player, t : Entity):
	if e.allies.size() > 1:
		e.UpdateAllies()
		e.turnhandler.Entities[t.entityNum] = e.allies[0]
		e.allies[0].SnapPosition(t.gridPos)
		e.allies[0].visible = true
		e.text.AddLine(e.allies[0].GetLogName() + " was summoned from reserves!\n")
		e.usedTurn = true
		e.turnhandler.RemovalQueue.erase(t.entityNum)

func SummonerPassiveApply(e : Entity):
	e.maxAllies = 2
	e.OnTame.connect(SummonerOnTame)
	e.OnAllyDeath.connect(SummonerOnTameDeath)
	
func SummonerPassiveRemove(e : Entity):
	e.maxAllies = 1
	e.OnTame.disconnect(SummonerOnTame)
	e.OnAllyDeath.disconnect(SummonerOnTameDeath)

#TRANSMUTER
func Transmuter1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var criteria : Array[Callable] = [TransmuterCriteria]
	var critDesc : Array[String] = ["Select a Stone, Heavy, Reagent, Sharp or Healing material."]
	var e : Player = g
	e.action = false
	e.inventoryUI.pickingComplete.connect(TransmuterPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func TransmuterCriteria(i : Item, _last : Item):
	if i != null && i.crafting.tags.size() > 0:
		if "Stone" in i.crafting.tags || "Heavy" in i.crafting.tags:
			return "Place an Earth tile effect and apply Bleed to nearby enemies.\n  "
		elif "Reagent" in i.crafting.tags || "Sharp" in i.crafting.tags || "Healing" in i.crafting.tags:
			return "Place a Shadow tile effect and heal.\n  "
			
	return null

func TransmuterPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(TransmuterPickComplete)
	if ids.size() < 1:
		return
	var item : Item = e.GetItem(ids[0])
	if "Stone" in item.crafting.tags || "Heavy" in item.crafting.tags:
		e.text.AddLine(item.GetLogName() + " was transmuted into earthen spikes!\n")
		e.gridmap.PlaceTileEffect(e.gridPos, TileEffect.Effect.Earth, e)
		for pos in e.AdjacentTiles():
			var entity : Entity = e.GetEntity(pos)
			if entity != null && entity.Type == "AI":
				entity.animator.Damage()
				entity.AddStatus(Status.Bleed(), 3)
	elif "Reagent" in item.crafting.tags || "Sharp" in item.crafting.tags || "Healing" in item.crafting.tags:
		e.text.AddLine(item.GetLogName() + " was transmuted into renewing shadows!\n")
		e.gridmap.PlaceTileEffect(e.gridPos, TileEffect.Effect.Shadow, e)
		var healAmount : int = e.Heal(int(.25 * e.stats.maxHP))
		if healAmount > 0:
			e.text.AddLine(e.GetLogName() + " was healed by shadows for " + LogText.GetHealNum(healAmount) + "HP!\n")
		
	e.inventoryUI.RemoveItem(ids[0])
	e.StartCooldownName("Conversion Alchemy")
	e.skillUI.UpdateAll()
	e.OnMoveUse.emit(e, null, "Conversion Alchemy")
	e.endTurn.emit()
	
func EquipmentToSalvage(equipment : Equipment) -> Array:
	if equipment.prefixes.size() < 1:
		return []
	var prefixes = equipment.prefixes.keys()
	var prefix : String = prefixes[randi_range(0, prefixes.size() - 1)]
	match equipment.requiredProf:
		Classes.Proficiency.FocusBasic:
			var basicFocus : Dictionary = { "Fire":[Items.items["Fire Mote"]], "Frost":[Items.items["Frost Mote"]], "Earth":[Items.items["Earth Mote"]], "Air":[Items.items["Air Mote"]] }
			return basicFocus[prefix]
		Classes.Proficiency.FocusAdvanced:
			var advancedFocus : Dictionary = {"Force":[Items.items["Earth Mote"], Items.items["Heavy Scrap"]], "Lightning":[Items.items["Air Mote"], Items.items["Sharp Scrap"]], "Radiant":[Items.items["Fire Mote"], Items.items["Shiny Scrap"]], "Shadow":[Items.items["Light Scrap"], Items.items["Frost Mote"]] }
			return advancedFocus[prefix]
		Classes.Proficiency.WeaponBasic:
			var basicWeapon : Dictionary = { "Bold":[Items.items["Shiny Scrap"]], "Blitz":[Items.items["Light Scrap"]], "Bludgeon":[Items.items["Heavy Scrap"]], "Bleed":[Items.items["Sharp Scrap"]] }
			return basicWeapon[prefix]
		Classes.Proficiency.WeaponMartial:
			var martialWeapon : Dictionary = { "Cleave":[Items.items["Fire Mote"], Items.items["Light Scrap"]], "Reach": [Items.items["Air Mote"], Items.items["Sharp Scrap"]], "Runed":[Items.items["Frost Mote"], Items.items["Shiny Scrap"]], "Crush":[Items.items["Heavy Scrap"], Items.items["Earth Mote"]]}
			return martialWeapon[prefix]
		_:
			return []

func TransmuterItemMove(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var criteria : Array[Callable] = [TransmuterItemCriteria]
	var critDesc : Array[String] = ["Select a focus or weapon."]
	var e : Player = g
	e.action = false
	e.inventoryUI.pickingComplete.connect(TransmuterItemPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func TransmuterItemCriteria(i : Item, _last : Item):
	if i != null && i.equipment:
		return "Valid piece of equipment.\n  "
	else:
		return null

func TransmuterItemPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(TransmuterItemPickComplete)
	if ids.size() < 1:
		return
	var item : Equipment = e.GetItem(ids[0])
	var quantity : int = item.rarity
	var salvage : Array = EquipmentToSalvage(item)
	e.text.AddLine(item.GetLogName() + " was transmuted into salvage!\n")
	e.inventoryUI.RemoveItem(ids[0])
	
	if e.inventoryUI.inventory[e.inventoryUI.using].uses > 1:
		e.inventoryUI.inventory[e.inventoryUI.using].uses -= 1
	else:
		e.inventoryUI.RemoveItem(e.inventoryUI.using)
		
	for i in range(randi_range(1, 2) + quantity):
		if e.IsInventoryFull():
			e.gridmap.PlaceItem(e.gridPos, salvage[randi_range(0, salvage.size() - 1)], -2)
		else:
			e.PickupItem(salvage[randi_range(0, salvage.size() - 1)], -2)
			
	e.OnMoveUse.emit(e, null, "Transmuter's Stone")
	e.endTurn.emit()

#ENCHANTER
func Enchanter1(g : Entity, t : Entity):
	if g.Type != "Player":
		return
	var e : Player = g
	if e.equipped == -1 || !e.GetItem(e.equipped).move.magic:
		e.text.AddLine(e.GetLogName() + " is not using a focus!\n")
		return
	elif e.GetItem(e.equipped).prefixes.size() == 0:
		e.text.AddLine(e.GetLogName() + "'s equipped focus has no aspects to disenchant!\n")
		return
	var startingMod = 1 + (.2 * e.GetItem(e.equipped).prefixes.size())
	await Equipment.FocusCrit(e, t, e.GetItem(e.equipped), "Disenchanting Surge", startingMod)
	e.text.AddLine(e.GetItem(e.equipped).GetLogName() + " was disenchanted!\n")
	e.GetItem(e.equipped).prefixes = {}
	Items.ChangePrefixName(e.GetItem(e.equipped))

func ChangeAspect1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var criteria : Array[Callable] = [EnchanterFocusCriteria, EnchanterMaterialCriteria]
	var critDesc : Array[String] = ["Select a focus.", "Select a Fire, Frost, Air, or Stone material."]
	var e : Player = g
	e.action = false
	e.inventoryUI.pickingComplete.connect(EnchanterPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func EnchanterFocusCriteria(i : Item, _last : Item):
	if i != null && i.equipment && i.move.magic && i.prefixes.size() < 2:
		return "Enchantable focus.\n  "
	else:
		return null

func EnchanterMaterialCriteria(i : Item, last : Item):
	if i != null :
		var materials : Dictionary = { "Fire":null, "Frost":null, "Air":null, "Stone":null }
		for tag in i.crafting.tags:
			if tag not in materials || tag in last.prefixes || tag == "Stone" && "Earth" in last.prefixes:
				continue
			return "Usable material.\n  "

	return null

func EnchanterPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(EnchanterPickComplete)
	if ids.size() < 1:
		return
	var focus : Equipment = e.GetItem(ids[0])
	var tags = e.GetItem(ids[1]).crafting.tags.keys()
	var possibleAspects : Array[String] = []
	for tag in tags:
		if tag == "Fire" || tag == "Frost" || tag == "Air":
			possibleAspects.append(tag)
		elif tag == "Stone":
			possibleAspects.append("Earth")
	var tag = possibleAspects[randi_range(0, possibleAspects.size() - 1)]
	focus.prefixes[tag] = null
	e.inventoryUI.RemoveItem(ids[1])
	e.text.AddLine(focus.GetLogName() + " was enchanted with the power of " + tag + "!\n")
	Items.ChangePrefixName(focus)
	e.OnMoveUse.emit(e, null, "Enchanted Attuner")
	if e.inventoryUI.inventory[e.inventoryUI.using].uses > 1:
		e.inventoryUI.inventory[e.inventoryUI.using].uses -= 1
	else:
		e.inventoryUI.RemoveItem(e.inventoryUI.using)
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
		var damage : int = int(Stats.GetDamage(e.stats, t.stats, true) / 2)
		if damage <= 0:
			damage = 1
		e.text.AddLine(t.GetLogName() + " was surprised and took " + LogText.GetDamageNum(damage, true) + " damage!\n")
		t.TakeDamage(damage, e)

func CutthroatPassiveApply(e : Entity):
	e.OnMoveUse.connect(CutthroatOnMoveUse)
	
func CutthroatPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(CutthroatOnMoveUse)

#WARDEN
func Warden1(e : Entity, _t : Entity):
	e.AddStatus(Status.SureCrit(), 6)
	if e.allies.size() > 0:
		e.allies[0].AddStatus(Status.SureCrit(), 6)
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
	newMove.noTargets = true
	t.moves[0] = newMove
	
func WardenOnAllyDeath(e : Entity, t : Entity):
	e.classE.classVariables.erase(t.Name + "originalMove")

func WardenPassiveApply(e : Entity):
	e.OnMoveUse.connect(WardenOnMoveUse)
	e.OnTame.connect(WardenOnTame)
	e.OnAllyDeath.connect(WardenOnAllyDeath)
	for ally in e.allies:
		WardenOnTame(e, ally)
	
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

#WEAPONSMITH
func Weaponsmith1(g : Entity, t : Entity):
	if g.Type != "Player":
		return
	var e : Player = g
	if e.equipped == -1 || e.GetItem(e.equipped).move.magic:
		e.text.AddLine(e.GetLogName() + " is not using a weapon!\n")
		return
	elif e.GetItem(e.equipped).prefixes.size() == 0:
		e.text.AddLine(e.GetLogName() + "'s equipped weapon has no modifiers to abrade!\n")
		return
	var startingMod = 1 + (.2 * e.GetItem(e.equipped).prefixes.size())
	await Equipment.WeaponCrit(e, t, e.GetItem(e.equipped), "Abrading Assault", startingMod)
	e.text.AddLine(e.GetItem(e.equipped).GetLogName() + " was abraded!\n")
	e.GetItem(e.equipped).prefixes = {}
	Items.ChangePrefixName(e.GetItem(e.equipped))

func ChangeModifier1(g : Entity, _t = null):
	if g.Type != "Player":
		return
	var criteria : Array[Callable] = [WeaponsmithWeaponCriteria, WeaponsmithMaterialCriteria]
	var critDesc : Array[String] = ["Select a weapon.", "Select a Reagent, Sharp, Heavy, or Light material."]
	var e : Player = g
	e.action = false
	e.inventoryUI.pickingComplete.connect(WeaponsmithPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func WeaponsmithWeaponCriteria(i : Item, _last : Item):
	if i != null && i.equipment && !i.move.magic && i.prefixes.size() < 2:
		return "Modifiable weapon.\n  "
	else:
		return null

func WeaponsmithMaterialCriteria(i : Item, last : Item):
	if i != null :
		var materials : Dictionary = { "Reagent":null, "Sharp":null, "Heavy":null, "Light":null }
		for tag in i.crafting.tags:
			if tag not in materials || (tag == "Reagent" && "Bold" in last.prefixes) || (tag == "Sharp" && "Bleed" in last.prefixes) || (tag == "Heavy" && "Bludgeon" in last.prefixes) || (tag == "Light" && "Blitz" in last.prefixes):
				continue
			return "Usable material.\n  "

	return null

func WeaponsmithPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(WeaponsmithPickComplete)
	if ids.size() < 1:
		return
	var weapon : Equipment = e.GetItem(ids[0])
	var tags = e.GetItem(ids[1]).crafting.tags.keys()
	var possibleAspects : Array[String] = []
	for tag in tags:
		if tag == "Reagent":
			possibleAspects.append("Bold")
		elif tag == "Sharp":
			possibleAspects.append("Bleed")
		elif tag == "Heavy":
			possibleAspects.append("Bludgeon")
		elif tag == "Light":
			possibleAspects.append("Blitz")
	var tag = possibleAspects[randi_range(0, possibleAspects.size() - 1)]
	weapon.prefixes[tag] = null
	e.inventoryUI.RemoveItem(ids[1])
	e.text.AddLine(weapon.GetLogName() + " was improved to have the " + tag + " modifier!\n")
	Items.ChangePrefixName(weapon)
	e.OnMoveUse.emit(e, null, "Smithing Gear")
	if e.inventoryUI.inventory[e.inventoryUI.using].uses > 1:
		e.inventoryUI.inventory[e.inventoryUI.using].uses -= 1
	else:
		e.inventoryUI.RemoveItem(e.inventoryUI.using)
	e.endTurn.emit()

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

func BlighterItem(e : Entity, t : Entity):
	if t != null:
		e.text.AddLine(t.GetLogName() + " was pincushioned by toxic spikes for " + LogText.GetDamageNum(3) + " damage!\n")
		t.TakeDamage(3, e)

#THIEF
func Thief1(e : Entity, t : Entity):
	var pierce : int = 2 if t.Type == "AI" && t.inventory.size() == 0 else 0
	var damage : int = Stats.GetDamage(e.stats, t.stats, false, pierce)
	e.text.AddLine(e.GetLogName() + " pilfered " + t.GetLogName() + " for " + LogText.GetDamageNum(damage) + " damage!" + "\n")
	t.TakeDamage(damage, e)

func ThiefOnMoveUse(e : Entity, t : Entity, movename : String):
	if t != null && t.Type == "AI" && e.GetEquippedMove() != null && movename == e.GetEquippedMove().name && "Stealth" in e.statuses.keys() && t.inventory.size() > 0:
		var removeSpot = t.inventory.size() - 1
		var item : Item = t.inventory[removeSpot]
		var uses : int = t.useMeta[removeSpot] if removeSpot in t.useMeta else 0
		if e.IsInventoryFull():
			e.gridmap.PlaceItem(t.gridPos, item, uses)
			e.text.AddLine(item.GetLogName() + " fell to the floor!\n")
		else:
			e.inventoryUI.AddItem(item, uses)
			e.text.AddLine(e.GetLogName() + " stole " + item.GetLogName() + "!\n")
		t.RemoveItemAt(removeSpot)
		
func ThiefPassiveApply(e : Entity):
	e.OnMoveUse.connect(ThiefOnMoveUse)
	
func ThiefPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ThiefOnMoveUse)

#IMBUER
func Imbuer1(e : Entity, t : Entity):
	var damage : int = Stats.GetDamage(e.stats, t.stats, false)
	e.text.AddLine(e.GetLogName() + " attacked " + t.GetLogName() + " for " + LogText.GetDamageNum(damage) + " damage!" + "\n")
	if t.Type == "AI":
		var renew : bool = false
		for status in e.statuses:
			if status == "AttackBuff" || status == "DefenseBuff" || status == "MagicBuff" || status == "ResistenceBuff":
				e.statusDuration[status] = 6
				renew = true
		if e.allies.size() > 0:
			for status in e.allies[0].statuses:
				if status == "AttackBuff" || status == "DefenseBuff" || status == "MagicBuff" || status == "ResistenceBuff":
					e.allies[0].statusDuration[status] = 6
					renew = true
		if renew:
			e.text.AddLine(e.GetLogName() + "'s vigor was renewed!\n")
	t.TakeDamage(damage, e)

func ImbuerItemMove(e : Entity, _t : Entity):
	var healAmount : int = e.Heal(int(.25 * e.stats.maxHP))
	if healAmount > 0:
		e.text.AddLine(e.GetLogName() + " healed for " + str(healAmount) + " HP!\n")
	var applyBuffs : Array[String] = []
	for status in ["AttackBuff", "DefenseBuff", "MagicBuff", "ResistenceBuff"]:
		if status not in e.statuses:
			applyBuffs.append(status)
			
	if applyBuffs.size() == 0:
		e.text.AddLine(e.GetLogName() + " was already fully imbued!\n")
		return
		
	var status : Status = Status.status[applyBuffs[randi_range(0, applyBuffs.size() - 1)]]
	match status.name:
		"AttackBuff":
			e.text.AddLine(e.GetLogName() + " was imbued with strength!\n")
		"MagicBuff":
			e.text.AddLine(e.GetLogName() + " was imbued with wit!\n")
		"DefenseBuff":
			e.text.AddLine(e.GetLogName() + " was imbued with durability!\n")
		"ResistenceBuff":
			e.text.AddLine(e.GetLogName() + " was imbued with resilience!\n")
	e.AddStatus(status, 4)

var potions : Dictionary = { "Healing Potion":null, "Imbued Wilds":null }
func ImbuerOnMoveUse(e : Entity, _t : Entity, movename : String):
	if movename in potions && e.allies.size() > 0:
		Move.moves[movename].Use(e.allies[0])

func ImbuerPassiveApply(e : Entity):
	e.OnMoveUse.connect(ImbuerOnMoveUse)
	
func ImbuerPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ImbuerOnMoveUse)
	
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
		potentialItems = e.gridmap.controller.level.materials + ["Shiny Scrap", "Heavy Scrap", "Light Scrap", "Sharp Scrap"]
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
var userBlacklist : Dictionary = { "Totem":null, "Transmuter's Stone":null, "Whetstone Oil":null, "Enchanted Attuner":null, "Smithing Gear":null, "Tunneling Tools":null}
func Artificer1(g : Entity, _t : Entity = null):
	if g.gridmap.GetMapPos(g.facingPos) != -1:
		g.text.AddLine("A mechanical user can't be summoned there!\n")
		g.endTurn.emit()
		return
	
	if g.Type != "Player":
		return
	var criteria : Array[Callable] = [ArtificerCriteria]
	var critDesc : Array[String] = ["Select a consumable item."]
	var e : Player = g
	e.action = false
	e.inventoryUI.pickingComplete.connect(ArtificerPickComplete)
	e.inventoryUI.ModPickerOpen(criteria, critDesc)

func ArtificerCriteria(i : Item, _last : Item):
	if i != null && i.consumable && i.name not in userBlacklist:
		return "Valid consumable.\n  "
	return null

func ArtificerPickComplete(e : Player, ids : Array[int]):
	e.inventoryUI.pickingComplete.disconnect(ArtificerPickComplete)
	if ids.size() < 1:
		return
	var item : Item = e.GetItem(ids[0])
	
	var structure : Structure = e.gridmap.turnhandler.entityhandler.SpawnStructure(e.facingPos, e, "Mechanical User", e.mesh, ArtificerStructureBehavior, Stats.new(5, e.originalStats.POW, 1, e.originalStats.MAG, 1, false, true), [Color.BLACK, Color.DARK_GRAY, Color.DARK_GRAY], 7)
	structure.moves.append(item.move.Duplicate())
	structure.moves[0].noTargets = true
	structure.moves[0].manualCooldown = true
	if item.name == "Salvager":
		structure.duration = 3
	e.text.AddLine(e.GetLogName() + " summoned a mechanical user!\n")
	
	e.inventoryUI.RemoveItem(ids[0])
	e.StartCooldownName("Mechanical User")
	e.skillUI.UpdateAll()
	e.OnMoveUse.emit(e, null, "Mechanical User")
	e.endTurn.emit()
	
func ArtificerStructureBehavior(e : Structure):
	for pos in e.AdjacentTiles():
		var entity : Entity = e.GetEntity(pos)
		if entity != null && entity.Type == "AI":
			entity.targetEntity = e
			entity.targetGridPos = e.gridPos
			entity.targetGridPosChanged = true
			e.Rotate(pos)
			await e.moves[0].Use(e, entity)
			return

func ArtificerOnMoveUse(e : Entity, _t : Entity, movename : String):
	if movename == "Tinker":
		e.AddStatus(Status.DefenseBuff(), 3)
		e.AddStatus(Status.ResistenceBuff(), 3)
	elif movename == "Brew":
		e.AddStatus(Status.AttackBuff(), 3)
		e.AddStatus(Status.MagicBuff(), 3)
		
func ArtificerPassiveApply(e : Entity):
	e.OnMoveUse.connect(ArtificerOnMoveUse)
	
func ArtificerPassiveRemove(e : Entity):
	e.OnMoveUse.disconnect(ArtificerOnMoveUse)
	
