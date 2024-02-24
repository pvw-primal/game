class_name Structure
extends Entity

var own : Entity
var behavior : Callable
var duration : int
var structureName : String

#called when structure first is initialized, use for structure-structure connections
func _ready():
	Initialize()
	startTurn.connect(FindAction)

#called when structure is added to the main game scene, use for structure-main game connections
func init(pos : Vector2i, num : int, o : Entity, n : String, m : Node3D, ai : Callable, stat : Stats, color : Array[Color] = [], d : int = -1):
	OnInit()
	onDeath.connect(Die)
	
	behavior = ai
	stats = stat
	originalStats = stat
	cooldown = []
	Name =  o.Name + "'s " + n if o != null else n
	structureName = n
	SetMeshCopy(m)
	if color.size() > 2:
		SetColor(color[0], color[1], color[2])
	duration = d
	
	UpdateStatusUI()
	partialInit(pos, num)
	RandomRotate(gridPos)
	
#called when a new floor is reached, use for updating on a new floor
func partialInit(pos : Vector2i, num : int):
	startingPos = pos
	entityNum = num
	Spawn(startingPos)

func FindAction():
	if timer.time_left > 0:
		await timer.timeout
	if behavior != null:
		await behavior.call(self)
		
	if duration > 0:
		duration -= 1
		if duration < 1:
			await Wait(.6)
			onDeath.emit()
			return
	
	if turn:
		endTurn.emit()
	
	
func Die():
	if dead:
		return
	dead = true
	gridmap.Pathfinding.set_point_weight_scale(gridPos, 1)
	gridmap.SetMapPos(gridPos, -1)
	text.AddLine(GetLogName() + " was destroyed!" + "\n")
	turnhandler.RemoveEntity(entityNum)
	if gridmap.minimap.get_cell_source_id(0, gridPos) != -1:
		gridmap.minimap.Reveal(gridPos)
	endTurn.emit()
	usedTurn = true
	queue_free.call_deferred()

