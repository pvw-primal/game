class_name Controller
extends Node

@onready var mapgenerator : MapGenerator = get_node("/root/Root/GridMap")
@onready var entityhandler : EntityHandler = get_node("/root/Root/EntityHandler")
@onready var turnhandler : TurnHandler = get_node("/root/Root/TurnHandler")
@onready var transitionscreen : TransitionScreen = get_node("TransitionScreen")

var level : Level

var floorNum : int = 0

var numEnemies : int = 7
var statDistribution : int = 2
var spawnChance : float = 0

func _ready():
	level = entityhandler.level
	
func _process(_delta):
	if Input.is_action_just_pressed("Test"):
		await NextLevel()
		
func NextLevel():
	floorNum += 1
	IncreaseDifficulty()
	await Start(level.name + "\n" + level.floorPrefix + str(floorNum))
	
	var player : Player = turnhandler.Entities[turnhandler.player]
	player.text.text = "\n\n\n\n"
	turnhandler.Reset()
	entityhandler.Reset()
	mapgenerator.Reset()
	
	mapgenerator._ready()
	if player.turn:
		player.endTurn.disconnect(turnhandler.HandleNextTurn)
	turnhandler.AddEntity(player)
	entityhandler._ready(player, numEnemies, statDistribution)
	
	await transitionscreen.Wait(.5)
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
