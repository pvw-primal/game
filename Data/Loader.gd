class_name Loader

const EnemyData = "res://Data/Enemies.json"

static func GetEnemyData(name : String):
	var json = JSON.new()
	if json.parse(LoadFile(EnemyData)) != OK:
		print(json.get_error_message())
		return
	var EnemyList = json.data
	return EnemyList[name]
	
static func LoadFile(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text()
