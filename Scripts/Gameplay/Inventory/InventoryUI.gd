class_name InventoryUI
extends HBoxContainer

@onready var list : ItemList = get_node("ItemList")
@onready var description : RichTextLabel = get_node("Description")
@onready var popup : ItemList = get_node("ItemList/PopUp")

var player : Player
var selected
var popupSelect

func _ready():
	visible = false
	popup.visible = false
	list.item_selected.connect(Display)
	list.item_activated.connect(OpenMenu)
	popup.item_activated.connect(DismissMenu)

func _process(_delta):
	if Input.is_action_just_pressed("Inventory") && player.turn && !player.action:
		if visible:
			Close()
		else:
			Open()
	if visible:
		if popup.visible:
			if Input.is_action_just_pressed("MoveDown"):
				popupSelect = 0 if popupSelect + 1 >= popup.item_count else popupSelect + 1
				popup.select(popupSelect)
				popup.item_selected.emit(popupSelect)
			if Input.is_action_just_pressed("MoveUp"):
				popupSelect = popup.item_count - 1 if popupSelect - 1 < 0 else popupSelect - 1
				popup.select(popupSelect)
				popup.item_selected.emit(popupSelect)
			if Input.is_action_just_pressed("UISelect"):
				popup.item_activated.emit(popupSelect)
		else:
			if Input.is_action_just_pressed("MoveDown"):
				selected = 0 if selected + 1 >= list.item_count else selected + 1
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("MoveUp"):
				selected = list.item_count - 1 if selected - 1 < 0 else selected - 1
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("UISelect"):
				list.item_activated.emit(selected)
	
func Display(id : int):
	popup.visible = false
	selected = id
	var showCrafting : bool = player.classE.craftTinker.size() > 0 || player.classE.craftBrew.size() > 0
	description.text = player.inventory[id].GetDescription(showCrafting, player.classE.HasBase(Classes.BaseClass.Arcana) || player.classE.HasBase(Classes.BaseClass.Arms))
		
func Open():
	visible = true
	selected = 0
	player.ignoreInput = true
	for i in range(player.inventory.size()):
		if i == player.equipped:
			list.add_item(player.inventory[i].name + " (E)")
		else:
			list.add_item(player.inventory[i].name)
	list.select(selected)
	list.item_selected.emit(selected)
		
func Close():
	visible = false
	popup.visible = false
	description.text = ""
	player.ignoreInput = false
	list.clear()

func OpenMenu(id : int):
	popup.clear()
	popup.visible = true
	popup.grab_focus()
	popupSelect = 0
	if player.inventory[id].equipment && player.classE.HasProf(player.inventory[id].requiredProf):
		if player.equipped == id:
			popup.add_item("Unequip")
		else:
			popup.add_item("Equip")
	elif player.inventory[id].CanUse():
		popup.add_item(player.inventory[id].moveTooltip)
		
	popup.add_item("Drop")
	popup.add_item("Back")
	popup.select(popupSelect)
	popup.item_selected.emit(popupSelect)
	
func DismissMenu(id : int):
	if id == popup.item_count - 2:
		player.text.AddLine("Dropped " + player.inventory[selected].name + ". \n")
		player.endTurn.emit()
		player.lastAction = Move.ActionType.other
		player.gridmap.PlaceItem(player.gridPos, player.inventory[selected])
		if selected == player.equipped:
			player.Unequip()
		player.RemoveItemAt(selected)
		Close.call_deferred()
		return
	if id == popup.item_count - 1:
		list.grab_focus()
		popup.visible = false
		list.select(selected)
		list.item_selected.emit(selected)
		return
	Close.call_deferred()
	if player.inventory[selected].equipment:
		if selected == player.equipped:
			player.Unequip()
		else:
			player.Equip(selected)
		player.lastAction = Move.ActionType.other
		player.endTurn.emit()
		return
	player.inventory[selected].move.Use(player, player.GetEntity(player.facingPos))
	if player.inventory[selected].consumable:
		player.RemoveItemAt(selected)
	
