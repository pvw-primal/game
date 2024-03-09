class_name CharacterCreator
extends Node3D

@onready var preview : CharacterCreatorPreview = get_node("Preview")
@onready var colorPicker : Array[BasicColorPicker] = [get_node("ColorPicker/ColorPickerButtonR"), get_node("ColorPicker/ColorPickerButtonG"), get_node("ColorPicker/ColorPickerButtonB")]
@onready var nameField : LineEdit = get_node("NameField/LineEdit")
@onready var proceed : Button = get_node("Proceed")

var savedColors = []

func _ready():
	for _i in range(3):
		savedColors.append([Color.DARK_GRAY, Color.GAINSBORO, Color.GRAY])
	colorPicker[0].color_changed.connect(SetColorR)
	colorPicker[0].color = savedColors[0][0]
	colorPicker[1].color_changed.connect(SetColorG)
	colorPicker[1].color = savedColors[0][1]
	colorPicker[2].color_changed.connect(SetColorB)
	colorPicker[2].color = savedColors[0][2]
	preview.tabs.tab_changed.connect(LoadColors)
	proceed.button_up.connect(Proceed)

func SetColorR(color : Color):
	savedColors[preview.active][0] = color
	for child in preview.GetActivePreview().get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		child.set_instance_shader_parameter("replaceR", color)
		
func SetColorG(color : Color):
	savedColors[preview.active][1] = color
	for child in preview.GetActivePreview().get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		child.set_instance_shader_parameter("replaceG", color)
		
func SetColorB(color : Color):
	savedColors[preview.active][2] = color
	for child in preview.GetActivePreview().get_node("Armature/Skeleton3D").get_children():
		var m = child.mesh.surface_get_material(0)
		if !m.is_class("ShaderMaterial"):
			continue
		child.set_instance_shader_parameter("replaceB", color)

func LoadColors(id : int):
	for i in range(3):
		colorPicker[i].color = savedColors[id][i]

func Proceed():
	Global.playerMesh = preview.GetActivePreview()
	preview.layout.remove_child(preview.GetActivePreview())
	Global.playerName = nameField.text
	get_tree().change_scene_to_file("res://Scenes/tree.tscn")
