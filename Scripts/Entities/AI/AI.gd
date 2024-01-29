class_name AI
extends Entity

var renderMove = false
var shouldMove = false

var inventory : Array[Item] = []
var inventorySize : int = 12
var useMeta : Dictionary

var tamer : Player

func _ready():
	Initialize()
	startTurn.connect(FindAction)
	move.connect(UpdateMap)
	
func init(pos : Vector2i, num : int, loadName : String, color : Array[Color] = []):
	partialInit(pos, num)
	onDeath.connect(Die)
	classE = Classes.GetClass(Classes.BaseClass.Beastmastery)
	
	var enemyData = Loader.GetEnemyData(loadName)
	moves = [Move.new(enemyData["move_name"])]
	cooldown.resize(moves.size())
	cooldown.fill(0)
	Name = enemyData["name"]
	SetMesh(enemyData["path"])
	tamer = null
	useMeta = {}
	if color.size() > 2:
		SetColor(color[0], color[1], color[2])
	
func partialInit(pos : Vector2i, num : int):
	startingPos = pos
	entityNum = num
	
func _process(delta):
	Update(delta)

#handles the AI's turn
func FindAction():
	if timer.time_left > 0:
		await timer.timeout
	if usedTurn: #used for Swap()
		endTurn.emit()
		usedTurn = false
		lastAction = Move.ActionType.other
		return
	if shouldMove && targetGridPosChanged:
		MovePath(targetGridPos)
		path.pop_front()
		targetGridPosChanged = false
	if path.size() > 0 && targetEntity.stats.CanBeTargeted:
		if !stats.CanMove:
			text.AddLine(GetLogName() + " can't move!\n")
			lastAction = Move.ActionType.other
			endTurn.emit()
			return
		var nextMove = path.pop_back()
		var mappos = gridmap.GetMapPos(nextMove)
		if mappos == -1:
			if renderMove:
				MoveGrid(nextMove)
			else:
				SnapPosition(nextMove)
			lastAction = Move.ActionType.move
			endTurn.emit()
			return
		elif mappos > -1 && GetEntity(nextMove).Type != "AI":
			targetEntity = GetEntity(nextMove)
			targetGridPos = GetEntity(nextMove).gridPos
	if shouldMove && !(Type == "Ally" && targetEntity.Type == "Player") && targetEntity.stats.CanBeTargeted: # attacking check
		if !stats.CanAttack:
			text.AddLine(GetLogName() + " can't attack!\n")
		elif moves[0].InRange(self, targetEntity):
			Rotate(targetGridPos)
			await Wait(.5)
			if is_instance_valid(targetEntity):
				await moves[0].Use(self, targetEntity)
			else:
				endTurn.emit()
			return
			
	lastAction = Move.ActionType.other
	endTurn.emit()
	
func UpdateMap(pos : Vector2i, dir : Vector2i):
	if gridmap.minimap.get_cell_source_id(0, pos) != -1 && renderMove:
		gridmap.minimap.Reveal(pos - dir)
		gridmap.minimap.Reveal(pos)

func Die():
	if dead:
		return
	dead = true
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	text.AddLine(GetLogName() + " was defeated!" + "\n")
	turnhandler.RemoveEntity(entityNum)
	for i in range(inventory.size()):
		var uses = useMeta[i] if i in useMeta else -1
		gridmap.PlaceItem(gridPos, inventory[i], uses)
	if gridmap.minimap.get_cell_source_id(0, gridPos) != -1:
		gridmap.minimap.Reveal(gridPos)
	endTurn.emit()
	usedTurn = true
	if Type == "Ally":
		turnhandler.Entities[turnhandler.player].OnAllyDeath.emit(turnhandler.Entities[turnhandler.player], self)
		turnhandler.Entities[turnhandler.player].UpdateAllies()
	queue_free.call_deferred()

func GetItem(i : int) -> Item:
	return inventory[i]

func HasItem(n : String) -> int:
	for i in range(inventory.size()):
		if inventory[i].name == n:
			return i
	return -1
	
func RemoveItemAt(itemPos : int):
	inventory.remove_at(itemPos)
	if itemPos in useMeta:
		useMeta.erase(itemPos)

func PickupItem(i : Item, uses : int):
	inventory.append(i)
	if i.consumable && uses == -2:
		if i.maxUses > 1:
			useMeta[inventory.size() - 1] = i.maxUses
	elif uses > 0:
		useMeta[inventory.size() - 1] = uses
	
func IsInventoryFull() -> bool:
	return inventory.size() >= inventorySize
