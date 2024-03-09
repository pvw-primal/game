extends Node

const DEBUG : bool = false

var playerName : String = "Player"
var playerMesh : Node3D

var player : Player
var inventory : Array[Item]
var lastSlot : int
var initInventory : bool = true

var level : Level
var stage : int = 0
var options : int = 3
