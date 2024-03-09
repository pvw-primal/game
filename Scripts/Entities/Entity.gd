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
var dead : bool = false
signal onDeath

var turn : bool = false
var usedTurn : bool = false
var lastAction : Move.ActionType = Move.ActionType.other

var Name : String = "Unassigned"
var nameColor : Color = Color.WHITE

var originalStats : Stats
var stats : Stats
var statuses : Dictionary
var statusDuration : Dictionary
var immune : Dictionary
var statsChanged : bool = false
var combatTurns : int = 0

var moves : Array[Move] = []
var cooldown : Array[int]
var classE : Class
signal HPChange(currentHP : int, maxHP : int)

signal OnTurnStart(e : Entity)
signal OnMoveUse(e : Entity, t : Entity, name : String)
signal OnTileEffectPlace(e : Entity, pos : Vector2i, effect : TileEffect.Effect)
signal OnEnterTileEffect(e : Entity, effect : TileEffect.Effect)
signal OnDamage(e : Entity, source : Entity)

var mesh : Node3D
var animator : Animator

@onready var timer : Timer = get_node("Timer")
@onready var statusUI : StatusUI = get_node("StatusUI")

var gridmap : MapGenerator
var turnhandler : TurnHandler
var text : LogText

func Initialize():
	startTurn.connect(StartTurn)
	endTurn.connect(EndTurn)
	
func OnInit():
	gridmap = get_node("/root/Root/GridMap")
	turnhandler = get_node("/root/Root/TurnHandler")
	text = get_node("/root/Root/Log/LogText")
	
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
	gridPos = pos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(gridPos, entityNum)
	targetPos = gridmap.to_global(gridmap.map_to_local(Vector3i(gridPos.x, 0, gridPos.y)))
	targetPos = Vector3(targetPos.x, position.y, targetPos.z)
	position = targetPos
	RandomRotate(pos)
	
func SnapPosition(pos: Vector2i):
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	var newFacingPos = (pos - gridPos).sign() + pos
	gridPos = pos
	gridmap.Pathfinding.set_point_weight_scale(gridPos, OCCUPIED_WEIGHT)
	gridmap.SetMapPos(gridPos, entityNum)
	targetPos = gridmap.to_global(gridmap.map_to_local(Vector3i(gridPos.x, 0, gridPos.y)))
	targetPos = Vector3(targetPos.x, position.y, targetPos.z)
	position = targetPos
	Rotate(newFacingPos)
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
	var rotPos = pos
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
	var oldRotate = Vector3.ZERO
	if mesh != null:
		oldRotate = mesh.rotation
		mesh.queue_free()
	mesh = s.instantiate()
	mesh.rotation = oldRotate
	add_child(mesh)
	animator = get_node("Mesh/AnimationTree")
	
func SetMeshCopy(node : Node3D):
	var oldRotate = Vector3.ZERO
	if mesh != null:
		oldRotate = mesh.rotation
		mesh.queue_free()
	mesh = node.duplicate()
	mesh.rotation = oldRotate
	add_child(mesh)
	animator = get_node("Mesh/AnimationTree")

func StartTurn():
	OnTurnStart.emit(self)
	if combatTurns > 0:
		combatTurns -= 1
	else:
		Heal(1)
	for SN in statuses.keys():
		if !statuses[SN].OnTurnStart.is_null():
			await statuses[SN].OnTurnStart.call(self)
			if dead:
				return
	for i in range(cooldown.size()):
		if cooldown[i] != 0:
			cooldown[i] -= 1
		if Type == "Player":
			self.skillUI.UpdateSkill(i, cooldown[i])
	turn = true
	
func EndTurn():
	turn = false
	if dead:
		return
	var statusChanged = false
	for SN in statuses.keys():
		statusDuration[SN] -= 1
		if statusDuration[SN] <= 0:
			statusChanged = true
			if !statuses[SN].OnStatCheck.is_null() || !statuses[SN].OnPercentStatCheck.is_null():
				statsChanged = true
			var sn = statuses[SN].name
			statuses.erase(statuses[SN].name)
			statusDuration.erase(sn)
	
	if statusChanged:
		UpdateStatusUI()
		
	if gridPos in gridmap.tileEffects.keys():
		gridmap.tileEffects[gridPos].applyEffect.call(self)
		if lastAction == Move.ActionType.move:
			OnEnterTileEffect.emit(self, gridmap.tileEffects[gridPos].effect)
	
	if statsChanged:
		UpdateStats()
		statsChanged = false
		
func Wait(time : float):
	timer.one_shot = true
	timer.start(time)
	await timer.timeout

func Target(e : Entity):
	targetEntity = e
	if targetGridPos != e.gridPos:
		targetGridPosChanged = true
	targetGridPos = e.gridPos

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
			
func SetSize(s : float = randf_range(.9, 1.1)):
	mesh.scale = Vector3(s, s, s)

func UpdateStats():
	var statcopy = originalStats.Copy()
	var additiveMod : Array[float] = [1, 1, 1, 1, 0] #POW, DEF, MAG, RES
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
	if status.name in immune:
		return
	if status.name not in statuses:
		statuses[status.name] = status
		if status.icon != null:
			statusUI.icons.append(status.icon)
			statusUI.Enable()
		if !status.OnStatCheck.is_null() || !status.OnPercentStatCheck.is_null():
			UpdateStats()
	statusDuration[status.name] = turns
		
func RemoveStatus(status : String):
	if status in statuses:
		statuses.erase(status)
		statusDuration.erase(status)
		UpdateStats()
		UpdateStatusUI()

func UpdateStatusUI():
	statusUI.icons.clear()
	for SN in statuses.keys():
		if statuses[SN].icon != null:
			statusUI.icons.append(statuses[SN].icon)
	if statusUI.icons.size() <= 0:
		statusUI.Disable()
	else:
		statusUI.Enable()

func TakeDamage(damage : int, source : Entity = null):
	stats.HP -= damage
	if source != null:
		targetEntity = source
		targetGridPos = source.gridPos
	OnDamage.emit(self, source)
	HPChange.emit(stats.HP, stats.maxHP)
	combatTurns = 6
	if stats.HP < 1:
		onDeath.emit()

func Heal(healing : int):
	var originalHP = stats.HP
	stats.HP += healing
	if stats.HP > stats.maxHP:
		stats.HP = stats.maxHP
	HPChange.emit(stats.HP, stats.maxHP)
	return stats.HP - originalHP

func InCombat():
	return combatTurns > 0

func StartCooldown(id : int, cd : int = -1):
	cooldown[id] = moves[id].cooldown if cd == -1 else cd
	
func StartCooldownName(n : String, cd : int = -1):
	for i in range(moves.size()):
		if moves[i] != null && moves[i].name == n:
			StartCooldown(i, cd)
			return
	
func OnCooldown(id : int):
	return cooldown[id] > 0
	
func GetLogName() -> String:
	return "[color=#" + nameColor.to_html() + "]" + Name + "[/color]"
