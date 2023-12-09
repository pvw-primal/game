class_name OptionMenu
extends HBoxContainer

@onready var list : ItemList = get_node("ItemList")
@onready var description : RichTextLabel = get_node("Description")

var player : Player
var selected

signal OptionSelected(e : Entity, id : int)
var disable : Dictionary = {}

var descriptions : Array[String]

func _ready():
	visible = false
	list.item_selected.connect(Display)
	list.item_activated.connect(ItemActivated)
	

func _process(_delta):
	if visible:
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
		elif Input.is_action_just_pressed("Inventory"):
			OptionSelected.emit(player, -1)
			Close()
	
func Display(id : int):
	selected = id
	if description.visible:
		description.text = descriptions[id]
		
func Open(options : Array[String], disabled : Dictionary = {}, OWidth : float = 75, desc : Array[String] = [], DWidth : float = 60):
	visible = true
	selected = 0
	player.ignoreInput = true
	for i in range(options.size()):
		list.add_item(options[i])
		if i in disabled:
			list.set_item_custom_bg_color(i, Color.BLACK)
	list.add_item("Back")
	disable = disabled
	
	if desc.size() > 0:
		descriptions = desc
		description.visible = true
		description.custom_minimum_size.x = DWidth
	else:
		description.visible = false
	
	position.x = 714 - OWidth - (DWidth / 2)
	
	list.custom_minimum_size.x = OWidth
	list.select(selected)
	list.item_selected.emit(selected)
		
func Close():
	visible = false
	player.ignoreInput = false
	list.clear()
	
func ItemActivated(id : int):
	if id not in disable:
		if id == list.item_count - 1:
			OptionSelected.emit(player, -1)
			Close()
		else:
			OptionSelected.emit(player, id)
			Close()
		
	
