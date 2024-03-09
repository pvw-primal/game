class_name AIBehavior
extends Node

func _ready():
	var russMove = Move.new("Call Kasu", RussMove)
	russMove.playAnimation = false
	russMove.cooldown = 9
	russMove.cutsCorners = true
	russMove.noTargets = true
	Move.moves["Call Kasu"] = russMove
	
	var pesterMove = Move.new("Quick Brew", PesterMove)
	pesterMove.playAnimation = false
	pesterMove.cooldown = 4
	pesterMove.noTargets = true
	Move.moves["Quick Brew"] = pesterMove
	
	var cinchMove = Move.new("Siphon", CinchMove)
	cinchMove.cooldown = 5
	Move.moves["Siphon"] = cinchMove
	
func RussMove(e : Entity, _t : Entity):
	var numSummons = randi_range(0, 2) if e.Type == "AI" else 1
	var start = numSummons
	var tiles = e.AdjacentTiles()
	tiles.shuffle()
	var babyStats : Stats = Stats.new(1, 2, 0, 2, 0)
	var babyMove : Move = Move.DefaultPhysical()
	babyMove.name = "Lil' Peck"
	for i in range(tiles.size()):
		if e.gridmap.GetMapPos(tiles[i]) == -1:
			var baby : AI = e.gridmap.turnhandler.entityhandler.SpawnAIAt(tiles[i], e, 0)
			var s : float = randf_range(.5, .7)
			baby.Name = "Kasu"
			baby.mesh.scale = Vector3(s, s, s)
			baby.originalStats = babyStats
			baby.originalStats.Distribute(floor(e.stats.MAG / 2.0))
			baby.stats = baby.originalStats.Copy()
			baby.UpdateStats()
			baby.moves = [babyMove]
			baby.cooldown.resize(baby.moves.size())
			baby.cooldown.fill(0)
			baby.Target(e.targetEntity)
			e.gridmap.minimap.Reveal(tiles[i])
			numSummons -= 1
			if numSummons < 1:
				break
	e.text.AddLine(e.GetLogName() + " called some " + LogText.WrapColor("Kasu", e.nameColor) + " for backup!\n")
	if numSummons == start:
		e.text.AddLine("But no one came!\n")

func PesterMove(e : Entity, t : Entity):
	var possibleItems : Array[String] = ["Flamefroth Tincture", "Paralysis Draught", "Imbued Wilds", "Healing Potion"]
	var use : int = randi_range(0, possibleItems.size() - 1)
	var useItem : Item = Items.items[possibleItems[use]]
	var message : String = e.GetLogName() + " brewed "
	match use:
		0:
			message += "a " + useItem.GetLogName() + " and drank it!\n"
			t.animator.Damage()
		1: message += "a " + useItem.GetLogName() + " and threw it!\n"
		2: message += "an " + useItem.GetLogName() + " and drank it!\n"
		_: message += "a " + useItem.GetLogName() + " and drank it!\n"
	e.text.AddLine(message)
	await useItem.move.Use(e, t)
	if use < 2:
		await e.Wait(.3)
	
func CinchMove(e : Entity, t : Entity):
	e.AddStatus(Status.Shadow(), 3)
	e.gridmap.PlaceTileEffect(e.gridPos, TileEffect.Effect.Shadow)
	var damage : int = Stats.GetDamage(e.stats, t.stats, true)
	e.text.AddLine(e.GetLogName() + " siphoned shadow from " + t.GetLogName() + " for " + LogText.GetDamageNum(damage, true) + " damage!\n")
	t.TakeDamage(damage)
