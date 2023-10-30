class_name ItemWorld
extends Sprite3D

@onready var bundlesprite = load("res://Assets/Items/Bundle.png")

var items : Array[Item]

func init(i : Array[Item], pos : Vector3):
	items = i
	position = pos
	texture = items[0].texture if items.size() < 2 && items[0].texture != null else bundlesprite
	
func AddItem(i : Item):
	items.append(i)
	texture = bundlesprite
