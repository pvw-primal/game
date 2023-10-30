class_name Controller
extends Node

@onready var mapgenerator : MapGenerator = get_node("/root/Root/GridMap")
@onready var entityhandler : EntityHandler = get_node("/root/Root/EntityHandler")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var transitionscreen : TransitionScreen = get_node("TransitionScreen")

var level : int = 0

var numEnemies : int = 7
var statDistribution : int = 2
var spawnChance : float = 0

#func _process(_delta):
#	if Input.is_action_just_pressed("Test"):
#		await NextLevel()
		
func NextLevel():
	level += 1
	IncreaseDifficulty()
	await Start("GREEN ASS FUCKING FOREST\nBF" + str(level))
	var player : Player = turnhandler.Entities[turnhandler.player]
	player.text.label.text = "\n\n\n\n"
	turnhandler.Reset()
	entityhandler.Reset()
	mapgenerator.Reset()
	
	mapgenerator._ready()
	player.endTurn.disconnect(turnhandler.HandleNextTurn)
	turnhandler.AddEntity(player)
	entityhandler._ready(player, numEnemies, statDistribution)
	
	await Stop()
	turnhandler._ready(spawnChance)

func IncreaseDifficulty():
	var chance = randf_range(0, 1)
	if chance > .8:
		statDistribution += 1
	elif chance > .6:
		numEnemies += 1
	else:
		spawnChance += .02

func Start(text : String):
	transitionscreen.visible = true
	transitionscreen.transitiontext.visible = true
	transitionscreen.transitiontext.text = text
	transitionscreen.shouldVisible = true
	transitionscreen.fullyVisible = false
	await transitionscreen.ScreenVisible
	
func Stop():
	transitionscreen.shouldVisible = false
	transitionscreen.transitiontext.visible = false
	await transitionscreen.ScreenNotVisible
