class_name MenuUI
extends TabContainer

@onready var inventory : InventoryViewport = get_node("Inventory/InventoryWindow")
@onready var minimap : Minimap = get_node("/root/Root/MinimapContainer/Minimap")
@onready var statsUI : StatsUI = get_node("Stats")
@onready var movesUI : MovesUI = get_node("Skills")

signal OnWindowOpen()
signal OnWindowClose()

var locked : bool = false

func _ready():
	visible = false
	
func Process(delta):
	if Input.is_action_just_pressed("TabLeft") && !locked && visible:
		if current_tab - 1 < 0:
			UIInput(3)
		else:
			UIInput(current_tab - 1)
	elif Input.is_action_just_pressed("TabRight") && !locked && visible:
		if current_tab + 1 > 3:
			UIInput(0)
		else:
			UIInput(current_tab + 1)
	elif Input.is_action_just_pressed("UIClose"):
		if visible:
			if locked:
				inventory.Close(false)
				OnWindowClose.emit()
				return
			UIInput(current_tab)
	if current_tab == 0:
		inventory.Process(delta)

func UIInput(id : int):
	if visible:
		if current_tab == id:
			visible = false
			inventory.player.ignoreInput = false
			CloseTab(id)
			if !locked:
				tab_changed.disconnect(TabChanged)
			statsUI.changed = true
			OnWindowClose.emit()
		else:
			current_tab = id
	else:
		visible = true
		tabs_visible = true
		TabChanged(id, false)
		tab_changed.connect(TabChanged)
		locked = false
		OnWindowOpen.emit()

func TabChanged(id : int, close : bool = true):
	if close:
		CloseTab(get_previous_tab())
	match id:
		0:
			inventory.OnWindowClose.connect(OnClose)
			inventory.Open()
		1:
			inventory.player.ignoreInput = true
			minimap.ToggleMaximize(true)
		2:
			inventory.player.ignoreInput = true
			statsUI.DisplayStats([inventory.player] + inventory.player.allies)
		3:
			inventory.player.ignoreInput = true
			movesUI.DisplayMoves(inventory.player)
	current_tab = id

func CloseTab(id : int):
	match id:
		0:
			inventory.OnWindowClose.disconnect(OnClose)
			inventory.Close.call_deferred(false)
		1:
			minimap.ToggleMaximize(false)
		2:
			pass
		3:
			pass

func OtherInventoryOpen():
	current_tab = 0
	locked = true
	tabs_visible = false
	inventory.OnWindowClose.connect(OnClose)
	visible = true
	OnWindowOpen.emit()

func OnClose():
	if inventory.visible:
		visible = false
		tabs_visible = true
		inventory.OnWindowClose.disconnect(OnClose)
		statsUI.changed = true
		if !locked:
			tab_changed.disconnect(TabChanged)
		locked = false
	OnWindowClose.emit()
