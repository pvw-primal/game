class_name Crafting
extends Object

var tags : Dictionary 
var requires : int
var recipe : Array[String]

func _init():
	tags = {}
	requires = Classes.GetClassNum(Classes.BaseClass.None)
	recipe = []

func CanCraft(e : Entity):
	if recipe.size() <= 0:
		return []
	var locations : Array[int] = []
	locations.resize(recipe.size())
	locations.fill(-1)
	
	for t in range(recipe.size()):
		for i in range(e.inventoryUI.lastSlot + 1):
			var item = e.GetItem(i)
			if i in locations || item == null:
				continue
			if recipe[t] in item.crafting.tags:
				locations[t] = i
				break
				
	if -1 in locations:
		return []
	else:
		return locations
		
