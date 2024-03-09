class_name PlayerInput
extends Node

var mode : int = 0

var player : Player
var menuUI : MenuUI
var optionUI : OptionMenu

func init():
	player = get_parent()
	menuUI = get_node("/root/Root/MenuUI")
	optionUI = player.option
	menuUI.OnWindowOpen.connect(OpenMenu)
	menuUI.OnWindowClose.connect(SwitchInput)
	optionUI.OnWindowOpen.connect(OpenOptionUI)
	optionUI.OnWindowClose.connect(SwitchInput)
	
func _process(delta):
	if player.turn && !player.action:
		if Input.is_action_just_pressed("Inventory"):
			menuUI.UIInput(0)
			return
		elif Input.is_action_just_pressed("Map") && !menuUI.locked:
			menuUI.UIInput(1)
			return
		elif Input.is_action_just_pressed("Stats") && !menuUI.locked:
			menuUI.UIInput(2)
			return
		elif Input.is_action_just_pressed("Moves") && !menuUI.locked:
			menuUI.UIInput(3)
			return
	match(mode):
		0: ProcessPlayer(delta)
		1: ProcessMenu(delta)
		2: ProcessOption(delta)
	
func ProcessPlayer(delta : float):
	player.Process(delta)

func ProcessMenu(delta : float):
	menuUI.Process(delta)
	
func ProcessOption(delta : float):
	optionUI.Process(delta)

func SwitchInput(id : int = 0):
	player.ignoreInput = id != 0
	mode = id

func OpenMenu():
	SwitchInput(1)
	
func OpenOptionUI():
	SwitchInput(2)
