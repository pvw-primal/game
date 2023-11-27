class_name Entity
extends Node3D

var Type : String = "None"
var entityNum : int = -1

var speed : float = 0
const SPEED_U : float = .4
const SPEED_D : float = .01
const MAX_SPEED : float = 3
var targetPos : Vector3 = position

var gridPos : Vector2i
var targetGridPos : Vector2i = gridPos
var targetGridPosChanged : bool = true
var targetEntity : Entity = null
var startingPos : Vector2i
var facingPos : Vector2i

var moving : bool = false
var path : Array[Vector2i] = []
const OCCUPIED_WEIGHT : float = 10

signal startTurn
signal endTurn
signal move(pos : Vector2i, dir : Vector2i)
var turn : bool = false
var usedTurn : bool = false
var lastAction : Move.ActionType = Move.ActionType.other

var Name : String = "Unassigned"
var originalStats : Stats
var stats : Stats
var statuses : Dictionary
var statsChanged : bool = false
var equippedMove : Move = null
var moves : Array[Move] = []
var cooldown : Array[int]
var classE : Class
signal HPChange(currentHP : int, maxHP : int)

var inventory : Array[Item] = []
var inventorySize : int = 12
var equipped : int = -1
var equippedTool : int = -1

@onready var meshScene = preload("res://Assets/Enemy/MortalPester/MortalPester.tscn")
var mesh : Node3D
var animator : Animator

@onready var timer : Timer = get_node("Timer")
@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var text : TextScroll = get_node("/root/Root/Log/ScrollContainer")

func Initialize():
#	mesh = meshScene.instantiate()
#	add_child(mesh)
#	animator = get_node("Mesh/AnimationTree")
	
	turnhandler.AddEntity(self)
	startTurn.connect(StartTurn)
	endTurn.connect(EndTurn)
	Spawn(startingPos)

func Update(delta):
	if Type != "Player":
		position = position.lerp(targetPos, speed * delta / 2)
		position = position.move_toward(targetPos, speed * delta / 1.5)
	else:
		position = position.move_toward(targetPos, speed * delta)
	
	if moving:
		if speed < MAX_SPEED:
			speed += SPEED_U
		if targetPos == position:
			animator.Walk(false)
			moving = false
			if Type == "Player":
				endTurn.emit()
	elif speed > 0:
		speed -= SPEED_D

func Spawn(pos: Vector2i):
	RandomRotate(pos)
	gridPos = pos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(gridPos, entityNum)
	targetPos = gridmap.to_global(gridmap.map_to_local(Vector3i(gridPos.x, 0, gridPos.y)))
	targetPos = Vector3(targetPos.x, position.y, targetPos.z)
	position = targetPos
	
func SnapPosition(pos: Vector2i):
	facingPos = (2 * (pos - gridPos)) + gridPos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	Rotate(pos)
	gridPos = pos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(gridPos, entityNum)
	targetPos = gridmap.to_global(gridmap.map_to_local(Vector3i(gridPos.x, 0, gridPos.y)))
	targetPos = Vector3(targetPos.x, position.y, targetPos.z)
	position = targetPos
	gridmap.TakeItems(gridPos, self)
	move.emit(pos, facingPos - gridPos)

func MoveWorld(pos : Vector3):
	targetPos = Vector3(pos.x, position.y, pos.z)
	mesh.rotation.y = (Vector2(targetPos.x, position.z) - Vector2(position.x, targetPos.z)).angle()
	animator.Walk(true)
	moving = true
	
func MoveGrid(pos: Vector2i):
	facingPos = (2 * (pos - gridPos)) + gridPos
	MoveWorld(gridmap.to_global(gridmap.map_to_local(Vector3i(pos.x, 0, pos.y))))
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	gridPos = pos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(gridPos, entityNum)
	gridmap.TakeItems(gridPos, self)
	move.emit(pos, facingPos - gridPos)
	
func MovePath(pos: Vector2i):
	path = gridmap.Pathfinding.get_id_path(pos, gridPos)
	path.pop_back()
	
func Rotate(pos : Vector2i):
	var tPos = gridmap.to_global(gridmap.map_to_local(Vector3i(pos.x, 0, pos.y)))
	mesh.rotation.y = (Vector2(tPos.x, position.z) - Vector2(position.x, tPos.z)).angle()
	facingPos = pos
	
func RandomRotate(pos : Vector2i):
	var rotPos = Vector2i.ZERO
	while rotPos == pos:
		rotPos = Vector2i(pos.x + randi_range(-1, 1), pos.y + randi_range(-1, 1))
	Rotate(rotPos)

func Swap(pos: Vector2i):
	var e = GetEntity(pos)
	e.usedTurn = true
	e.MoveGrid(gridPos)
	MoveGrid(pos)
	gridmap.Pathfinding.set_point_weight_scale(e.gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(e.gridPos, e.entityNum)
	gridmap.minimap.Reveal(e.gridPos)
	endTurn.emit()

func SetMesh(meshPath : String):
	var s = load(meshPath)
	mesh = s.instantiate()
	add_child(mesh)
	animator = get_node("Mesh/AnimationTree")

func StartTurn():
	Heal(1)
	for SN in statuses.keys():
		if !statuses[SN].OnTurnStart.is_null():
			statuses[SN].OnTurnStart.call(self)
	for i in range(cooldown.size()):
		if cooldown[i] != 0:
			cooldown[i] -= 1
		if Type == "Player":
			self.skillUI.UpdateSkill(i, cooldown[i])
	turn = true
	
func EndTurn():
	turn = false
	for SN in statuses.keys():
		statuses[SN].turnsRemaining -= 1
		if statuses[SN].turnsRemaining <= 0:
			if !statuses[SN].OnStatCheck.is_null() || !statuses[SN].OnPercentStatCheck.is_null():
				statsChanged = true
			statuses.erase(statuses[SN].name)
			
	if gridPos in gridmap.tileEffects.keys():
		gridmap.tileEffects[gridPos].applyEffect.call(self)
	
	if statsChanged:
		UpdateStats()
		statsChanged = false
		
func Die():
	if Type == "Player":
		get_tree().quit()
		return
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	text.AddLine(Name + " was defeated!" + "\n")
	turnhandler.RemoveEntity(entityNum)
	for i in inventory:
		gridmap.PlaceItem(gridPos, i)
	if gridmap.minimap.get_cell_source_id(0, gridPos) != -1:
		gridmap.minimap.Reveal(gridPos)
	endTurn.emit()
	usedTurn = true
	if Type == "Ally":
		turnhandler.Entities[turnhandler.player].UpdateAllies()
	queue_free.call_deferred()
		
func Wait(time : float):
	timer.one_shot = true
	timer.start(time)
	await timer.timeout

func GetEntity(pos : Vector2i):
	return turnhandler.Entities[gridmap.GetMapPos(pos)] if gridmap.GetMapPos(pos) >= 0 else null

func CheckDirection(dir : Vector2i, r : int):
	var pos = gridPos + dir
	var lastPos = gridPos
	for i in range(r):
		if gridmap.GetMapPos(pos) == -2:
			return [lastPos, null]
		var e = GetEntity(pos)
		if e != null:
			return [pos, e]
		lastPos = pos
		pos += dir
	return [lastPos, null]

func AdjacentTiles():
	var adj = []
	for dir in [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1)]:
		if gridmap.GetMapPos(dir + gridPos) != -2:
			adj.append(dir + gridPos)
	return adj

func SetColor(cR : Color, cG : Color, cB: Color):
	for child in mesh.get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		child.set_instance_shader_parameter("replaceR", cR)
		child.set_instance_shader_parameter("replaceG", cG)
		child.set_instance_shader_parameter("replaceB", cB)
			

func UpdateStats():
	var statcopy = originalStats.Copy()
	var additiveMod : Array[float] = [1, 1, 1, 1] #POW, DEF, MAG, RES
	for SN in statuses.keys():
		if !statuses[SN].OnStatCheck.is_null():
			statuses[SN].OnStatCheck.call(statcopy)
		if !statuses[SN].OnPercentStatCheck.is_null():
			statuses[SN].OnPercentStatCheck.call(additiveMod)
	stats.CopyAll(statcopy.Modified(additiveMod))

func ChangeStats(s : Stats):
	originalStats = s
	stats = originalStats.Copy()
	UpdateStats()

func AddStatus(status : Status, turns : int):
	var changed = false
	if status.name not in statuses:
		statuses[status.name] = status
	else:
		changed = true
	statuses[status.name].turnsRemaining = turns
	if changed || !status.OnStatCheck.is_null() || !status.OnPercentStatCheck.is_null():
		UpdateStats()
		
func RemoveStatus(status : String):
	if status in statuses:
		statuses.erase(status)
		UpdateStats()

func TakeDamage(damage : int, source : Entity = null):
	stats.HP -= damage
	if source != null:
		targetEntity = source
		targetGridPos = source.gridPos
	HPChange.emit(stats.HP, stats.maxHP)
	if stats.HP < 1:
		Die()

func Heal(healing : int):
	var originalHP = stats.HP
	stats.HP += healing
	if stats.HP > stats.maxHP:
		stats.HP = stats.maxHP
	HPChange.emit(stats.HP, stats.maxHP)
	return stats.HP - originalHP

func Equip(id : int):
	equipped = id
	equippedMove = inventory[id].move

func Unequip():
	equipped = -1
	equippedMove = null

func StartCooldown(id : int):
	cooldown[id] = moves[id].cooldown
	
func StartCooldownName(n : String):
	for i in range(moves.size()):
		if moves[i].name == n:
			StartCooldown(i)
	
func OnCooldown(id : int):
	return cooldown[id] > 0

func Remove():
	pass
	
