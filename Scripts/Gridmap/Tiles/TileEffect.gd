class_name TileEffect
extends Node3D

enum Effect { Fire, Frost, Earth, Air, Force, Lightning, Radiant, Shadow }
const TILE_EFFECT_TURNS = 10

@onready var fire = preload("res://Scripts/Gridmap/Tiles/Effects/FireTile.tscn")
@onready var frost = preload("res://Scripts/Gridmap/Tiles/Effects/FrostTile.tscn")
@onready var earth = preload("res://Scripts/Gridmap/Tiles/Effects/EarthTile.tscn")
@onready var air = preload("res://Scripts/Gridmap/Tiles/Effects/AirTile.tscn")

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")

var gridPos : Vector2i

var effect : Effect
var applyEffect : Callable
var applyOnEnter : bool
var remainingTurns : int

func init(pos : Vector3, eff : Effect, grid : Vector2i):
	position = pos
	gridPos = grid
	remainingTurns = TILE_EFFECT_TURNS
	var e
	effect = eff
	applyOnEnter = true
	if effect == Effect.Fire:
		e = fire.instantiate()
		applyEffect = FireEffect
		applyOnEnter = false
	elif effect == Effect.Frost:
		e = frost.instantiate()
		applyEffect = FrostEffect
	elif effect == Effect.Earth:
		e = earth.instantiate()
		applyEffect = EarthEffect
	elif effect == Effect.Air:
		e = air.instantiate()
		applyEffect = AirEffect
	add_child(e)

func OnTurn():
	remainingTurns -= 1
	if remainingTurns < 0:
		gridmap.RemoveTileEffect(gridPos)

func FireEffect(e : Entity):
	e.AddStatus(Status.Burning(), 1)

func FrostEffect(e : Entity):
	e.AddStatus(Status.Frost(), 1)

func EarthEffect(e : Entity):
	e.AddStatus(Status.Earth(), 1)

func AirEffect(e : Entity):
	e.AddStatus(Status.Air(), 1)

static func GetTileEffect(s : String) -> Effect:
	if s == "Fire":
		return Effect.Fire
	elif s == "Frost":
		return Effect.Frost
	elif s == "Earth":
		return Effect.Earth
	elif s == "Air":
		return Effect.Air
	elif s == "Force":
		return Effect.Force
	elif s == "Lightning":
		return Effect.Lightning
	elif s == "Radiant":
		return Effect.Radiant
	else:
		return Effect.Shadow
		
