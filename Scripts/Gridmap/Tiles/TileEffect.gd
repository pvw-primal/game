class_name TileEffect
extends Node3D

enum Effect { Fire, Frost, Earth, Air, Force, Lightning, Radiant, Shadow, Smoke }
const TILE_EFFECT_TURNS = 10

static var fire = preload("res://Scripts/Gridmap/Tiles/Effects/FireTile.tscn")
static var frost = preload("res://Scripts/Gridmap/Tiles/Effects/FrostTile.tscn")
static var earth = preload("res://Scripts/Gridmap/Tiles/Effects/EarthTile.tscn")
static var air = preload("res://Scripts/Gridmap/Tiles/Effects/AirTile.tscn")
static var force = preload("res://Scripts/Gridmap/Tiles/Effects/ForceTile.tscn")
static var lightning = preload("res://Scripts/Gridmap/Tiles/Effects/LightningTile.tscn")
static var radiant = preload("res://Scripts/Gridmap/Tiles/Effects/RadiantTile.tscn")
static var shadow = preload("res://Scripts/Gridmap/Tiles/Effects/ShadowTile.tscn")
static var smoke = preload("res://Scripts/Gridmap/Tiles/Effects/SmokeTile.tscn")

@onready var gridmap : MapGenerator = get_node("/root/Root/GridMap")

var gridPos : Vector2i

var effect : Effect
var applyEffect : Callable
var remainingTurns : int

func init(pos : Vector3, eff : Effect, grid : Vector2i):
	position = pos
	gridPos = grid
	remainingTurns = TILE_EFFECT_TURNS
	var e
	effect = eff
	match effect:
		Effect.Fire:
			e = TileEffect.fire.instantiate()
			applyEffect = FireEffect
		Effect.Frost:
			e = TileEffect.frost.instantiate()
			applyEffect = FrostEffect
		Effect.Earth:
			e = TileEffect.earth.instantiate()
			applyEffect = EarthEffect
		Effect.Air:
			e = TileEffect.air.instantiate()
			applyEffect = AirEffect
		Effect.Force:
			e = TileEffect.force.instantiate()
			applyEffect = ForceEffect
		Effect.Lightning:
			e = TileEffect.lightning.instantiate()
			applyEffect = LightningEffect
		Effect.Radiant:
			e = TileEffect.radiant.instantiate()
			applyEffect = RadiantEffect
		Effect.Shadow:
			e = TileEffect.shadow.instantiate()
			applyEffect = ShadowEffect
		Effect.Smoke:
			e = TileEffect.smoke.instantiate()
			applyEffect = SmokeEffect
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

func ForceEffect(e : Entity):
	e.AddStatus(Status.Gravity(), 1)

func LightningEffect(e : Entity):
	if randf() > float(e.stats.HP) / e.stats.maxHP:
		e.AddStatus(Status.Paralysis(), 2)
		e.text.AddLine(e.GetLogName() + " was paralyzed!\n")
		
func RadiantEffect(e : Entity):
	if randf() > float(e.stats.HP) / e.stats.maxHP:
		e.AddStatus(Status.Disarm(), 1)
		e.text.AddLine(e.GetLogName() + " was disarmed by the radiant light!\n")

func ShadowEffect(e : Entity):
	e.AddStatus(Status.Shadow(), 1)

func SmokeEffect(_e : Entity):
	return

static func GetTileEffect(s : String) -> Effect:
	match s:
		"Fire":
			return Effect.Fire
		"Frost":
			return Effect.Frost
		"Earth":
			return Effect.Earth
		"Air":
			return Effect.Air
		"Force":
			return Effect.Force
		"Lightning":
			return Effect.Lightning
		"Radiant":
			return Effect.Radiant
		"Shadow":
			return Effect.Shadow
		_:
			return Effect.Air
		
