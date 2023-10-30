class_name Status
extends Resource

var name : String
var turnsRemaining : int = 0
var OnTurnStart : Callable
var OnStatCheck : Callable
var OnPercentStatCheck : Callable

func _init(Name : String, turnstart = null, statcheck = null, percentstatcheck = null):
	name = Name
	if turnstart != null:
		OnTurnStart = turnstart
	if statcheck != null:
		OnStatCheck = statcheck
	if percentstatcheck != null:
		OnPercentStatCheck = percentstatcheck
		
static func Stun():
	var stun = func(stat: Stats):
		stat.CanAttack = false
		stat.CanMove = false
		return stat
	return Status.new("Stun", null, stun, null)

static func Disarm():
	var da = func(stat : Stats):
		stat.CanAttack = false
		return stat
	return Status.new("Disarm", null, da, null)

static func Paralysis():
	var para = func(stat : Stats):
		stat.CanMove = false
		return stat
	return Status.new("Paralysis", null, para, null)

static func Burning():
	var burn = func(e : Entity):
		var damage = randi_range(1, 4)
		e.animator.Damage()
		e.text.AddLine(e.Name + " was burned for " + str(damage) + " damage!\n")
		e.TakeDamage(damage)
	return Status.new("Burning", burn, null, null)
	
static func Air():
	var air = func(e : Entity):
		var healing = e.Heal(1)
		if healing > 0:
			e.text.AddLine("The cool breeze healed " + e.Name + " for " + str(healing) + " HP!\n")
	return Status.new("Refreshing Breeze", air, null, null)
	
#POW DEF MAG RES
static func Frost():
	var frost = func(sum : Array[float]):
		sum[0] -= .2
		sum[2] -= .2
		return sum
	return Status.new("Frostbite", null, null, frost)
	
#POW DEF MAG RES
static func Earth():
	var earth = func(sum : Array[float]):
		sum[1] += .2
		sum[3] += .2
		return sum
	return Status.new("Earthen Resistence", null, null, earth)
	
static func Stealth():
	var stealth = func(stat : Stats):
		stat.CanBeTargeted = false
		return stat
	return Status.new("Stealth", null, stealth, null)
	
static func Bleed():
	var bleed = func(e : Entity):
		e.animator.Damage()
		e.text.AddLine(e.Name + " bled for " + str(1) + " damage!\n")
		e.TakeDamage(1)
	return Status.new("Bleed", bleed, null, null)
