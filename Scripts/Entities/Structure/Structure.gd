class_name Structure
extends Entity

var own : Entity
var behavior : Callable
var duration : int
var structureName : String

func _ready():
	Initialize()
	RandomRotate(gridPos)
	gridmap.minimap.Reveal(gridPos)
	startTurn.connect(FindAction)
	
func init(pos : Vector2i, num : int, o : Entity, n : String, m : Node3D, ai : Callable, stat : Stats, color : Array[Color] = [], d : int = -1):
	partialInit(pos, num)
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
		
func partialInit(pos : Vector2i, num : int):
	startingPos = pos
	entityNum = num

func FindAction():
	if timer.time_left > 0:
		await timer.timeout
	if behavior != null:
		await behavior.call(self)
		
	if duration > 0:
		duration -= 1
		if duration < 1:
			onDeath.emit()
			return
	
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

