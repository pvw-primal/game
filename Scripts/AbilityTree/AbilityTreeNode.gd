class_name AbilityTreeNode
extends Node3D

var from : Array[AbilityTreeNode]
var to : Array[AbilityTreeNode]

var Name : String
var desc : String

func _init():
	from = []
	to = []
	
func _ready():
	Name = "Test Node"
	desc = "This node is at (" + str(position.x) + ", " + str(position.z) + ")."
	
