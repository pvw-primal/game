#TODO: ensure that GenerateMapLayout generates all rooms properly
#      create RectTouching() function to fix diagonal groups
class_name MapGenerator
extends GridMap

#MAX values are INCLUSIVE
const NUM_ROOMS : int = 25
const ROOM_MIN : int = 4 #5
const ROOM_MAX : int = 10 #25
const ROOM_BORDER_MIN : int = 4
const ROOM_BORDER_MAX : int = 6 #10
const ROOM_PATH_MIN : int = 1
const ROOM_PATH_MAX : int = 1
const ROOM_PATH_MAX_DISTANCE : float = 50
const ROOM_ORIGIN : Vector2i = Vector2i.ZERO
const MAP_BORDER : int = 9
const NUM_EXITS : int = 3

var rooms : Array = []
var roomGroups : Array = []
var groupNum = 0
var lastRoom = -1

var Pathfinding : AStarGrid2D = AStarGrid2D.new()
var rawPathfinding : AStarGrid2D = AStarGrid2D.new()
var lowest : Vector2i = ROOM_ORIGIN
var highest : Vector2i = ROOM_ORIGIN

var map : Array[Array]
var offsetX : int = 0
var offsetY : int = 0

var exits : Dictionary = {}
var items : Dictionary = {}
var tileEffects : Dictionary = {}

@onready var minimap : Minimap = get_node("/root/Root/MinimapContainer/Minimap")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var controller : Controller = get_node("/root/Root/Controller")
@onready var anglelight : DirectionalLight3D = get_node("/root/Root/Anglelight")
@onready var shadowlight : DirectionalLight3D = get_node("/root/Root/Shadowlight")
@onready var item = preload("res://Scripts/Gameplay/Inventory/item3D.tscn")
@onready var tileEffect = preload("res://Scripts/Gridmap/Tiles/TileEffect.tscn")
@onready var projectile = preload("res://Scripts/Gameplay/Projectile.tscn")

# Called when the node enters the scene tree for the first time.
func init():
	GenerateRooms(GenerateMapLayout(ROOM_ORIGIN, NUM_ROOMS))
	lastRoom = rooms.size() - 1
	GenerateMapPaths()
	lowest -= Vector2i(MAP_BORDER, MAP_BORDER)
	highest += Vector2i(MAP_BORDER, MAP_BORDER)
	Pathfinding.region = Rect2i(lowest, (highest - lowest))
	Pathfinding.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	Pathfinding.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	Pathfinding.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	Pathfinding.update()
	rawPathfinding.region = Rect2i(lowest, (highest - lowest))
	rawPathfinding.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	rawPathfinding.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	rawPathfinding.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	rawPathfinding.update()
	
	for i in range(highest.x - lowest.x):
		var heightMap = []
		heightMap.resize(highest.y - lowest.y)
		heightMap.fill(-1)
		map.append(heightMap)
	offsetX = lowest.x
	offsetY = lowest.y
	
	for i in range(NUM_EXITS):
		var spot = GetRandomRoomPos()
		exits[spot] = null
		set_cell_item(Vector3i(spot.x, 0, spot.y), 4)
	
	var angles = [0, PI / 2]
	for x in range(lowest.x, highest.x):
		for y in range(lowest.y, highest.y):
			if get_cell_item(Vector3i(x, 0, y)) == INVALID_CELL_ITEM:
				Pathfinding.set_point_solid(Vector2i(x, y))
				rawPathfinding.set_point_solid(Vector2i(x, y))
				set_cell_item(Vector3i(x, 0, y), randi_range(1, 3), get_orthogonal_index_from_basis(Basis(Vector3.UP, angles[randi_range(0, 1)])))
				map[x - offsetX][y - offsetY] = -2
	
	var numItems = randi_range(8, 15)
	for i in range(numItems):
		var spot = GetRandomRoomPos()
		while spot in exits:
			spot = GetRandomRoomPos()
		PlaceItem(spot, controller.level.RandomItem(), -2)
		
	anglelight.light_color = controller.level.color
	shadowlight.light_color = controller.level.color
				
func GenerateMapLayout(pos: Vector2i, numRooms: int):
	var bound = Rect2i(pos.x, pos.y, randi_range(ROOM_MIN, ROOM_MAX), randi_range(ROOM_MIN, ROOM_MAX))
	var roomBounds = [ bound ]
	numRooms -= 1
	
	var border = randi_range(ROOM_BORDER_MIN, ROOM_BORDER_MAX)
	var roomDistribution
	for lastPos in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var size = Vector2i(randi_range(ROOM_MIN, ROOM_MAX), randi_range(ROOM_MIN, ROOM_MAX))
		roomDistribution = randi_range(0, numRooms)
		var newPos
		if lastPos == Vector2i.RIGHT:
			newPos = pos + Vector2i(-border - size.x, 0)
		elif lastPos == Vector2i.LEFT:
			newPos = pos + Vector2i(border + bound.size.x, 0)
		elif lastPos == Vector2i.UP:
			newPos = pos + Vector2i(0, -border - size.y)
		else:
			newPos = pos + Vector2i(0, border + bound.size.y)
		GenerateMapLayoutR(size, newPos, lastPos, roomDistribution, roomBounds)
		numRooms -= roomDistribution
	return roomBounds

func GenerateMapLayoutR(roomSize: Vector2i, pos: Vector2i, lastPos: Vector2i, remainingRooms: int, roomBounds: Array):
	if remainingRooms <= 0:
		return
	var bound = Rect2i(pos.x, pos.y, roomSize.x, roomSize.y)
	roomBounds.append(bound)
	remainingRooms -= 1
	
	var border = randi_range(ROOM_BORDER_MIN, ROOM_BORDER_MAX)
	var roomDistribution
	for newlastPos in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var size = Vector2i(randi_range(ROOM_MIN, ROOM_MAX), randi_range(ROOM_MIN, ROOM_MAX))
		roomDistribution = randi_range(0, remainingRooms)
		var newPos
		if newlastPos == Vector2i.RIGHT:
			if lastPos == Vector2i.LEFT or remainingRooms <= 0:
				continue
			newPos = pos + Vector2i(-border - size.x, 0)
		elif newlastPos == Vector2i.LEFT:
			if lastPos == Vector2i.RIGHT or remainingRooms <= 0:
				continue
			newPos = pos + Vector2i(border + bound.size.x, 0)
		elif newlastPos == Vector2i.UP:
			if lastPos == Vector2i.DOWN or remainingRooms <= 0:
				continue
			newPos = pos + Vector2i(0, -border - size.y)
		else:
			if lastPos == Vector2i.UP or remainingRooms <= 0:
				continue
			newPos = pos + Vector2i(0, border + bound.size.y)
		GenerateMapLayoutR(size, newPos, newlastPos, roomDistribution, roomBounds)
		remainingRooms -= roomDistribution

func GenerateRooms(roomList: Array):
	for room in roomList:
		AddRoom(room)
		
func BuildRoom(room: Rect2i):
	for x in range(room.position.x, room.position.x + room.size.x):
		if x < lowest.x:
			lowest.x = x
		elif x > highest.x:
			highest.x = x
		for y in range(room.position.y, room.position.y + room.size.y):
			if y < lowest.y:
				lowest.y = y
			elif y > highest.y:
				highest.y = y
			set_cell_item(Vector3i(x, 0, y), 0)

func AddRoom(room: Rect2i):
	var alone = true
	for i in range(roomGroups.size()):
		if room.grow_individual(1, 1, 1, 1).intersects(rooms[i]):
			alone = false
			var groupToChange = roomGroups[i]
			roomGroups[i] = groupNum
			if groupToChange != -1:
				for r in range(roomGroups.size()):
					if roomGroups[r] == groupToChange:
						roomGroups[r] = groupNum
	rooms.append(room)
	if alone:
		roomGroups.append(-1)
	else:
		roomGroups.append(groupNum)
	groupNum = groupNum if alone else groupNum + 1
	BuildRoom(room)
	
func NumGroups():
	var groups = {}
	var lone = 0
	for i in range(roomGroups.size()):
		if roomGroups[i] == -1:
			lone += 1
		else:
			groups[roomGroups[i]] = true
	return groups.keys().size() + lone
	
func BuildHorizontalPath(pos1: Vector2i, pos2: Vector2i, width: int):
	var offset = pos2.x
	if pos1.x < pos2.x:
		AddRoom(Rect2i(pos1.x, pos1.y, pos2.x - pos1.x + width, width))
	elif pos1.x > pos2.x:
		offset = pos1.x
		AddRoom(Rect2i(pos2.x, pos2.y, pos1.x - pos2.x + width, width))
	return offset
	
func BuildVerticalPath(pos1: Vector2i, pos2: Vector2i, width: int, offset: int):
	if pos1.y < pos2.y:
		AddRoom(Rect2i(offset, pos1.y, width, pos2.y - pos1.y))
	elif pos1.y > pos2.y:
		AddRoom(Rect2i(offset, pos2.y, width, pos1.y - pos2.y))
		
func BuildPath(pos1: Vector2i, pos2: Vector2i, width: int):
	BuildVerticalPath(pos1, pos2, width, BuildHorizontalPath(pos1, pos2, width))
	
func GenerateMapPaths():
	while NumGroups() > 1:
		var roomNum1 = randi_range(0, roomGroups.size() - 1)
		var roomNum2 = roomNum1
		while roomGroups[roomNum2] == roomGroups[roomNum1]:
			if roomGroups[roomNum2] == -1 and roomNum2 != roomNum1:
				break
			roomNum2 = randi_range(0, roomGroups.size() - 1)
		var room1 : Rect2i = rooms[roomNum1]
		var room2 : Rect2i = rooms[roomNum2]
		var pos1 = Vector2(randi_range(room1.position.x, room1.end.x - 1), randi_range(room1.position.y, room1.end.y - 1))
		var pos2 = Vector2(randi_range(room2.position.x, room2.end.x - 1), randi_range(room2.position.y, room2.end.y - 1))
		if pos1.distance_to(pos2) > ROOM_PATH_MAX_DISTANCE:
			continue
		BuildPath(pos1, pos2, randi_range(ROOM_PATH_MIN, ROOM_PATH_MAX))

#assumes Cpos and Tpos are adjacent
func CanMove(Cpos : Vector2i, Tpos : Vector2i):
	return Pathfinding.get_point_weight_scale(Tpos) <= 1 && Pathfinding.get_id_path(Cpos, Tpos).size() == 2
	
#assumes Cpos and Tpos are adjacent
func NoCorners(Cpos : Vector2i, Tpos : Vector2i):
	return Pathfinding.get_id_path(Cpos, Tpos).size() == 2

func GetMapPos(pos: Vector2i):
	return map[pos.x - offsetX][pos.y - offsetY]
	
func SetMapPos(pos : Vector2i, num : int):
	map[pos.x - offsetX][pos.y - offsetY] = num

func GetRandomRoomPos():
	var r : Rect2i = rooms[randi_range(0, lastRoom)]
	return Vector2i(randi_range(r.position.x + 1, r.end.x - 2), randi_range(r.position.y + 1, r.end.y - 2))

func Reset():
	rooms.clear()
	roomGroups.clear()
	groupNum = 0
	lastRoom = -1

	Pathfinding.clear()
	rawPathfinding.clear()
	lowest = ROOM_ORIGIN
	highest = ROOM_ORIGIN
	
	for i in range(map.size()):
		map[i].clear()
	map.clear()
	offsetX = 0
	offsetY = 0
	
	clear()
	minimap.clear()
	
	for child in get_children():
		child.queue_free()
	
	items.clear()
	tileEffects.clear()
	exits.clear()

func ExitCheck(pos : Vector2i, _dir : Vector2i):
	if pos in exits:
		await controller.NextLevel()

func PlaceItem(pos : Vector2i, i : Item, uses : int = -1):
	if pos in items.keys():
		items[pos].AddItem(i, uses)
	else:
		var ni : ItemWorld = item.instantiate()
		add_child(ni)
		var placePos = map_to_local(Vector3i(pos.x, 0, pos.y))
		ni.init(i, Vector3(placePos.x, ni.position.y, placePos.z), uses)
		items[pos] = ni
		
func TakeItems(pos : Vector2i, e : Entity):
	if pos in items.keys():
		if e.Type == "Player":
			for x in range(items[pos].items.size()):
				if e.IsInventoryFull():
					e.text.AddLine("Inventory is full!\n")
					break
				var uses = items[pos].PopUseMeta()
				var i : Item = items[pos].PopItem()
				e.PickupItem(i, uses)
				e.text.AddLine("Picked up " + i.GetLogName() + ".\n")
		elif e.Type == "Ally":
			var player = turnhandler.Entities[turnhandler.player]
			for x in range(items[pos].items.size()):
				if player.IsInventoryFull():
					e.text.AddLine("Inventory is full!\n")
					break
				var uses = items[pos].PopUseMeta()
				var i : Item = items[pos].PopItem()
				player.PickupItem(i, uses)
				player.text.AddLine(e.GetLogName() + " picked up " + i.GetLogName() + ".\n")
		else:
			for x in range(items[pos].items.size()):
				if e.IsInventoryFull():
					break
				var uses = items[pos].PopUseMeta()
				var i : Item = items[pos].PopItem()
				e.PickupItem(i, uses)
				e.text.AddLine(e.GetLogName() + " picked up " + i.GetLogName() + ".\n")
		if items[pos].items.size() <= 0:
			items[pos].queue_free()
			items.erase(pos)
	
func PlaceTileEffect(pos : Vector2i, effect : TileEffect.Effect, placer : Entity = null):
	if pos in tileEffects.keys():
		if tileEffects[pos].effect == effect:
			return
		tileEffects[pos].queue_free()
		
	var TE : TileEffect = tileEffect.instantiate()
	add_child(TE)
	var placePos = map_to_local(Vector3i(pos.x, 0, pos.y))
	TE.init(Vector3(placePos.x, TE.position.y, placePos.z), effect, pos)
	if placer == null:
		turnhandler.EndTurnOrder.connect(TE.OnTurn)
	else:
		placer.endTurn.connect(TE.OnTurn)
	tileEffects[pos] = TE
	
func RemoveTileEffect(pos : Vector2i):
	if pos in tileEffects.keys():
		tileEffects[pos].queue_free()
		tileEffects.erase(pos)

func SpawnProjectileTarget(attacker : Entity, defender : Entity, move : Callable, speed : float, t : PackedScene):
	var proj : Projectile = projectile.instantiate()
	proj.init(attacker, Vector3(defender.position.x, proj.position.y, defender.position.z), speed, t, move, defender)
	add_child(proj)
	
func SpawnProjectile(attacker : Entity, pos : Vector2i, speed : float, t : PackedScene):
	var proj : Projectile = projectile.instantiate()
	var placePos = map_to_local(Vector3i(pos.x, 0, pos.y))
	proj.init(attacker, Vector3(placePos.x, proj.position.y, placePos.z), speed, t)
	add_child(proj)
	
