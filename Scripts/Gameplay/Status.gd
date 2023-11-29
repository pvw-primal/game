class_name Status
extends Resource

var name : String
var turnsRemaining : int = 0
var OnTurnStart : Callable
var OnStatCheck : Callable
var OnPercentStatCheck : Callable

static var status : Dictionary

func _init(Name : String, turnstart = null, statcheck = null, percentstatcheck = null):
	name = Name
	if turnstart != null:
		OnTurnStart = turnstart
	if statcheck != null:
		OnStatCheck = statcheck
	if percentstatcheck != null:
		OnPercentStatCheck = percentstatcheck

#temporary
static func InitStatus():
	Stun()
	Disarm()
	Paralysis()
	Burning()
	Air()
	Frost()
	Earth()
	Stealth()
	Bleed()

static func Stun():
	if "Stun" not in status:
		var stun = func(stat: Stats):
			stat.CanAttack = false
			stat.CanMove = false
			return stat
		status["Stun"] = Status.new("Stun", null, stun, null)
	return status["Stun"]

static func Disarm():
	if "Disarm" not in status:
		var da = func(stat : Stats):
			stat.CanAttack = false
			return stat
		status["Disarm"] = Status.new("Disarm", null, da, null)
	return status["Disarm"]

static func Paralysis():
	if "Paralysis" not in status:
		var para = func(stat : Stats):
			stat.CanMove = false
			return stat
		status["Paralysis"] = Status.new("Paralysis", null, para, null)
	return status["Paralysis"]

static func Burning():
	if "Burning" not in status:
		var burn = func(e : Entity):
			var damage = randi_range(1, 4)
			e.animator.Damage()
			e.text.AddLine(e.Name + " was burned for " + str(damage) + " damage!\n")
			e.TakeDamage(damage)
		status["Burning"] = Status.new("Burning", burn, null, null)
	return status["Burning"]
	
static func Air():
	if "Refreshing Breeze" not in status:
		var air = func(e : Entity):
			var healing = e.Heal(1)
			if healing > 0:
				e.text.AddLine("The cool breeze healed " + e.Name + " for " + str(healing) + " HP!\n")
		status["Refreshing Breeze"] = Status.new("Refreshing Breeze", air, null, null)
	return status["Refreshing Breeze"]
	
#POW DEF MAG RES
static func Frost():
	if "Frostbite" not in status:
		var frost = func(sum : Array[float]):
			sum[0] -= .2
			sum[2] -= .2
			return sum
		status["Frostbite"] = Status.new("Frostbite", null, null, frost)
	return status["Frostbite"]
	
#POW DEF MAG RES
static func Earth():
	if "Earthen Resistence" not in status:
		var earth = func(sum : Array[float]):
			sum[1] += .2
			sum[3] += .2
			return sum
		status["Earthen Resistence"] = Status.new("Earthen Resistence", null, null, earth)
	return status["Earthen Resistence"]
	
static func Stealth():
	if "Stealth" not in status:
		var stealth = func(stat : Stats):
			stat.CanBeTargeted = false
			return stat
		status["Stealth"] = Status.new("Stealth", null, stealth, null)
	return status["Stealth"]
	
static func Bleed():
	if "Bleed" not in status:
		var bleed = func(e : Entity):
			e.animator.Damage()
			e.text.AddLine(e.Name + " bled for " + str(1) + " damage!\n")
			e.TakeDamage(1)
		status["Bleed"] = Status.new("Bleed", bleed, null, null)
	return status["Bleed"]
