class_name Item
extends Resource

var move : Move
var moveTooltip : String
var name : String
var description : String
var flavor : String
var mesh : PackedScene
var consumable : bool
var equipment : bool

var requiredProf : Classes.Proficiency = Classes.Proficiency.None
var crafting : Crafting
var prefixes : Dictionary

func _init(Name : String, Description : String, Flavor : String = "", t : PackedScene = null, Use : Move = null, UseTT : String = "", Consumable : bool = false):
	name = Name
	description = Description
	flavor = Flavor
	move = Use
	moveTooltip = UseTT
	consumable = Consumable
	mesh = t
	crafting = Crafting.new()
	
func CanUse():
	return move != null && !equipment

func GetDescription(showc : bool = false, showpf : bool = false) -> String:
	var rs = description
	rs += "\n\n" + flavor
	if showpf:
		var num = 0
		for mod in prefixes.keys():
			rs += mod
			if num < prefixes.keys().size() - 1:
				rs += ", "
		rs += "\n\n"
	if showc:
		var num = 0
		if crafting.tags.keys().size() > 0:
			rs += "Material Tags: "
			for itemname in crafting.tags.keys():
				rs += itemname
				if num < crafting.tags.keys().size() - 1:
					rs += ", "
				num += 1
	return rs

func SetEquipment(m : Move, prof : Classes.Proficiency, pf : Dictionary = {}):
	equipment = true
	move = m
	requiredProf = prof
	move.name = name
	prefixes = pf
	
