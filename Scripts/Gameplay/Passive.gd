class_name Passive
extends Resource

var name : String
var PassiveApply : Callable
var PassiveRemove : Callable
var internal : bool

static var passives : Dictionary = {}

func _init(n : String, apply : Callable, remove : Callable, Interal : bool = false):
	name = n
	PassiveApply = apply
	PassiveRemove = remove
	internal = Interal
