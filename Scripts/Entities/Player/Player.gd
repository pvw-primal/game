class_name Player
extends Entity

var ignoreInput = false
var action = false

var maxAllies : int = 1
var allies : Array[Entity]

signal OnTame(player : Player, ally : Entity)
signal OnAllyDeath(player : Player, ally : Entity)
signal OnFloorStart(player : Player)
signal OnLevelStart(player : Player)
signal OnLevelEnd(player : Player)

var inventoryUI : InventoryViewport
var option : OptionMenu
var skillUI : SkillUI
var input : PlayerInput

var equipped : int = -1

#called when player first is initialized, use for player-player connections (only called once)
func _ready():
	Initialize()
	Type = "Player"
	nameColor = Color.DEEP_SKY_BLUE
	startTurn.connect(Start)
	onDeath.connect(Die)
	if mesh == null:
		SetMesh("res://Assets/Enemy/Cinch/Cinch.tscn")
	if originalStats == null:
		originalStats = Stats.new(25, 5, 1, 5, 1)
	
	allies = []
	
#called when player is added to the main game scene, use for player-main game connections
func init(pos : Vector2i, num : int, i : bool = false):
	if i:
		OnInit()
		inventoryUI = get_node("/root/Root/MenuUI/Inventory/InventoryWindow")
		if Global.initInventory:
			var inventory : Array[Item] = [Items.items["Fulminating Gravel"], Items.items["Eidolon Mass"], Items.items["Charshroom"]]
			inventoryUI.init(inventory, 12)
			PickupItem(Items.items["Smithing Gear"], -2)
			PickupItem(Items.items["Bandage"], -2)
			var e : int = PickupItem(Items.RandomEquipment(false, Items.Rarity.Common, false))
			inventoryUI.Equip(e)
			Global.initInventory = false
		else:
			inventoryUI.init(Global.inventory, 12)
			inventoryUI.Equip(equipped)
		option = get_node("/root/Root/OptionUI")
		skillUI = get_node("/root/Root/SkillUI")
		input = get_node("Input")
		input.init()
	statuses.clear()
	statusDuration.clear()
	move.connect(gridmap.minimap.OnMove)
	move.connect(gridmap.ExitCheck)
	HPChange.connect(skillUI.UpdateHP)
	stats = originalStats.Copy()
	UpdateStats()
	UpdateStatusUI()
	partialInit(pos, num)

#called when a new floor is reached, use for updating on a new floor
func partialInit(pos : Vector2i, num : int):
	entityNum = num
	startingPos = pos
	Spawn(startingPos)

func SetClass(c : Class):
	if classE != null:
		for passive in classE.passives:
			if !passive.PassiveRemove.is_null():
				passive.PassiveRemove.call(self)
		classE.classVariables.clear()
	classE = c
	moves = classE.moves
	cooldown.resize(moves.size())
	cooldown.fill(0)
	for passive in classE.passives:
		if !passive.PassiveApply.is_null():
			passive.PassiveApply.call(self)

func _process(delta):
	Update(delta)

func Process(_delta):
	if turn && !moving && !action && stats.CanAttack && !ignoreInput:
		if Input.is_action_just_pressed("EquipAttack") && equipped != -1:
			action = true
			var e = GetEntity(facingPos)
			await inventoryUI.inventory[equipped].item.Use(self, e, stats.CRIT)
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.Target(e)
		elif moves.size() > 0 && Input.is_action_just_pressed("Attack1") && moves[0] != null && !OnCooldown(0):
			action = true
			var e = GetEntity(facingPos)
			await moves[0].Use(self, e)
			skillUI.UpdateSkill(0, cooldown[0])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.Target(e)
		elif moves.size() > 1 && Input.is_action_just_pressed("Attack2") && moves[1] != null && !OnCooldown(1):
			action = true
			var e = GetEntity(facingPos)
			await moves[1].Use(self, e)
			skillUI.UpdateSkill(1, cooldown[1])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.Target(e)
		elif moves.size() > 2 && Input.is_action_just_pressed("Attack3") && moves[2] != null && !OnCooldown(2):
			action = true
			var e = GetEntity(facingPos)
			await moves[2].Use(self, e)
			skillUI.UpdateSkill(2, cooldown[2])
			if e != null && e.Type != "Ally":
				for ally in allies:
					ally.Target(e)
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
			elif GetEntity(pos) != null && GetEntity(pos).Type == "Ally":
				Swap(pos)
			else:
				Rotate(pos)
				return
			lastAction = Move.ActionType.move

func GetItem(i : int) -> Item:
	return inventoryUI.inventory[i].item

func GetEquippedMove() -> Move:
	if equipped == -1:
		return null
	return GetItem(equipped).move

func Die():
	get_tree().quit()

func PickupItem(i : Item, uses : int = -1) -> int:
	return inventoryUI.AddItem(i, uses)

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
