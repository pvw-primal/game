class_name AI
extends Entity

var renderMove = false
var shouldMove = false

func _ready():
	Initialize()
	move.connect(UpdateMap)
	SetColor(Color.DIM_GRAY, Color.FIREBRICK, Color.FIREBRICK)
	
func init(pos : Vector2i, num : int):
	partialInit(pos, num)
	startTurn.connect(FindAction)
	classE = Classes.GetClass(Classes.BaseClass.Beastmastery)
	
	var enemyData
	if randi_range(0, 1) == 0:
		enemyData = Loader.GetEnemyData("Russ")
	else:
		enemyData = Loader.GetEnemyData("Mortal Pester")
	moves = [Move.new(enemyData["move_name"])]
	cooldown.resize(moves.size())
	cooldown.fill(0)
	Name = enemyData["name"]
	SetMesh(enemyData["path"])
	
func partialInit(pos : Vector2i, num : int):
	startingPos = pos
	entityNum = num
	
func _process(delta):
	Update(delta)

#handles the AI's turn
func FindAction():
	if usedTurn: #used for Swap()
		endTurn.emit()
		usedTurn = false
		lastAction = Move.ActionType.other
		return
	if shouldMove && targetGridPosChanged:
		MovePath(targetGridPos)
		path.pop_front()
		targetGridPosChanged = false
	if path.size() > 0 && stats.CanMove && targetEntity.stats.CanBeTargeted:
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
	if shouldMove && !(Type == "Ally" && targetEntity.Type == "Player") && stats.CanAttack && targetEntity.stats.CanBeTargeted: # attacking check
		if moves[0].InRange(self, targetEntity):
			Rotate(targetGridPos)
			await Wait(.5)
			if is_instance_valid(targetEntity):
				moves[0].Use(self, targetEntity)
			else:
				endTurn.emit()
			return
			
	lastAction = Move.ActionType.other
	endTurn.emit()
	
func UpdateMap(pos : Vector2i, dir : Vector2i):
	if gridmap.minimap.get_cell_source_id(0, pos) != -1 && renderMove:
		gridmap.minimap.Reveal(pos - dir)
		gridmap.minimap.Reveal(pos)
		

