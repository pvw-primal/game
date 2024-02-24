class_name Controller
extends Node

var level : Level

var floorNum : int

var numEnemies : int
var statDistribution : int
var spawnChance : float

var goal = 1

func _ready():
	level = Global.level
	numEnemies = 7
	statDistribution = 2
	spawnChance = 0
	floorNum = 0
	%EntityHandler.player = Global.player
	
	%GridMap.init()
	%EntityHandler.init(numEnemies, statDistribution, true)
	%TurnHandler.init(spawnChance)
	
func _process(_delta):
	if Input.is_action_just_pressed("Test"):
		await NextLevel()
		
func NextLevel():
	floorNum += 1
	if floorNum > goal:
		await Start(level.name + " " + level.goalName)
		var player : Player = %EntityHandler.player
		if player.turn:
			player.endTurn.disconnect(%TurnHandler.HandleNextTurn)
		%TurnHandler.Reset()
		%EntityHandler.Reset()
		for child in %EntityHandler.get_children():
			%EntityHandler.remove_child(child)
		%GridMap.Reset()
		Global.inventory = player.inventoryUI.InventoryList()
		Global.lastSlot = player.inventoryUI.lastSlot
		await $TransitionScreen.Wait(.5)
		get_tree().change_scene_to_file("res://Scenes/tree.tscn")
		return
		
	IncreaseDifficulty()
	await Start(level.name + "\n" + level.floorPrefix + str(floorNum))
	
	var player : Player = %TurnHandler.Entities[%TurnHandler.player]
	player.text.text = "\n\n\n\n"
	%TurnHandler.Reset()
	%EntityHandler.Reset()
	%GridMap.Reset()
	
	%GridMap.init()
	if player.turn:
		player.endTurn.disconnect(%TurnHandler.HandleNextTurn)
	%EntityHandler.init(numEnemies, statDistribution, false)
	
	await $TransitionScreen.Wait(.5)
	await Stop()
	
	%TurnHandler.init(spawnChance)

func IncreaseDifficulty():
	var chance = randf_range(0, 1)
	if chance > .8:
		statDistribution += 1
	elif chance > .6:
		numEnemies += 1
	else:
		spawnChance += .02

func Start(text : String):
	$TransitionScreen.visible = true
	$TransitionScreen.transitiontext.visible = true
	$TransitionScreen.transitiontext.text = text
	$TransitionScreen.shouldVisible = true
	$TransitionScreen.fullyVisible = false
	await $TransitionScreen.ScreenVisible
	
func Stop():
	$TransitionScreen.shouldVisible = false
	$TransitionScreen.transitiontext.visible = false
	await $TransitionScreen.ScreenNotVisible
