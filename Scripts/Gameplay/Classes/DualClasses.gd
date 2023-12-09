class_name DualClasses
extends Node

func _ready():
	var druidMove = Move.new("Shapeshare", Druid1)
	druidMove.playAnimation = false
	druidMove.noTargets = true
	druidMove.cooldown = 5
	druidMove.icon = preload("res://Assets/Icons/Move/Druid.png")
	Move.moves["Shapeshare"] = druidMove
		
	var druidPassive = Passive.new("True to Form", DruidPassiveApply, DruidPassiveRemove, true)
	Passive.passives["True to Form"] = druidPassive
	
	var herbalistMove = Move.new("Forager's Bounty", Herbalist1)
	herbalistMove.playAnimation = false
	herbalistMove.manualEndTurn = true
	herbalistMove.noTargets = true
	herbalistMove.cooldown = 4
	herbalistMove.manualCooldown = true
	herbalistMove.icon = preload("res://Assets/Icons/Move/Herbalist.png")
	Move.moves["Forager's Bounty"] = herbalistMove
	
	var artificerPassive = Passive.new("Combat Ingenuity", ArtificerPassiveApply, ArtificerPassiveRemove)
	Passive.passives["Combat Ingenuity"] = artificerPassive
	
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
var HerbalistOptions : Array[String] = ["Charshroom: ATK", "Windeelion: MAG", "Pebblepod: DEF", "Tarrime Bloom: RES"]
func Herbalist1(e : Entity, _t = null):
	if e.Type == "Player":
		var disabled : Dictionary = {}
		if e.HasItem("Charshroom") == -1:
			disabled[0] = null
		if e.HasItem("Windeelion") == -1:
			disabled[1] = null
		if e.HasItem("Pebblepod") == -1:
			disabled[2] = null
		if e.HasItem("Tarrime Bloom") == -1:
			disabled[3] = null
		e.option.OptionSelected.connect(HerbalistAttack)
		e.option.Open(HerbalistOptions, disabled, 250)
	else:
		HerbalistAttack(e, 0)
		
func HerbalistAttack(e : Entity, id : int):
	if e.Type == "Player":
		e.option.OptionSelected.disconnect(HerbalistAttack)
		if id == -1:
			e.Start.call_deferred()
			return
			
	var effect : Status
	var message : String
	var removeSpot : int
	if id == 0:
		effect = Status.AttackBuff()
		message = e.Name + " ate a charshroom and felt stronger!\n"
		removeSpot = e.HasItem("Charshroom")
	elif id == 1:
		effect = Status.MagicBuff()
		message = e.Name + " ate a windeelion and felt more powerful!\n"
		removeSpot = e.HasItem("Windeelion")
	elif id == 2:
		effect = Status.DefenseBuff()
		message = e.Name + " ate a pebblepod and felt tougher!\n"
		removeSpot = e.HasItem("Pebblepod")
	elif id == 3:
		effect = Status.ResistenceBuff()
		message = e.Name + " ate a tarrime bloom and felt more resistant!\n"
		removeSpot = e.HasItem("Tarrime Bloom")
	e.StartCooldownName("Forager's Bounty")
	e.AddStatus(effect, 3)
	e.text.AddLine(message)
	e.RemoveItemAt(removeSpot)
	e.OnMoveUse.emit(e, "Tinker")
	if e.Type == "Player":
		e.skillUI.UpdateAll()
	e.endTurn.emit()

#ARTIFICER
func ArtificerOnMoveUse(e : Entity, movename : String):
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
	
	
	
	
	
	
