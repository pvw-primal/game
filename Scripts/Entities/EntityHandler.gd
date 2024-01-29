class_name EntityHandler
extends Node

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var inventoryUI : InventoryViewport = get_node("/root/Root/InventoryUI3D")
@onready var option : OptionMenu = get_node("/root/Root/OptionUI")
@onready var skillUI : SkillUI = get_node("/root/Root/SkillUI")

@onready var EnemyScene = preload("res://Scripts/Entities/AI/Enemy.tscn")

var player : Player
var entityNum = 0
var distributeStats
var baseStats : Stats = Stats.new(6, 4, 1, 3, 0)

func init(numEnemies : int = 7, ds : int = 2, initPlayer : bool = false):
	var startPos = gridmap.GetRandomRoomPos()
	if initPlayer:
		player.init(startPos, entityNum)
		player.nameColor = Color.DEEP_SKY_BLUE
	else:
		player.partialInit(startPos, entityNum)
		player.Spawn(startPos)
	entityNum += 1
	
	inventoryUI.player = player
	option.player = player
	
	if initPlayer:
		add_child(player)
		player.option.OptionSelected.connect(tempClassSet)
		player.option.list.auto_height = false
		player.option.Open(["Shaman", "Arcanist", "Fighter", "Rogue", "Tamer", "Alchemist", "Mechanist", "Enchanter", "Warden", "Weaponsmith", "War Caster"], {}, 150)
		
	skillUI.player = player
	
	if player.allies.size() > 0:
		var possibleSpawns = player.AdjacentTiles()
		possibleSpawns.shuffle()
		for ally in player.allies:
			var spawnPos : Vector2i
			for posi in possibleSpawns:
				if gridmap.GetMapPos(posi) == -1:
					spawnPos = posi
					break
			ally.partialInit(spawnPos, entityNum)
			ally.Spawn(spawnPos)
			turnhandler.AddEntity(ally)
			entityNum += 1
	
	distributeStats = ds
	for i in range(numEnemies):
		SpawnAI()
	
	gridmap.minimap.SetPosition(startPos)
	gridmap.minimap.OnMove(startPos, Vector2i.ZERO)

func tempClassSet (e : Entity, id : int):
	var focus : bool = false
	if id == 0:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Shamanism))
		focus = true
	elif id == 1:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arcana))
		focus = true
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
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arcana, Classes.BaseClass.Machining))
	elif id == 8:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arms, Classes.BaseClass.Beastmastery))
	elif id == 9:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arms, Classes.BaseClass.Machining))
	elif id == 10:
		player.SetClass(Classes.GetClass(Classes.BaseClass.Arcana, Classes.BaseClass.Arms))
	else:
		get_tree().quit()
	var slot = player.inventoryUI.firstOpenSlot
	player.PickupItem(Items.RandomEquipment(false, Items.Rarity.Common, focus))
	player.inventoryUI.Equip(slot)
	e.option.OptionSelected.disconnect(tempClassSet)
	skillUI.init()
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

func SpawnAIAt(pos : Vector2i, spawnAI : AI = null, distribute : int = -1):
	var e : AI = EnemyScene.instantiate() if spawnAI == null else spawnAI
	e.targetEntity = player
	if spawnAI == null:
		var enemyName = %Controller.level.enemies.keys()[randi_range(0, %Controller.level.enemies.size() - 1)]
		e.init(pos, entityNum, enemyName, %Controller.level.GetRandomEnemyColor(enemyName))
		e.Type = "AI"
		e.nameColor = Color.CRIMSON
	entityNum += 1
	add_child(e)
	if distribute == -1:
		e.ChangeStats(baseStats.Distribute(distributeStats))
	else:
		e.ChangeStats(baseStats.Distribute(distribute))

func Reset():
	for e in get_children():
		if e.Type == "Player" || e.Type == "Ally":
			continue
		e.queue_free()
	entityNum = 0
