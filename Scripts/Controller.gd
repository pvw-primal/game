class_name Controller
extends Node

var level : Level

var floorNum : int

var numEnemies : int
var statDistribution : int
var spawnChance : float

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
	%TurnHandler.AddEntity(player)
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
