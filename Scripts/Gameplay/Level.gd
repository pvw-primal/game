class_name Level
extends Resource

#number of colors cannot exceed 16 (minus number of allies)
const NUM_COLOR_VARIATIONS = 4

var name : String
var floorPrefix : String
var enemies : Dictionary

func _init(type : String):
	var levelDetails : Dictionary = Loader.GetLevelData(type)
	if "name" in levelDetails:
		var p = levelDetails["name"]["prefix"]
		var s = levelDetails["name"]["suffix"]
		name = p[randi_range(0, p.size() - 1)] + " " + s[randi_range(0, p.size() - 1)]
	if "floorPrefix" in levelDetails:
		floorPrefix = levelDetails["floorPrefix"]
	if "spawns" in levelDetails:
		for enemyName in levelDetails["spawns"]:
			enemies[enemyName] = []
			for i in range(NUM_COLOR_VARIATIONS):
				enemies[enemyName].append(EnemyColor(levelDetails["spawns"][enemyName]["color"]))
				
func GetRandomEnemyColor(enemyName : String):
	return enemies[enemyName][randi_range(0, NUM_COLOR_VARIATIONS - 1)]

func EnemyColor(colorDetails : Dictionary) -> Array[Color]:
	var colors : Array[Color] = []
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
