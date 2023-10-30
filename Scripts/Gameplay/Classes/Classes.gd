class_name Classes
extends Resource

enum BaseClass { Shamanism = 0, Arcana = 1, Arms = 2, Technique = 3, Beastmastery = 4, Alchemy = 5, Machining = 6, None = -1 }
enum Proficiency { WeaponBasic = 0, WeaponMartial = 1, FocusBasic = 2, FocusAdvanced = 3, Tool = 4, None = -1 }

static var ClassDict : Dictionary = {}

static func AddClass(c : Class, s1 : BaseClass, s2 : BaseClass = BaseClass.None, s3 : BaseClass = BaseClass.None):
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
