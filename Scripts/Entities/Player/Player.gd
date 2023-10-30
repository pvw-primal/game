class_name Player
extends Entity

const inputCooldown : float = .05
var inputCD : float = 0
var ignoreInput = false
var action = false

var allies : Array[Entity]

@onready var option : OptionMenu = get_node("/root/Root/OptionUI")
@onready var skillUI : SkillUI = get_node("/root/Root/SkillUI")

func _ready():
	Initialize()
	originalStats = Stats.new(40, 5, 1, 5, 1)
	stats = originalStats.Copy()
	UpdateStats()
	move.connect(gridmap.minimap.OnMove)
	move.connect(gridmap.ExitCheck)
	gridmap.minimap.OnMove(gridPos, Vector2i.ZERO)
	allies = []
	
func init(pos : Vector2i, num : int):
	Type = "Player"
	partialInit(pos, num)
	Name = "Player"
	startTurn.connect(Start)
	
func partialInit(pos : Vector2i, num : int):
	entityNum = num
	startingPos = pos

func SetClass(c : Classes.BaseClass, i : Item):
	classE = Classes.GetClass(c)
	moves = classE.moves
	cooldown.resize(moves.size())
	cooldown.fill(0)
	inventory = [i]
	equipped = 0
	equippedMove = inventory[equipped].move

func _process(delta):
	Update(delta)
	if inputCD > 0:
		inputCD -= delta
	elif turn && !moving && !ignoreInput && !action && stats.CanAttack:
		if Input.is_action_just_pressed("EquipAttack") && equippedMove != null:
			action = true
			var e = GetEntity(facingPos)
			equippedMove.Use(self, e)
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif Input.is_action_just_pressed("Attack1") && moves[0] != null && !OnCooldown(0):
			action = true
			var e = GetEntity(facingPos)
			moves[0].Use(self, e)
			skillUI.UpdateSkill(0, cooldown[0])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif Input.is_action_just_pressed("Attack2") && moves[1] != null && !OnCooldown(1):
			action = true
			var e = GetEntity(facingPos)
			moves[1].Use(self, e)
			skillUI.UpdateSkill(2, cooldown[2])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif Input.is_action_just_pressed("Attack3") && moves[2] != null && !OnCooldown(2):
			action = true
			var e = GetEntity(facingPos)
			moves[2].Use(self, e)
			skillUI.UpdateSkill(2, cooldown[2])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		var dir : Vector2i = Vector2i.ZERO
		if Input.is_action_pressed("MoveLock") || !stats.CanMove:
			if Input.is_action_pressed("MoveUpLeft") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveLeft")):
				Rotate(gridPos + Vector2i(1, 1))
			elif Input.is_action_pressed("MoveUpRight") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveRight")):
				Rotate(gridPos + Vector2i(-1, 1))
			elif Input.is_action_pressed("MoveDownLeft") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveLeft")):
				Rotate(gridPos + Vector2i(1, -1))
			elif Input.is_action_pressed("MoveDownRight") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveRight")):
				Rotate(gridPos + Vector2i(-1, -1))
			elif Input.is_action_pressed("MoveUp"):
				Rotate(gridPos + Vector2i(0, 1))
			elif Input.is_action_pressed("MoveLeft"):
				Rotate(gridPos + Vector2i(1, 0))
			elif Input.is_action_pressed("MoveDown"):
				Rotate(gridPos + Vector2i(0, -1))
			elif Input.is_action_pressed("MoveRight"):
				Rotate(gridPos + Vector2i(-1, 0))
		elif Input.is_action_pressed("MoveUpLeft") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveLeft")):
			dir = Vector2i(1, 1)
		elif Input.is_action_pressed("MoveUpRight") || (Input.is_action_pressed("MoveUp") && Input.is_action_pressed("MoveRight")):
			dir = Vector2i(-1, 1)
		elif Input.is_action_pressed("MoveDownLeft") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveLeft")):
			dir = Vector2i(1, -1)
		elif Input.is_action_pressed("MoveDownRight") || (Input.is_action_pressed("MoveDown") && Input.is_action_pressed("MoveRight")):
			dir = Vector2i(-1, -1)
		elif Input.is_action_pressed("MoveUp"):
			dir = Vector2i(0, 1)
		elif Input.is_action_pressed("MoveLeft"):
			dir = Vector2i(1, 0)
		elif Input.is_action_pressed("MoveDown"):
			dir = Vector2i(0, -1)
		elif Input.is_action_pressed("MoveRight"):
			dir = Vector2i(-1, 0)
			
		if dir != Vector2i.ZERO:
			var pos = gridPos + dir
			if gridmap.CanMove(gridPos, pos):
				MoveGrid(pos)
				inputCD = inputCooldown
			elif GetEntity(pos) != null && GetEntity(pos).Type == "Ally":
				Swap(pos)
			else:
				Rotate(pos)
				return
			lastAction = Move.ActionType.move

func UpdateAllies():
	for i in range(allies.size()):
		if GetEntity(allies[i].gridPos) == null:
			allies.remove_at(i)
			return
			
#DO NOT ADD ANYTHING TO START, USE ENTITY.START INSTEAD
func Start():
	action = false
