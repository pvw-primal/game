class_name Item
extends Resource

var move : Move
var moveTooltip : String

var name : String
var description : String
var flavor : String

var mesh : PackedScene
var topdown : bool
var invHeight : float

var crafting : Crafting
var rarity : Items.Rarity

var equipment : bool

var consumable : bool
var maxUses : int

func _init(Name : String, Description : String, Flavor : String = "", t : PackedScene = null, Use : Move = null, UseTT : String = "", Consumable : bool = false):
	name = Name
	description = Description
	flavor = Flavor
	move = Use
	moveTooltip = UseTT
	consumable = Consumable
	mesh = t
	crafting = Crafting.new()
	rarity = Items.Rarity.Common
	topdown = false
	equipment = false
	invHeight = .1
	
func CanUse():
	return move != null && !equipment

func GetLogName():
	return"[color=#" + Items.RarityColor(rarity).to_html() + "]" + name + "[/color]"

func GetDescription(uses : int = -1) -> String:
	var rs = "[indent][color=#" + Items.RarityColor(rarity).to_html() + "][b]"
	@warning_ignore("integer_division")
	rs += "[font_size=" + str((1100 / name.length())) + "]" + name + ":[/font_size]" if name.length() >= 20 else name + ":"
	rs += "[/b]\n"
	if consumable:
		rs += "[font_size=28]consumable"
		if uses > 1:
			rs += ", uses: "
			for i in range(uses):
				rs += "o"
		rs += "[/font_size]"
	if crafting.tags.keys().size() > 0:
		var num = 0
		rs += "[font_size=28]"
		for itemname in crafting.tags.keys():
			rs += itemname
			if num < crafting.tags.keys().size() - 1:
				rs += ", "
			num += 1
		rs += " material[/font_size]"
		
	rs += "[/color]\n\n" + description
	if flavor != "":
		rs += "\n\n[i][font_size=24]" + flavor + "[/font_size][/i]"
	rs += "\n [/indent]"
	return rs
