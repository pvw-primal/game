#TODO: Optimize AI range checking, currently pathfinding is called twice (once in NoCorners, once in InRange; redundant)
class_name Move
extends Resource

static var moves : Dictionary
enum ActionType { move, attack, other }

var name : String
var attackEffects : Callable
var check : Callable
var magic : bool = false
var cutsCorners : bool = false
var atkRange : int = 1
var cooldown = 0
var icon : Texture2D = null
var projectileMesh : PackedScene = null

var playAnimation : bool = true
var manualEndTurn : bool = false
var manualCooldown : bool = false
var noTargets : bool = false
var reveals = true
var waittime : float = .65

func _init(Name : String, AttackEffects : Callable = Effects):
	name = Name
	attackEffects = AttackEffects
	check = MeleeCheck
	
func Use(attacker : Entity, defender : Entity = null, defenders : Array[Entity] = []):
	if !manualCooldown:
		attacker.StartCooldownName(name)
		if attacker.Type == "Player":
			attacker.skillUI.UpdateAll()
	if playAnimation:
		attacker.animator.Attack()
		
	if noTargets:
		await attackEffects.call(attacker, defender)
	elif defenders.size() > 0:
		for e in defenders:
			if check.call(attacker, e):
				await attacker.Wait(waittime)
				e.animator.Damage()
				attackEffects.call(attacker, e)
	elif check.call(attacker, defender):
		await attacker.Wait(waittime)
		defender.animator.Damage()
		attackEffects.call(attacker, defender)
	else:
		await attacker.Wait(waittime)
		
	if reveals:
		attacker.RemoveStatus("Stealth")
	attacker.lastAction = Move.ActionType.attack
	
	if !manualEndTurn:
		attacker.endTurn.emit()
		
func Effects(attacker : Entity, defender : Entity = null):
	var damage : int = Stats.GetDamage(attacker.stats, defender.stats, magic)
	attacker.text.AddLine(attacker.Name + " attacked " + defender.Name + " with " + name +  " for " + str(damage) + " damage!" + "\n")
	defender.TakeDamage(damage, attacker)
	
func InRange(attacker : Entity, defender : Entity):
	return attacker.gridmap.Pathfinding.get_id_path(attacker.gridPos, defender.gridPos).size() - 1 <= atkRange

func RemoveCheck():
	check = NoCheck

func NoCheck(_attacker : Entity, _defender : Entity):
	return true
	
func MeleeCheck(attacker : Entity, defender : Entity):
	return !(defender == null || (!cutsCorners && !attacker.gridmap.NoCorners(attacker.gridPos, defender.gridPos)))
	
static func DefaultPhysical():
	var move = Move.new("Attack")
	return move
	
static func DefaultMagical():
	var move = Move.new("Attack")
	move.magic = true
	return move

static func DefaultProjectile(applyMove : Move, r : int = 7):
	var proj = func(e : Entity, t : Entity):
		var dir = e.facingPos - e.gridPos
		var def = e.CheckDirection(dir, r) if t == null else [t.gridPos, t]
		if def[1] == null:
			e.gridmap.SpawnProjectile(e, def[0], 3, applyMove.projectileMesh)
		else:
			applyMove.playAnimation = false
			applyMove.manualEndTurn = true
			applyMove.RemoveCheck()
			applyMove.waittime = .1
			e.gridmap.SpawnProjectileTarget(e, def[1], applyMove, 3, applyMove.projectileMesh)
	
	var move = Move.new("Projectile", proj)
	move.manualEndTurn = true
	move.noTargets = true
	return move
	
	
