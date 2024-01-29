class_name AbilityTreeDisplay
extends Node3D

const OFFSET : float = 2.5

@onready var treeRoot : Node3D = get_node("tree")
@onready var treePlayer : AbilityTreePlayer = get_node("Player")
@onready var collider : Area3D = get_node("Player/Area3D")
@onready var text : RichTextLabel = get_node("/root/root/Description")

@onready var PlayerScene = preload("res://Scripts/Entities/Player/Player.tscn")

var tree : AbilityTree
var currentNode : AbilityTreeNode

func _ready():
	tree = AbilityTree.new(5)
	DisplayTree(tree.tree, Vector3.ZERO)
	collider.area_entered.connect(OnCollision)
	collider.area_exited.connect(OnExit)
	text.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("Test"):
		for node in treeRoot.get_children():
			node.queue_free()
		tree._init(5)
		DisplayTree(tree.tree, Vector3.ZERO)
	elif Input.is_action_just_pressed("UISelect"):
		if currentNode != null:
			PrepareLevel()
			get_tree().change_scene_to_file("res://Scenes/root.tscn")
		
func PrepareLevel():
	var player : Player = PlayerScene.instantiate()
	player.SetMeshCopy(treePlayer.mesh)
	Global.player = player
	Global.level = Level.new("Forest")

func DisplayTree(t : Array, startingPos : Vector3):
	for row in range(t.size()):
		var pos : Vector3
		if t[row].size() % 2 == 0:
			var x = floorf(t[row].size() / 2) - 1
			pos = Vector3(x * -OFFSET, 0, row * OFFSET) + startingPos
			pos.x -= OFFSET / 2
		else:
			var x = floorf(t[row].size() / 2)
			pos = Vector3(x * -OFFSET, 0, row * OFFSET) + startingPos
		for column in range(t[row].size()):
			t[row][column].position = pos
			DisplayNode(t[row][column])
			pos.x += OFFSET
	
func DisplayNode(node : AbilityTreeNode):
	for connection in node.from:
		treeRoot.add_child(line(node.position, connection.position))
	treeRoot.add_child(node)
	

func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return mesh_instance

func OnExit(_a : Area3D):
	currentNode = null
	RemoveNodeText()

func OnCollision(a : Area3D):
	currentNode = a.get_parent()
	DisplayNodeText(currentNode)

func DisplayNodeText(node : AbilityTreeNode):
	text.visible = true
	text.text = "[indent][b]" + node.Name + "[/b]\n" + node.desc + "[/indent]"
	
func RemoveNodeText():
	text.visible = false
	



