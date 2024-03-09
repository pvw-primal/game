class_name Level
extends Resource

#number of colors cannot exceed 16 (minus max number of allies)
const NUM_COLOR_VARIATIONS = 4

var name : String
var floorPrefix : String
var goalName : String
var enemies : Dictionary

var difficulty : int
var difficultyName : String
var numEnemies : int
var statDistribution : int
var spawnChance : float
var goal : int

var commonItems : Array
var rareItems : Array
var materials : Array

var color : Color

func _init(type : String, difficult : int = 0, variant : String = ""):
	var levelDetails : Dictionary = Loader.GetLevelData(type)
	var variants = levelDetails["variant"]
	var v : String = variants.keys()[randi_range(0, variants.size() - 1)] if variant == "" else variant
	var p = levelDetails["variant"][v]["prefix"]
	var s = levelDetails["suffix"]
	name = p[randi_range(0, p.size() - 1)] + " " + s[randi_range(0, s.size() - 1)]
	if "floorPrefix" in levelDetails:
		floorPrefix = levelDetails["floorPrefix"]
	if "goalName" in levelDetails:
		goalName = levelDetails["goalName"]
	var enemyDrops : Array[String] = []
	if "spawns" in levelDetails:
		var cacheList : Array[String] = []
		for enemyName in levelDetails["spawns"]:
			cacheList.append(enemyName)
			enemies[enemyName] = []
			for i in range(NUM_COLOR_VARIATIONS):
				enemies[enemyName].append(EnemyColor(levelDetails["spawns"][enemyName]["color"]))
		Loader.CacheEnemies(cacheList)
		for enemyName in levelDetails["spawns"]:
			var enemyDetails = Loader.GetEnemyData(enemyName)
			if "drops" in enemyDetails:
				for drop in enemyDetails["drops"]:
					enemyDrops.append(drop)
	if "items" in levelDetails:
		commonItems = levelDetails["items"]["common"] as Array[String]
		rareItems = levelDetails["items"]["rare"] as Array[String]
		materials = levelDetails["items"]["materials"] as Array[String]
		for drop in enemyDrops:
			if drop not in materials:
				materials.append(drop)
		
	var colorR = levelDetails["variant"][v]["color"]["R"]
	var colorG = levelDetails["variant"][v]["color"]["G"]
	var colorB = levelDetails["variant"][v]["color"]["B"]
	color = Color(randf_range(colorR[0], colorR[1]), randf_range(colorG[0], colorG[1]), randf_range(colorB[0], colorB[1]))
	
	SetDifficulty(difficult)

func SetDifficulty(difficult : int):
	difficulty = difficult
	statDistribution = difficult + Global.stage
	numEnemies = 6 + floor(difficult / 2.0)
	spawnChance = .004 * (floor(difficult / 2.0) - 1)
	goal = randi_range(2 + floor(difficult / 2.0), 2 + (difficult * 2))

static func GetDifficultyName(difficult : int):
	match(difficult):
		0: return "Trivial"
		1: return "Simple"
		2: return "Normal"
		3: return "Tough"
		4: return "Hard"
		5: return "Insane"
		6: return "Maddening"
		7: return "Lunacy"
		8: return "Abyssal"
		_: return "Impossible"
	
func IncreaseDifficulty():
	var chance = randf_range(0, 1)
	if chance > .7:
		statDistribution += 1
	elif chance > .5:
		numEnemies += 1
	else:
		spawnChance += .004

func GetRandomEnemyColor(enemyName : String):
	return enemies[enemyName][randi_range(0, NUM_COLOR_VARIATIONS - 1)]

func RandomItem():
	#equipment : 10%
	#common : 30%
	#material : 50%
	#rare : 10%
	var chance = randf_range(0, 1)
	if chance > .9:
		return Items.RandomEquipment(true)
	elif chance > .6:
		return Items.items[commonItems[randi_range(0, commonItems.size() - 1)]]
	elif chance > .1:
		return Items.items[materials[randi_range(0, materials.size() - 1)]]
	else:
		return Items.items[rareItems[randi_range(0, rareItems.size() - 1)]]

func EnemyColor(colorDetails : Dictionary) -> Array[Color]:
	var colors : Array[Color] = []
	if "dependants" in colorDetails && randf_range(0, 1) < colorDetails["dependants"]["chance"]:
		colors.append(Color(randf_range(colorDetails["RLower"][0], colorDetails["RUpper"][0]),
		randf_range(colorDetails["RLower"][1], colorDetails["RUpper"][1]),
		randf_range(colorDetails["RLower"][2], colorDetails["RUpper"][2])))
		
		if colorDetails["dependants"]["channels"][0] == "R":
			if colorDetails["dependants"]["channels"][1] == "G":
				colors.append(DependantColor(colors[0], colorDetails["dependants"]))
				colors.append(Color(randf_range(colorDetails["BLower"][0], colorDetails["BUpper"][0]),
				randf_range(colorDetails["BLower"][1], colorDetails["BUpper"][1]),
				randf_range(colorDetails["BLower"][2], colorDetails["BUpper"][2])))
			elif colorDetails["dependants"]["channels"][1] == "B":
				colors.append(Color(randf_range(colorDetails["GLower"][0], colorDetails["GUpper"][0]),
				randf_range(colorDetails["GLower"][1], colorDetails["GUpper"][1]),
				randf_range(colorDetails["GLower"][2], colorDetails["GUpper"][2])))
				colors.append(DependantColor(colors[0], colorDetails["dependants"]))
		elif colorDetails["dependants"]["channels"][0] == "G":
			colors.append(Color(randf_range(colorDetails["GLower"][0], colorDetails["GUpper"][0]),
			randf_range(colorDetails["GLower"][1], colorDetails["GUpper"][1]),
			randf_range(colorDetails["GLower"][2], colorDetails["GUpper"][2])))
			colors.append(DependantColor(colors[1], colorDetails["dependants"]))
	else:
		colors.append(Color(randf_range(colorDetails["RLower"][0], colorDetails["RUpper"][0]),
		randf_range(colorDetails["RLower"][1], colorDetails["RUpper"][1]),
		randf_range(colorDetails["RLower"][2], colorDetails["RUpper"][2])))
		
		colors.append(Color(randf_range(colorDetails["GLower"][0], colorDetails["GUpper"][0]),
		randf_range(colorDetails["GLower"][1], colorDetails["GUpper"][1]),
		randf_range(colorDetails["GLower"][2], colorDetails["GUpper"][2])))
		
		colors.append(Color(randf_range(colorDetails["BLower"][0], colorDetails["BUpper"][0]),
		randf_range(colorDetails["BLower"][1], colorDetails["BUpper"][1]),
		randf_range(colorDetails["BLower"][2], colorDetails["BUpper"][2])))
	
	return colors
	
func DependantColor(original : Color, dependantDetails) -> Color:
	if "darken" in dependantDetails:
		return original.darkened(randf_range(dependantDetails["darken"][0], dependantDetails["darken"][1]))
	elif "lighten" in dependantDetails:
		return original.lightened(randf_range(dependantDetails["lighten"][0], dependantDetails["lighten"][1]))
	else:
		return original
