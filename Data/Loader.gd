class_name Loader

const EnemyData = "res://Data/Enemies.json"
const ItemData = "res://Data/Items.json"
const LevelData = "res://Data/Levels.json"
const ClassData = "res://Data/Classes.json"
const EquipmentData = "res://Data/Equipment.json"

static var EnemyDataCache : Dictionary

static var accesses : int = 0

static func LoadFile(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	accesses += 1
	print(accesses)
	return file.get_as_text()

static func GetEnemyData(name : String):
	if name in EnemyDataCache:
		return EnemyDataCache[name]
			
	var json = JSON.new()
	if json.parse(LoadFile(EnemyData)) != OK:
		print(json.get_error_message())
		return
	var EnemyList = json.data
	return EnemyList[name]

static func GetEnemiesData(names : Array[String]):
	var data : Dictionary = {}
	var needed : Array[String] = []
	for name in names:
		if name in EnemyDataCache:
			data[name] = EnemyDataCache[name]
		else:
			needed.append(name)
			
	if needed.size() > 0:
		var json = JSON.new()
		if json.parse(LoadFile(EnemyData)) != OK:
			print(json.get_error_message())
			return
		var EnemyList = json.data
		for name in names:
			if name in EnemyList:
				data[name] = EnemyList[name]
	return data

static func CacheEnemies(names : Array[String]):
	var json = JSON.new()
	if json.parse(LoadFile(EnemyData)) != OK:
		print(json.get_error_message())
		return
	var EnemyList = json.data
	for name in names:
		if name in EnemyList:
			EnemyDataCache[name] = EnemyList[name]

static func GetItemsData(names : Array[String]):
	var json = JSON.new()
	if json.parse(LoadFile(ItemData)) != OK:
		print(json.get_error_message())
		return
	var itemList = json.data
	var data : Dictionary = {}
	for name in names:
		if name in itemList:
			data[name] = itemList[name]
	return data

static func GetAllItems():
	var json = JSON.new()
	if json.parse(LoadFile(ItemData)) != OK:
		print(json.get_error_message())
		return
	return json.data
	
static func GetLevelData(type : String):
	var json = JSON.new()
	if json.parse(LoadFile(LevelData)) != OK:
		print(json.get_error_message())
		return
	var LevelList = json.data
	return LevelList[type]
	
static func GetClassData():
	var json = JSON.new()
	if json.parse(LoadFile(ClassData)) != OK:
		print(json.get_error_message())
		return
	return json.data

static func GetEquipmentData():
	var json = JSON.new()
	if json.parse(LoadFile(EquipmentData)) != OK:
		print(json.get_error_message())
		return
	return json.data
