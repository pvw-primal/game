class_name InventoryViewport
extends AspectRatioContainer

const INVENTORY_HEIGHT : int = 5
const INVENTORY_WIDTH : int = 3
const INVENTORY_OFFSET : float = .5

@onready var layout : Node3D = get_node("InventoryWindow/InventoryViewportContainer/InventoryViewport/InventoryLayout")
@onready var list : ItemList = get_node("InventoryWindow/ItemList")
@onready var viewport : SubViewport = get_node("InventoryWindow/InventoryViewportContainer/InventoryViewport")
@onready var description : RichTextLabel = get_node("InventoryWindow/Description")
@onready var popup : ItemList = get_node("InventoryWindow/PopUp")

@onready var bottomBar : RichTextLabel = get_node("InventoryWindow/BottomBar")

@onready var item : PackedScene = preload("res://Scripts/Gameplay/Inventory/iteminventory3D.tscn")
@onready var testicon : Texture2D = preload("res://Assets/InventoryIcon.png")
@onready var selectedicon : Texture2D = preload("res://Assets/Icons/InventorySelected.png")
@onready var disabledicon : Texture2D = preload("res://Assets/Icons/InventoryDisabled.png")

var inventory : Array[ItemInventory]
var lastSlot : int
var firstOpenSlot : int

var player : Player
var selected : int
var popupSelect : int

var recipe : Array[String] = []
var currentRecipeSlot : int = 0
var craftingSlots : Dictionary
var crafting : bool
var showPopup : bool
signal craftCompleted(e : Entity, i : Item)

var picking : bool
var searchItems : Dictionary

func _ready():
	var i : int = 0
	for y in range(INVENTORY_HEIGHT):
		for x in range(INVENTORY_WIDTH):
			inventory.append(item.instantiate()) 
			inventory[i].init(Vector3(0, -y * INVENTORY_OFFSET, x * INVENTORY_OFFSET))
			layout.add_child(inventory[i])
			list.add_item("", testicon, true)
			list.set_item_disabled(i, true)
			i += 1
	
	lastSlot = (INVENTORY_WIDTH * INVENTORY_HEIGHT) - 1
	firstOpenSlot = -1
	
	visible = false
	popup.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("Inventory") && player.turn && !player.action:
		if visible:
			Close(false)
			return
		else:
			Open()
	if visible:
		if showPopup:
			if Input.is_action_just_pressed("MoveDown"):
				popupSelect = 0 if popupSelect + 1 >= popup.item_count else popupSelect + 1
				popup.select(popupSelect)
				popup.item_selected.emit(popupSelect)
			elif Input.is_action_just_pressed("MoveUp"):
				popupSelect = popup.item_count - 1 if popupSelect - 1 < 0 else popupSelect - 1
				popup.select(popupSelect)
				popup.item_selected.emit(popupSelect)
			elif Input.is_action_just_pressed("UISelect"):
				popup.item_activated.emit(popupSelect)
			elif Input.is_action_just_pressed("UIBack"):
				if crafting:
					Close(false)
					return
				else:
					DismissMenu(popup.item_count - 1)
#
		else:
			if Input.is_action_just_pressed("MoveRight"):
				selected = selected - (INVENTORY_WIDTH - 1) if (selected + 1) % INVENTORY_WIDTH == 0 else selected + 1
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("MoveLeft"):
				selected = selected + (INVENTORY_WIDTH - 1) if (selected + 1) % INVENTORY_WIDTH == 1 else selected - 1
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("MoveDown"):
				selected = selected % INVENTORY_WIDTH if selected + INVENTORY_WIDTH > lastSlot else selected + INVENTORY_WIDTH
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("MoveUp"):
				selected = (lastSlot - (INVENTORY_WIDTH - 1)) + (selected % INVENTORY_WIDTH) if selected - INVENTORY_WIDTH < 0 else selected - INVENTORY_WIDTH
				list.select(selected)
				list.item_selected.emit(selected)
			elif Input.is_action_just_pressed("UISelect"):
				list.item_activated.emit(selected)
			elif Input.is_action_just_pressed("UIBack"):
				if crafting:
					if craftingSlots.size() == 0:
						showPopup = true
						popup.grab_focus()
						popup.select(popupSelect)
						popup.item_selected.emit(popupSelect)
						CraftingShowMaterial("")
						return
					else:
						CraftingBack()
				else:
					Close(false)

func init(items : Array[Item], slots : int):
	for i in range(slots):
		list.set_item_disabled(i, false)
		if i < items.size():
			inventory[i].ChangeItem(items[i])
		elif firstOpenSlot == -1:
			firstOpenSlot = i
	lastSlot = slots - 1
	
func Open():
	visible = true
	description.visible = true
	bottomBar.visible = false
	selected = 0
	player.ignoreInput = true
	crafting = false
	picking = false
	showPopup = false
	
	list.item_selected.connect(Display)
	list.item_activated.connect(OpenMenu)
	popup.item_activated.connect(DismissMenu)
	
	list.grab_focus()
	list.select(selected)
	list.item_selected.emit(selected)

func Display(id : int):
	popup.visible = false
	showPopup = false
	selected = id
	if inventory[id].item != null:
		description.visible = true
		description.text = inventory[id].item.GetDescription()
	else:
		description.visible = false

func OpenMenu(id : int):
	if inventory[id].item == null && player.equipped == -1:
		return
	
	popup.clear()
	popup.visible = true
	showPopup = true
	popup.grab_focus()
	popupSelect = 0
	if inventory[id].item == null && player.equipped != -1:
		popup.add_item("Unequip")
		popup.add_item("Back")
		popup.select(popupSelect)
		popup.item_selected.emit(popupSelect)
		return
		
	if inventory[id].item.equipment && player.classE.HasProf(inventory[id].item.requiredProf):
		if player.equipped == id:
			popup.add_item("Unequip")
		else:
			popup.add_item("Equip")
	elif inventory[id].item.CanUse():
		popup.add_item(inventory[id].item.moveTooltip)
		
	popup.add_item("Drop")
	popup.add_item("Back")
	popup.select(popupSelect)
	popup.item_selected.emit(popupSelect)
	
func DismissMenu(id : int):
	if inventory[selected].item == null && player.equipped != -1:
		if id == 0:
			Unequip()
			player.endTurn.emit()
			player.lastAction = Move.ActionType.other
			Close.call_deferred()
		else:
			list.grab_focus()
			popup.visible = false
			showPopup = false
			list.select(selected)
			list.item_selected.emit(selected)
		return
	if id == popup.item_count - 2:
		player.text.AddLine("Dropped " + inventory[selected].item.GetLogName() + ". \n")
		player.endTurn.emit()
		player.lastAction = Move.ActionType.other
		player.gridmap.PlaceItem(player.gridPos, inventory[selected].item)
		RemoveItem(selected)
		Close.call_deferred()
		return
	if id == popup.item_count - 1:
		list.grab_focus()
		popup.visible = false
		showPopup = false
		list.select(selected)
		list.item_selected.emit(selected)
		return
	Close.call_deferred()
	if inventory[selected].item.equipment:
		if selected == player.equipped:
			Unequip()
		else:
			Equip(selected)
		player.lastAction = Move.ActionType.other
		player.endTurn.emit()
		return
	inventory[selected].item.move.Use(player, player.GetEntity(player.facingPos))
	if inventory[selected].item.consumable:
		RemoveItem(selected)
		
func CraftingOpen(items : Array[String]):
	visible = true
	bottomBar.visible = true
	popupSelect = 0
	
	player.ignoreInput = true
	craftingSlots.clear()
	crafting = true
	picking = false
	
	popup.clear()
	for itemname in items:
		popup.add_item(itemname)
	popup.add_item("Cancel")
	
	popup.item_selected.connect(CraftingSelectCraft)
	popup.item_activated.connect(CraftingActivateCraft)
	list.item_selected.connect(CraftingSelectItem)
	list.item_activated.connect(CraftingActivateItem)
	
	popup.visible = true
	showPopup = true
	popup.grab_focus()
	popup.select(popupSelect)
	popup.item_selected.emit(popupSelect)

func CraftingSelectCraft(id : int):
	if !showPopup:
		popup.select(popupSelect)
		return
	popupSelect = id
	description.visible = true
	if id == popup.item_count - 1:
		description.text = "Cancel crafting."
		bottomBar.text = ""
	else:
		description.text = Items.items[popup.get_item_text(popupSelect)].GetDescription()
		bottomBar.text = DisplayRecipe(Items.items[popup.get_item_text(popupSelect)].crafting.recipe)
	
func CraftingActivateCraft(id : int):
	if !showPopup:
		popup.select(popupSelect)
		return
	if id == popup.item_count - 1:
		Close(false)
		return
	recipe = Items.items[popup.get_item_text(popupSelect)].crafting.recipe
	currentRecipeSlot = 0
	
	showPopup = false
	selected = 0
	list.select(selected)
	list.item_selected.emit(selected)
	list.grab_focus()
	CraftingShowMaterial(recipe[currentRecipeSlot])
	
func CraftingSelectItem(id : int):
	if showPopup:
		return
	selected = id
	if inventory[id].item != null:
		description.text = inventory[id].item.GetDescription()
	else:
		description.text = ""
	bottomBar.text = DisplayRecipe(recipe)

func CraftingActivateItem(id : int):
	if showPopup || list.get_item_icon(id) == disabledicon:
		return
	if id in craftingSlots:
		craftingSlots.erase(id)
		currentRecipeSlot -= 1
		list.set_item_icon(id, testicon)
		CraftingShowMaterial(recipe[currentRecipeSlot])
		return
	
	craftingSlots[id] = null
	list.set_item_icon(id, selectedicon)
	if craftingSlots.keys().size() == recipe.size():
		#adding items should be handled in move
		var shouldNotConsume : bool = recipe.size() > 1 && "notConsumeMaterialChance" in player.classE.classVariables
		for slot in craftingSlots.keys():
			list.set_item_icon(slot, testicon)
			if !shouldNotConsume || randf_range(0, 1) > player.classE.classVariables["notConsumeMaterialChance"]:
				RemoveItem(slot)
			else:
				player.text.AddLine(inventory[slot].item.GetLogName() + " was not consumed while crafting!\n")
				shouldNotConsume = false
		craftCompleted.emit(player, Items.items[popup.get_item_text(popupSelect)])
		Close()
		return
	currentRecipeSlot += 1
	CraftingShowMaterial(recipe[currentRecipeSlot])
	bottomBar.text = DisplayRecipe(recipe)

func DisplayRecipe(r : Array[String]) -> String:
	var s = "[indent]" + Items.items[popup.get_item_text(popupSelect)].name + " requires: "
	for i in range(r.size()):
		s += r[i] if i == r.size() - 1 else r[i] + ", "
	if !showPopup:
		s += "\nSelect one " + r[currentRecipeSlot] + " material."
	if craftingSlots.keys().size() > 0:
		s += "\nCurrently using: "
		for id in craftingSlots.keys():
			s += inventory[id].item.name + ", "
	
	return s + "[/indent]\n "

func CraftingShowMaterial(tag : String):
	if tag == "":
		for i in range(lastSlot + 1):
			list.set_item_icon(i, testicon)
		return
	for i in range(lastSlot + 1):
		if inventory[i].item == null || list.get_item_icon(i) == selectedicon:
			continue
		if tag in inventory[i].item.crafting.tags:
			list.set_item_icon(i, testicon)
		else:
			list.set_item_icon(i, disabledicon)

func CraftingBack():
	for id in craftingSlots:
		list.set_item_icon(id, testicon)
	craftingSlots.clear()
	currentRecipeSlot = 0
	CraftingShowMaterial(recipe[currentRecipeSlot])
	bottomBar.text = DisplayRecipe(recipe)

func PickerOpen(viableItems : Dictionary):
	visible = true
	bottomBar.visible = false
	selected = 0
	player.ignoreInput = true
	crafting = false
	picking = true
	showPopup = false
	
	list.item_selected.connect(PickerSelected)
	list.item_activated.connect(PickerActivated)
	
	searchItems = viableItems
	PickerSetSlots()
	
	list.grab_focus()
	list.select(selected)
	list.item_selected.emit(selected)
	
func PickerSelected(id : int):
	if inventory[id].item != null && inventory[id].item.name in searchItems.keys():
		selected = id
		popup.visible = false
		showPopup = false
		description.visible = true
		description.text = inventory[id].item.GetDescription()
		bottomBar.visible = true
		bottomBar.text = "[indent]" + searchItems[inventory[id].item.name] + "[/indent]"
	else:
		description.visible = false
		bottomBar.visible = false
		
func PickerActivated(id : int):
	if inventory[id].item != null && inventory[id].item.name in searchItems.keys():
		craftCompleted.emit(player, inventory[id].item)
		inventory[id].Remove()
		Close()

func PickerSetSlots(reset : bool = false):
	for i in range(lastSlot + 1):
		if inventory[i].item == null:
			continue
		if inventory[i].item.name in searchItems || reset:
			list.set_item_icon(i, testicon)
		else:
			list.set_item_icon(i, disabledicon)

func Close(craftcomplete : bool = true):
	visible = false
	popup.visible = false
	bottomBar.visible = false
	player.ignoreInput = false
	if crafting:
		popup.item_selected.disconnect(CraftingSelectCraft)
		popup.item_activated.disconnect(CraftingActivateCraft)
		list.item_selected.disconnect(CraftingSelectItem)
		list.item_activated.disconnect(CraftingActivateItem)
		CraftingShowMaterial("")
	elif picking:
		list.item_selected.disconnect(PickerSelected)
		list.item_activated.disconnect(PickerActivated)
		PickerSetSlots(true)
	else:
		list.item_selected.disconnect(Display)
		list.item_activated.disconnect(OpenMenu)
		popup.item_activated.disconnect(DismissMenu)
	if !craftcomplete:
		craftCompleted.emit(player, null)

func AddItem(i : Item):
	inventory[firstOpenSlot].ChangeItem(i)
	for x in range(lastSlot + 1):
		if inventory[x] != null && inventory[x].item == null:
			firstOpenSlot = x
			return
	firstOpenSlot = -1

func RemoveItem(slot : int):
	inventory[slot].Remove()
	if slot < firstOpenSlot || firstOpenSlot == -1:
		firstOpenSlot = slot
	if slot == player.equipped:
		Unequip()

func SwapItem(slot1 : int, slot2 : int):
	if inventory[slot1].item == null:
		inventory[slot1].ChangeItem(inventory[slot2].item)
		inventory[slot2].Remove()
		if slot2 < slot1:
			firstOpenSlot = slot2
	else:
		var temp : Item = inventory[slot2].item
		inventory[slot2].ChangeItem(inventory[slot1].item)
		inventory[slot1].ChangeItem(temp)

func InventoryFull() -> bool:
	return firstOpenSlot == -1

func Equip(id : int):
	SwapItem(lastSlot + 1, id)
	player.equipped = lastSlot + 1
	
func Unequip():
	if firstOpenSlot == -1:
		return
	SwapItem(firstOpenSlot, lastSlot + 1)
	player.equipped = -1
	for x in range(lastSlot + 1):
		if inventory[x] != null && inventory[x].item == null:
			firstOpenSlot = x
			return
	firstOpenSlot = -1
