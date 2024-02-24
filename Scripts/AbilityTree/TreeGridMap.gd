class_name TreeGridMap
extends GridMap

var ROOM_WIDTH : int = 8
const ROOM_HEIGHT : int = 8
const ROOM_BORDER : int = 17
const angles = [0, PI / 2, PI, 3 * PI / 2]

var limitsX : Vector2
var limitsY : Vector2

func _ready():
	ROOM_WIDTH = 8 + ((Global.options - 3) * 2)
	var color : Color = Global.level.color if Global.level != null else Color.SEA_GREEN
	mesh_library.get_item_mesh(0).surface_get_material(0).albedo_color = color
	for i in range(1, mesh_library.get_item_list().size()):
		mesh_library.get_item_mesh(i).surface_get_material(0).albedo_color = color.darkened(.02 * float(i - 1))
			
	var s : MeshInstance3D = preload("res://Assets/Environment/TreeWall.tscn").instantiate()
	var num = mesh_library.get_last_unused_item_id()
	mesh_library.create_item(num)
	mesh_library.set_item_mesh(num, s.mesh)
	mesh_library.set_item_mesh_transform(num, s.transform)
	mesh_library.get_item_mesh(num).surface_get_material(0).albedo_color = color.darkened(.03 * randi_range(0, 1))
	s.queue_free()
	
	s = preload("res://Assets/Environment/StumpWall.tscn").instantiate()
	num = mesh_library.get_last_unused_item_id()
	mesh_library.create_item(num)
	mesh_library.set_item_mesh(num, s.mesh)
	mesh_library.set_item_mesh_transform(num, s.transform)
	s.queue_free()
	
	s = preload("res://Assets/Environment/RockWall.tscn").instantiate()
	num = mesh_library.get_last_unused_item_id()
	mesh_library.create_item(num)
	mesh_library.set_item_mesh(num, s.mesh)
	mesh_library.set_item_mesh_transform(num, s.transform)
	s.queue_free()
	@warning_ignore("integer_division")
	var room : Rect2i = Rect2i(-ROOM_WIDTH / 2, -1, ROOM_WIDTH, ROOM_HEIGHT)
	BuildRoom(room)
	AddRoomDecor(room)
	limitsX = Vector2(room.position.x, room.position.x + room.size.x)
	limitsX *= cell_size.x
	limitsY = Vector2(room.position.y, room.position.y + room.size.y)
	limitsY *= cell_size.z
	
func BuildRoom(room: Rect2i):
	for x in range(room.position.x - ROOM_BORDER, room.position.x + room.size.x + ROOM_BORDER):
		for y in range(room.position.y - ROOM_BORDER, room.position.y + room.size.y + ROOM_BORDER):
			if room.has_point(Vector2i(x, y)):
				set_cell_item(Vector3i(x, 0, y), 0, get_orthogonal_index_from_basis(Basis(Vector3.UP, angles[randi_range(0, angles.size() - 1)])))
			else:
				set_cell_item(Vector3i(x, 0, y), randi_range(1, 3), get_orthogonal_index_from_basis(Basis(Vector3.UP, angles[randi_range(0, angles.size() - 1)])))
			
func AddRoomDecor(r : Rect2i):
	for _j in range(20):
		var m : int = randi_range(mesh_library.get_item_list().size() - 2, mesh_library.get_item_list().size() - 1) if randf() < .3 else mesh_library.get_item_list().size() - 3
		var s : Vector3i
		match randi_range(0, 2):
			0: s = Vector3i(randi_range(r.position.x - 3, r.position.x), 1, randi_range(r.position.y, r.end.y))
			1: s = Vector3i(randi_range(r.position.x, r.end.x), 1, randi_range(r.end.y - 3, r.end.y))
			2: s = Vector3i(randi_range(r.end.x - 3, r.end.x), 1, randi_range(r.position.y, r.end.y))
		var p : Vector3i = Vector3i(s.x, 0, s.z)
		if get_cell_item(p) != 0 && get_cell_item(p) < 4:
			set_cell_item(p, 3, get_orthogonal_index_from_basis(Basis(Vector3.UP, angles[randi_range(0, angles.size() - 1)])))
			set_cell_item(s, m, get_orthogonal_index_from_basis(Basis(Vector3.UP, angles[randi_range(0, angles.size() - 1)])))
