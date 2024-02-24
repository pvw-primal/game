class_name Classes
extends Resource

enum BaseClass { Shamanism = 0, Arcana = 1, Arms = 2, Technique = 3, Beastmastery = 4, Alchemy = 5, Machining = 6, None = -1 }
enum Proficiency { WeaponBasic = 0, WeaponMartial = 1, FocusBasic = 2, FocusAdvanced = 3, Tool = 4, None = -1 }

static var ClassDict : Dictionary = {}

static func AddClass(c : Class):
	ClassDict[c.classBit] = c

static func AddClassBase(c : Class, s1 : BaseClass, s2 : BaseClass = BaseClass.None, s3 : BaseClass = BaseClass.None):
	ClassDict[GetClassNum(s1, s2, s3)] = c
	
static func GetClass(s1 : BaseClass, s2 : BaseClass = BaseClass.None, s3 : BaseClass = BaseClass.None):
	return ClassDict[GetClassNum(s1, s2, s3)]
	
static func GetClassNum(s1 : BaseClass, s2 : BaseClass = BaseClass.None, s3 : BaseClass = BaseClass.None):
	var bit = 0
	if s1 != BaseClass.None:
		bit += 1 << s1
	if s2 != BaseClass.None:
		bit += 1 << s2
	if s3 != BaseClass.None:
		bit += 1 << s3
	return bit

static func GetProfNum(s1 : Proficiency, s2 : Proficiency = Proficiency.None, s3 : Proficiency = Proficiency.None, s4 : Proficiency = Proficiency.None, s5 : Proficiency = Proficiency.None):
	var bit = 0
	if s1 != Proficiency.None:
		bit += 1 << s1
	if s2 != Proficiency.None:
		bit += 1 << s2
	if s3 != Proficiency.None:
		bit += 1 << s3
	if s4 != Proficiency.None:
		bit += 1 << s4
	if s5 != Proficiency.None:
		bit += 1 << s5
	return bit

static func GetBaseClass(name : String) -> BaseClass:
	if name == "Shamanism":
		return BaseClass.Shamanism
	if name == "Arcana":
		return BaseClass.Arcana
	if name == "Arms":
		return BaseClass.Arms
	if name == "Technique":
		return BaseClass.Technique
	if name == "Beastmastery":
		return BaseClass.Beastmastery
	if name == "Alchemy":
		return BaseClass.Alchemy
	if name == "Machining":
		return BaseClass.Machining
	else:
		return BaseClass.None

static func GetProficiency(name : String) -> Proficiency:
	if name == "WeaponBasic":
		return Proficiency.WeaponBasic
	if name == "FocusBasic":
		return Proficiency.FocusBasic
	if name == "WeaponMartial":
		return Proficiency.WeaponMartial
	if name == "FocusAdvanced":
		return Proficiency.FocusAdvanced
	if name == "Tool":
		return Proficiency.Tool
	else:
		return Proficiency.None

static func AddClassFromData(classData):
	var moves : Array[Move] = []
	for move in classData["moves"]:
		moves.append(Move.moves[move])
		
	var classes = []
	for base in classData["class"]:
		classes.append(GetBaseClass(base))
	for i in range(3 - classes.size()):
		classes.append(BaseClass.None)
	
	var desc  = classData["description"]
	
	var profs = []
	for prof in classData["prof"]:
		profs.append(GetProficiency(prof))
	for i in range(5 - profs.size()):
		profs.append(Proficiency.None)
	
	var passives : Array[Passive] = []
	if "passives" in classData:
		for passive in classData["passives"]:
			passives.append(Passive.passives[passive])
	
	var craftBrew : Array[String] = []
	if "craftBrew" in classData:
		for item in classData["craftBrew"]:
			craftBrew.append(item)
	
	var craftTinker : Array[String] = []
	if "craftTinker" in classData:
		for item in classData["craftTinker"]:
			craftTinker.append(item)
		
	AddClass(Class.new(classData["name"], desc, moves, GetClassNum(classes[0], classes[1], classes[2]), GetProfNum(profs[0], profs[1], profs[2], profs[3], profs[4]), passives, craftBrew, craftTinker))
	
static func LoadAllClasses():
	var data = Loader.GetClassData()
	for className in data:
		AddClassFromData(data[className])
		
static func LoadSelectClasses(classes : Array[String]):
	var data = Loader.GetClassData()
	for className in classes:
		AddClassFromData(data[className])
