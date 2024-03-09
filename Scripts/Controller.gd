class_name Controller
extends Node

var level : Level

var floorNum : int

func _ready():
	level = Global.level
	floorNum = 1
	%EntityHandler.player = Global.player
	
	%GridMap.init()
	%EntityHandler.init(level.numEnemies, level.statDistribution, true)
	%TurnHandler.init(level.spawnChance)
	
	%EntityHandler.player.OnLevelStart.emit(%EntityHandler.player)
	%EntityHandler.player.OnFloorStart.emit(%EntityHandler.player)
	
func _process(_delta):
	if Input.is_action_just_pressed("Test"):
		await NextLevel()
		
func NextLevel():
	floorNum += 1
	if floorNum >= level.goal:
		await Start(level.name + " " + level.goalName)
		var player : Player = %EntityHandler.player
		if player.turn:
			player.endTurn.disconnect(%TurnHandler.HandleNextTurn)
		player.OnLevelEnd.emit(player)
		%TurnHandler.Reset()
		%EntityHandler.Reset()
		for child in %EntityHandler.get_children():
			%EntityHandler.remove_child(child)
		%GridMap.Reset()
		Global.inventory = player.inventoryUI.InventoryList()
		Global.lastSlot = player.inventoryUI.lastSlot
		Global.playerMesh = player.mesh
		Global.player.remove_child(player.mesh)
		await $TransitionScreen.Wait(.5)
		get_tree().change_scene_to_file("res://Scenes/tree.tscn")
		return
		
	level.IncreaseDifficulty()
	await Start(level.name + "\n" + level.floorPrefix + str(floorNum))
	
	var player : Player = %TurnHandler.Entities[%TurnHandler.player]
	player.text.text = "\n\n\n\n"
	%TurnHandler.Reset()
	%EntityHandler.Reset()
	%GridMap.Reset()
	
	%GridMap.init()
	if player.turn:
		player.endTurn.disconnect(%TurnHandler.HandleNextTurn)
	%EntityHandler.init(level.numEnemies, level.statDistribution, false)
	
	await $TransitionScreen.Wait(.5)
	await Stop()
	
	%TurnHandler.init(level.spawnChance)
	player.OnFloorStart.emit(player)

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
