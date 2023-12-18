class_name Player
extends Entity

const inputCooldown : float = .05
var inputCD : float = 0
var ignoreInput = false
var action = false

var allies : Array[Entity]

signal OnAllyDeath(player : Player, ally : Entity)

@onready var inventoryUI : InventoryViewport = get_node("/root/Root/InventoryUI3D")
@onready var option : OptionMenu = get_node("/root/Root/OptionUI")
@onready var skillUI : SkillUI = get_node("/root/Root/SkillUI")

var equippedMove : Move = null
var equipped : int = -1

func _ready():
	SetMesh("res://Assets/Enemy/MortalPester/MortalPester.tscn")
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
	onDeath.connect(Die)
	
func partialInit(pos : Vector2i, num : int):
	entityNum = num
	startingPos = pos

func SetClass(c : Class, i : Item):
	classE = c
	moves = classE.moves
	cooldown.resize(moves.size())
	cooldown.fill(0)
	for passive in classE.passives:
		passive.PassiveApply.call(self)
	var inventory : Array[Item] = [i, Items.items["Tunneling Tools"], Items.items["Paralysis Draught"], Items.items["Flamefroth Tincture"], Items.items["Blighter's Brew"], Items.items["Pebblepod"]]
	inventoryUI.init(inventory, 12)
	inventoryUI.Equip(0)

func _process(delta):
	Update(delta)
	if inputCD > 0:
		inputCD -= delta
	elif turn && !moving && !ignoreInput && !action && stats.CanAttack:
		if Input.is_action_just_pressed("EquipAttack") && equippedMove != null:
			action = true
			var e = GetEntity(facingPos)
			await equippedMove.Use(self, e)
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif moves.size() > 0 && Input.is_action_just_pressed("Attack1") && moves[0] != null && !OnCooldown(0):
			action = true
			var e = GetEntity(facingPos)
			await moves[0].Use(self, e)
			skillUI.UpdateSkill(0, cooldown[0])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif moves.size() > 1 && Input.is_action_just_pressed("Attack2") && moves[1] != null && !OnCooldown(1):
			action = true
			var e = GetEntity(facingPos)
			await moves[1].Use(self, e)
			skillUI.UpdateSkill(1, cooldown[1])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.targetEntity = e
		elif moves.size() > 2 && Input.is_action_just_pressed("Attack3") && moves[2] != null && !OnCooldown(2):
			action = true
			var e = GetEntity(facingPos)
			await moves[2].Use(self, e)
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

func GetItem(i : int) -> Item:
	return inventoryUI.inventory[i].item

func Die():
	get_tree().quit()

func PickupItem(i : Item):
	inventoryUI.AddItem(i)

func IsInventoryFull() -> bool:
	return inventoryUI.InventoryFull()

func UpdateAllies():
	for i in range(allies.size()):
		if GetEntity(allies[i].gridPos) == null:
			allies.remove_at(i)
			return
			
#DO NOT ADD ANYTHING TO START, USE ENTITY.START INSTEAD
func Start():
	action = false
