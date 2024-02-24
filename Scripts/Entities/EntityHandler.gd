class_name EntityHandler
extends Node

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var inventoryUI : InventoryViewport = get_node("/root/Root/MenuUI/Inventory/InventoryWindow")
@onready var option : OptionMenu = get_node("/root/Root/OptionUI")
@onready var skillUI : SkillUI = get_node("/root/Root/SkillUI")

@onready var EnemyScene = preload("res://Scripts/Entities/AI/Enemy.tscn")
@onready var StructureScene = preload("res://Scripts/Entities/Structure/Structure.tscn")

var player : Player
var entityNum = 0
var distributeStats

func init(numEnemies : int = 7, ds : int = 2, initPlayer : bool = false):
	var startPos = gridmap.GetRandomRoomPos()
	inventoryUI.player = player
	option.player = player
	skillUI.player = player
	if initPlayer:
		add_child(player)
		player.init(startPos, entityNum, true)
	else:
		player.partialInit(startPos, entityNum)
	turnhandler.AddEntity(player)
	entityNum += 1
	
	if Global.DEBUG:
		player.option.OptionSelected.connect(tempClassSet)
		player.option.list.auto_height = false
		player.option.Open(["Shaman", "Arcanist", "Fighter", "Rogue", "Tamer", "Alchemist", "Mechanist", "Trickster", "Totemcarver", "Outcast", "Artificer"], {}, 350)
		
	skillUI.init()
	if player.allies.size() > 0:
		var possibleSpawns = player.AdjacentTiles()
		possibleSpawns.shuffle()
		
		var spawnPos : Vector2i
		for posi in possibleSpawns:
			if gridmap.GetMapPos(posi) == -1:
				spawnPos = posi
				break
		
		for ally in player.allies:
			if initPlayer:
				add_child(ally)
				ally.OnInit()
			
			ally.partialInit(spawnPos, entityNum)
		turnhandler.AddEntity(player.allies[0])
			
		entityNum += 1 #all allies have the same entityNum: only 1 should be out at a time
	
	distributeStats = ds
	for i in range(numEnemies):
		SpawnAI()
	
	gridmap.minimap.SetPosition(startPos)
	gridmap.minimap.OnMove(startPos, Vector2i.ZERO)

func tempClassSet (e : Entity, id : int):
	if id == 0:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Shamanism))
	elif id == 1:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arcana))
	elif id == 2:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arms))
	elif id == 3:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Technique))
	elif id == 4:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Beastmastery))
	elif id == 5:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Alchemy))
	elif id == 6:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Machining))
	elif id == 7:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arcana, Classes.BaseClass.Technique))
	elif id == 8:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Machining, Classes.BaseClass.Shamanism))
	elif id == 9:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Shamanism, Classes.BaseClass.Arms))
	elif id == 10:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Alchemy, Classes.BaseClass.Machining))
	else:
		get_tree().quit()
	e.option.OptionSelected.disconnect(tempClassSet)
	player.option.list.auto_height = true
	
func SpawnAIOffscreen():
	var spawnPos = gridmap.GetRandomRoomPos()
	while gridmap.GetMapPos(spawnPos) != -1 || gridmap.to_global(gridmap.map_to_local(Vector3i(spawnPos.x, 0, spawnPos.y))).distance_to(player.position) < turnhandler.MAX_MOVE_RENDER:
		spawnPos = gridmap.GetRandomRoomPos()
	SpawnAIAt(spawnPos)
		
func SpawnAI():
	var spawnPos = gridmap.GetRandomRoomPos()
	while gridmap.GetMapPos(spawnPos) != -1:
		spawnPos = gridmap.GetRandomRoomPos()
	SpawnAIAt(spawnPos)

func SpawnAIAt(pos : Vector2i, spawnAI : AI = null, distribute : int = -1) -> AI:
	var e : AI = EnemyScene.instantiate()
	e.targetEntity = player
	add_child(e)
	if spawnAI == null:
		var enemyName = %Controller.level.enemies.keys()[randi_range(0, %Controller.level.enemies.size() - 1)]
		e.init(pos, entityNum, enemyName, %Controller.level.GetRandomEnemyColor(enemyName))
		e.Type = "AI"
		e.SetSize()
		e.nameColor = Color.CRIMSON
		if distribute == -1:
			e.ChangeStats(e.originalStats.Distribute(distributeStats))
		else:
			e.ChangeStats(e.originalStats.Distribute(distribute))
	else:
		e.SetMeshCopy(spawnAI.mesh)
		e.init(pos, entityNum, "", [], false)
		e.Type = spawnAI.Type
		e.Name = spawnAI.Name
		e.mesh.scale = spawnAI.scale
		e.nameColor = spawnAI.nameColor
	turnhandler.AddEntity(e)
	entityNum += 1
	return e

func SpawnStructure(pos : Vector2i, o : Entity, n : String, mesh : Node3D, ai : Callable, stat : Stats, color : Array[Color] = [], duration : int = -1) -> Structure:
	var s : Structure = StructureScene.instantiate()
	s.targetEntity = player
	s.Type = "Structure"
	s.nameColor = Color.SLATE_GRAY
	add_child(s)
	s.init(pos, entityNum, o, n, mesh, ai, stat, color, duration)
	turnhandler.AddEntity(s)
	entityNum += 1
	gridmap.minimap.Reveal(s.gridPos)
	return s
	
func Reset():
	for e in get_children():
		if e.Type == "Player" || e.Type == "Ally":
			continue
		e.queue_free()
	entityNum = 0
