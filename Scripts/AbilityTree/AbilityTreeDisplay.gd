class_name AbilityTreeDisplay
extends Node3D

const OFFSET_X : float = 2.5
const OFFSET_Y : float = 1.5

@onready var treeRoot : Node3D = get_node("tree")
@onready var treePlayer : AbilityTreePlayer = get_node("Player")
@onready var collider : Area3D = get_node("Player/Area3D")
@onready var textTop : RichTextLabel = get_node("/root/root/DescriptionTop")
@onready var textBottom : RichTextLabel = get_node("DescriptionBottom")

@onready var PlayerScene = preload("res://Scripts/Entities/Player/Player.tscn")

var tree : AbilityTree
var currentNode : AbilityTreeNode

func _ready():
	treePlayer.init()
	tree = AbilityTree.StarterTree() if Global.player == null else AbilityTree.GetNextTree(Global.stage)
	DisplayTree(tree.tree, Vector3(0, 0, 1.5))
	collider.area_entered.connect(OnCollision)
	collider.area_exited.connect(OnExit)
	textTop.visible = false
	textBottom.visible = false
	textTop.resized.connect(ChangeNodeText)

func _process(_delta):
	if Input.is_action_just_pressed("UISelect"):
		if currentNode != null && currentNode.data != null:
			PrepareLevel()
			get_tree().change_scene_to_file("res://Scenes/root.tscn")
		
func PrepareLevel():
	if Global.player == null:
		var player : Player = PlayerScene.instantiate()
		Global.player = player
		Global.player.Name = Global.playerName
	treePlayer.remove_child(treePlayer.mesh)
	Global.player.SetMeshCopy(treePlayer.mesh)
	if !currentNode.data.OnLevelStart.is_null():
		currentNode.data.OnLevelStart.call(Global.player, treePlayer)
	Global.player.animator.Walk(false)
	Global.level = Level.new("Forest", currentNode.data.difficulty)
	Global.stage += 1

func DisplayTree(t : Array, startingPos : Vector3):
	for row in range(t.size()):
		var pos : Vector3
		if t[row].size() % 2 == 0:
			var x = floorf(t[row].size() / 2) - 1
			pos = Vector3(x * -OFFSET_X, 0, row * OFFSET_Y) + startingPos
			pos.x -= OFFSET_X / 2
		else:
			var x = floorf(t[row].size() / 2)
			pos = Vector3(x * -OFFSET_X, 0, row * OFFSET_Y) + startingPos
		for column in range(t[row].size()):
			t[row][column].position = pos
			DisplayNode(t[row][column])
			pos.x += OFFSET_X
	
func DisplayNode(node : AbilityTreeNode):
	#for connection in node.from:
		#treeRoot.add_child(line(node.position, connection.position))
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
	if currentNode.data != null:
		DisplayNodeText(currentNode)

func DisplayNodeText(node : AbilityTreeNode):
	textTop.visible = true
	textTop.text = "[b]" + node.data.name + "[/b]\n" + node.data.desc + ""
	if node.data.showDifficulty:
		textBottom.visible = true
		textBottom.text = "\nDifficulty: " + node.data.difficultyName + " (" + str(node.data.difficulty) + ")"

func ChangeNodeText():
	textBottom.position.y = textTop.size.y + 31

func RemoveNodeText():
	textTop.visible = false
	textBottom.visible = false
	



