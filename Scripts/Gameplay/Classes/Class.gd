class_name Class
extends Resource

var name : String
var classBit : int
var moves : Array[Move]
var profBit : int
var canCraft : Array[String]

func _init(Name : String, Attacks : Array[Move], classNum : int, profNum : int, CC : Array[String] = []):
	name = Name
	classBit = classNum
	moves = Attacks
	profBit = profNum
	canCraft = CC
	Classes.ClassDict[classBit] = self
	
func _to_string():
	return name

func HasProf(prof : Classes.Proficiency):
	return prof == Classes.Proficiency.None || profBit & Classes.GetProfNum(prof)
	
func HasBase(classE : Classes.BaseClass):
	return classE == Classes.BaseClass.None || classBit & Classes.GetClassNum(classE)
