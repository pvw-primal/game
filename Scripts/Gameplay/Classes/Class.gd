class_name Class
extends Resource

var name : String
var classBit : int
var moves : Array[Move]
var passives : Array[Passive]
var profBit : int
var craftBrew : Array[String]
var craftTinker : Array[String]

var classVariables : Dictionary = {}

func _init(Name : String, Attacks : Array[Move], classNum : int, profNum : int, Passives : Array[Passive] = [], CB : Array[String] = [], CT : Array[String] = []):
	name = Name
	classBit = classNum
	moves = Attacks
	profBit = profNum
	passives = Passives
	craftBrew = CB
	craftTinker = CT
	Classes.ClassDict[classBit] = self
	
func _to_string():
	return name

func HasProf(prof : Classes.Proficiency):
	return prof == Classes.Proficiency.None || profBit & Classes.GetProfNum(prof)
	
func HasBase(classE : Classes.BaseClass):
	return classE == Classes.BaseClass.None || classBit & Classes.GetClassNum(classE)
