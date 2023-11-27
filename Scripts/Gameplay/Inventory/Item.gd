class_name Item
extends Resource

var move : Move
var moveTooltip : String
var name : String
var description : String
var flavor : String
var texture : Texture2D
var consumable : bool
var equipment : bool

var requiredProf : Classes.Proficiency = Classes.Proficiency.None
var crafting : Crafting
var prefixes : Dictionary

func _init(Name : String, Description : String, Flavor : String = "", t : Texture2D = null, Use : Move = null, UseTT : String = "", Consumable : bool = false):
	name = Name
	description = Description
	flavor = Flavor
	move = Use
	moveTooltip = UseTT
	consumable = Consumable
	texture = t
	crafting = Crafting.new()
	
func CanUse():
	return move != null && !equipment

func GetDescription(showc : bool = false, showpf : bool = false) -> String:
	var rs = description
	rs += "\n\n" + flavor
	if showpf:
		for mod in prefixes.keys():
			rs += mod + " "
		rs += "\n\n"
	if showc:
		for itemname in crafting.tags.keys():
			rs += itemname + " "
	return rs

func SetEquipment(m : Move, prof : Classes.Proficiency, pf : Dictionary = {}):
	equipment = true
	move = m
	requiredProf = prof
	move.name = name
	prefixes = pf
	
