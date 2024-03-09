class_name CharacterCreatorPreview
extends Node3D

@onready var layout : Node3D = get_node("Layout/LayoutRotate")
@onready var tabs : TabBar = get_node("TabBar")

const ROTATE_SPEED : float = .5
var previews : Array[Node3D]
var active : int = 0

func _ready():
	var a = preload("res://Assets/Enemy/Russ/RussShaded.tscn")
	var b = preload("res://Assets/Enemy/MortalPester/MortalPester.tscn")
	var c = preload("res://Assets/Enemy/Cinch/Cinch.tscn")
	previews.append(a.instantiate())
	previews.append(b.instantiate())
	previews.append(c.instantiate())
	for preview in previews:
		layout.add_child(preview)
		preview.visible = false
	previews[active].visible = true
	tabs.add_tab("Russ ")
	tabs.add_tab(" Pester ")
	tabs.add_tab(" Cinch")
	tabs.tab_changed.connect(Swap)
	InitColor()
	
func InitColor():
	for preview in previews:
		for child in preview.get_node("Armature/Skeleton3D").get_children():
			var m = child.mesh.surface_get_material(0)
			if !m.is_class("ShaderMaterial"):
				continue
			child.set_instance_shader_parameter("replaceR", Color.DARK_GRAY)
			child.set_instance_shader_parameter("replaceG", Color.GAINSBORO)
			child.set_instance_shader_parameter("replaceB", Color.GRAY)

func _process(delta):
	layout.rotate_y(delta * ROTATE_SPEED)
	
func Swap(id : int):
	if id == active:
		return
	previews[active].visible = false
	active = id
	previews[active].visible = true

func GetActivePreview():
	return previews[active]
