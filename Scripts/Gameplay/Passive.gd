class_name Passive
extends Resource

var name : String
var description : String
var PassiveApply : Callable
var PassiveRemove : Callable
var internal : bool

static var passives : Dictionary = {}

func _init(n : String, apply : Callable = Callable(), remove : Callable = Callable(), Interal : bool = false):
	name = n
	description = ""
	PassiveApply = apply
	PassiveRemove = remove
	internal = Interal
