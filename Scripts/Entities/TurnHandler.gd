class_name TurnHandler
extends Node

@onready var entityhandler : EntityHandler = get_node("/root/Root/EntityHandler")

var TurnOrder : Array[int] = []
var Entities : Dictionary = {}
var currentTurn = 0
var player = -1
var RemovalQueue : Array[int] = []
var spawnChance : float

const MAX_MOVE_RENDER : float = 9
const MAX_MOVE_DISTANCE : float = 17

signal EndTurnOrder

func _ready(sc : float = 0):
	Entities[currentTurn].endTurn.connect(HandleNextTurn)
	Entities[currentTurn].startTurn.emit()
	spawnChance = sc

func AddEntity(entity : Entity):
	if entity.Type == "Player":
		player = entity.entityNum
	Entities[entity.entityNum] = entity
	TurnOrder.append(entity.entityNum)

func RemoveEntity(entityNum : int):
	for i in range(TurnOrder.size()):
		if TurnOrder[i] == entityNum:
			continue
		Entities[TurnOrder[i]].targetGridPos = Entities[player].gridPos
		Entities[TurnOrder[i]].targetGridPosChanged = true
	RemovalQueue.append(entityNum)
	
func HandleNextTurn(skipDisconnect : bool = false):
	if !skipDisconnect:
		Entities[TurnOrder[currentTurn]].endTurn.disconnect(HandleNextTurn)
	if currentTurn + 1 >= TurnOrder.size():
		currentTurn = 0
		while RemovalQueue.size() > 0:
			var remove = RemovalQueue.pop_back()
			TurnOrder.erase(remove)
			Entities.erase(remove)
		ReorderTurns()
		if randf_range(0, 1) > .8 && randf_range(0, 1) < spawnChance:
			entityhandler.SpawnAIOffscreen()
		EndTurnOrder.emit()
	else:
		currentTurn += 1
		
	if TurnOrder[currentTurn] in RemovalQueue:
		HandleNextTurn(true)
		return
		
	var entity = Entities[TurnOrder[currentTurn]]
	if TurnOrder[currentTurn] != player:
		if !is_instance_valid(entity.targetEntity):
			entity.targetEntity = Entities[player]
		var dist = entity.position.distance_to(entity.targetEntity.position)
		if entity.targetGridPos != entity.targetEntity.gridPos:
			entity.targetGridPos = entity.targetEntity.gridPos
			entity.targetGridPosChanged = true
		entity.renderMove = dist < MAX_MOVE_RENDER
		entity.shouldMove = dist < MAX_MOVE_DISTANCE
	entity.endTurn.connect(HandleNextTurn)
	entity.startTurn.emit()
	
func ReorderTurns():
	TurnOrder.sort_custom(SortPlayerDistance)
	
func SortPlayerDistance(aI : int, bI : int):
	var a : Entity = Entities[aI]
	var b: Entity = Entities[bI]
	if a.Type == "Player":
		return true
	elif b.Type == "Player":
		return false
	elif a.Type == "Ally":
		return true
	elif b.Type == "Ally":
		return false
	elif (!a.renderMove || !a.shouldMove):
		return false
	elif (!b.renderMove || !b.shouldMove):
		return true
	var pathfinding = Entities[player].gridmap.rawPathfinding
	return pathfinding.get_id_path(Entities[player].gridPos, a.gridPos).size() < pathfinding.get_id_path(Entities[player].gridPos, b.gridPos).size()
		
func Reset():
	RemovalQueue.clear()
	TurnOrder.clear()
	Entities.clear()
	currentTurn = 0
	player = -1
