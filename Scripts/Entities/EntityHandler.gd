class_name EntityHandler
extends Node

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var inventoryUI : InventoryUI = get_node("/root/Root/InventoryUI")
@onready var option : OptionMenu = get_node("/root/Root/OptionUI")
@onready var skillUI : SkillUI = get_node("/root/Root/SkillUI")

@onready var PlayerScene = preload("res://Scripts/Entities/Player/Player.tscn")
@onready var EnemyScene = preload("res://Scripts/Entities/AI/Enemy.tscn")

var level : Level = null

var player : Player
var entityNum = 0
var distributeStats
var baseStats : Stats = Stats.new(6, 4, 1, 3, 0)

func _ready(pl : Player = null, numEnemies : int = 7, ds : int = 2):
	if level == null:
		level = gridmap.level
	var p : Player = PlayerScene.instantiate() if pl == null else pl
	var startPos = gridmap.GetRandomRoomPos()
	if pl == null:
		p.init(startPos, entityNum)
	else:
		p.partialInit(startPos, entityNum)
		p.Spawn(startPos)
	entityNum += 1
	player = p
	
	inventoryUI.player = player
	option.player = player
	
	if pl == null:
		add_child(player)
		player.option.OptionSelected.connect(tempClassSet)
		player.option.list.auto_height = false
		player.option.Open(["Shaman", "Arcanist", "Fighter", "Rogue", "Tamer", "Alchemist", "Mechanist"], [], 150)
		
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
	if id == 0:
		var i = Item.new("Starting Focus", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultMagical(), Classes.Proficiency.FocusBasic, { Items.RandomAspect(Classes.Proficiency.FocusBasic):null })
		player.SetClass(Classes.BaseClass.Shamanism, i)
	elif id == 1:
		var i = Item.new("Starting Focus", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultMagical(), Classes.Proficiency.FocusBasic, { Items.RandomAspect(Classes.Proficiency.FocusBasic):null })
		player.SetClass(Classes.BaseClass.Arcana, i)
	elif id == 2:
		var i = Item.new("Starting Weapon", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultPhysical(), Classes.Proficiency.WeaponBasic, { Items.RandomModifier(Classes.Proficiency.WeaponBasic):null })
		player.SetClass(Classes.BaseClass.Arms, i)
	elif id == 3:
		var i = Item.new("Starting Weapon", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultPhysical(), Classes.Proficiency.WeaponBasic, { Items.RandomModifier(Classes.Proficiency.WeaponBasic):null })
		player.SetClass(Classes.BaseClass.Technique, i)
	elif id == 4:
		var i = Item.new("Starting Weapon", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultPhysical(), Classes.Proficiency.WeaponBasic, { Items.RandomModifier(Classes.Proficiency.WeaponBasic):null })
		player.SetClass(Classes.BaseClass.Beastmastery, i)
	elif id == 5:
		var i = Item.new("Starting Weapon", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultPhysical(), Classes.Proficiency.WeaponBasic, { Items.RandomModifier(Classes.Proficiency.WeaponBasic):null })
		player.SetClass(Classes.BaseClass.Alchemy, i)
	elif id == 6:
		var i = Item.new("Starting Weapon", "A starter piece of equipment.", "")
		i.SetEquipment(Move.DefaultPhysical(), Classes.Proficiency.WeaponBasic, { Items.RandomModifier(Classes.Proficiency.WeaponBasic):null })
		player.SetClass(Classes.BaseClass.Machining, i)
	else:
		get_tree().quit()
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
		var enemyName = level.enemies.keys()[randi_range(0, level.enemies.size() - 1)]
		e.init(pos, entityNum, enemyName, level.GetRandomEnemyColor(enemyName))
		e.Type = "AI"
	entityNum += 1
	add_child(e)
	if distribute == -1:
		e.ChangeStats(baseStats.Distribute(distributeStats))
	else:
		e.ChangeStats(baseStats.Distribute(distribute))
	
#func SpawnAlly(pos : Vector2i):
#	var e : AI = EnemyScene.instantiate()
#	e.init(pos, entityNum, "Russ")
#	e.targetEntity = player
#	entityNum += 1
#	e.Name = "Ally"
#	e.Type = "Ally"
#	player.allies.append(e)
#	add_child(e)

func Reset():
	for e in get_children():
		if e.Type == "Player" || e.Type == "Ally":
			continue
		e.Remove()
		e.queue_free()
	player = null
	entityNum = 0
