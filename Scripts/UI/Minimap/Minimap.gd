class_name Minimap
extends TileMap

const TILE_SIZE : float = 16
const REVEAL_DIST : int = 5
var startPos : Vector2 = Vector2(160, 160)

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")

func _ready():
	pass

func OnMove(pos : Vector2i, dir : Vector2i):
	for x in range(pos.x - REVEAL_DIST, REVEAL_DIST + pos.x):
		for y in range(pos.y - REVEAL_DIST, REVEAL_DIST + pos.y):
			Reveal(Vector2i(x, y))
	position += Vector2(dir) * TILE_SIZE
	
func Reveal(pos : Vector2i):
	var id = gridmap.GetMapPos(pos)
	if id > -2:
		if id == 0:
			set_cell(0, pos, 0, Vector2i(1, 0))
		elif id > 0:
			if gridmap.turnhandler.Entities[id].Type == "Ally":
				set_cell(0, pos, 0, Vector2i(4, 0))
			elif gridmap.turnhandler.Entities[id].Type == "Structure":
				set_cell(0, pos, 0, Vector2i(5, 0))
			else:
				set_cell(0, pos, 0, Vector2i(2, 0))
		elif pos in gridmap.items.keys():
			set_cell(0, pos, 0, Vector2i(3, 0))
		elif pos in gridmap.exits.keys():
			set_cell(0, pos, 0, Vector2i(0, 0))
		else:
			set_cell(0, pos, 0, Vector2i(0, 1))

func SetPosition(pos : Vector2i):
	position = startPos + (Vector2(pos) * TILE_SIZE)
