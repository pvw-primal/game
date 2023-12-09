class_name Status
extends Resource

var name : String
var turnsRemaining : int = 0
var OnTurnStart : Callable
var OnStatCheck : Callable
var OnPercentStatCheck : Callable

var icon : Texture2D

static var status : Dictionary

static var genericBuff : Texture2D = preload("res://Assets/Icons/Status/GenericBuff.png")
static var genericDebuff : Texture2D = preload("res://Assets/Icons/Status/GenericDebuff.png")

func _init(Name : String, turnstart = null, statcheck = null, percentstatcheck = null, i : Texture2D = null):
	name = Name
	if turnstart != null:
		OnTurnStart = turnstart
	if statcheck != null:
		OnStatCheck = statcheck
	if percentstatcheck != null:
		OnPercentStatCheck = percentstatcheck
	icon = i



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

static func AttackBuff():
	if "AttackBuff" not in status:
		var atk = func(sum : Array[float]):
			sum[0] += .3
			return sum
		status["AttackBuff"] = Status.new("AttackBuff", null, null, atk, genericBuff)
	return status["AttackBuff"]
	
static func MagicBuff():
	if "MagicBuff" not in status:
		var atk = func(sum : Array[float]):
			sum[1] += .3
			return sum
		status["MagicBuff"] = Status.new("MagicBuff", null, null, atk, genericBuff)
	return status["MagicBuff"]
	
static func DefenseBuff():
	if "DefenseBuff" not in status:
		var atk = func(sum : Array[float]):
			sum[2] += .3
			return sum
		status["DefenseBuff"] = Status.new("DefenseBuff", null, null, atk, genericBuff)
	return status["DefenseBuff"]

static func ResistenceBuff():
	if "ResistenceBuff" not in status:
		var atk = func(sum : Array[float]):
			sum[3] += .3
			return sum
		status["ResistenceBuff"] = Status.new("ResistenceBuff", null, null, atk, genericBuff)
	return status["ResistenceBuff"]

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
		status["Disarm"] = Status.new("Disarm", null, da, null, preload("res://Assets/Icons/Status/Disarm.png"))
	return status["Disarm"]

static func Paralysis():
	if "Paralysis" not in status:
		var para = func(stat : Stats):
			stat.CanMove = false
			return stat
		status["Paralysis"] = Status.new("Paralysis", null, para, null, preload("res://Assets/Icons/Status/Paralysis.png"))
	return status["Paralysis"]

static func Burning():
	if "Burning" not in status:
		var burn = func(e : Entity):
			var damage = randi_range(1, 4)
			e.animator.Damage()
			e.text.AddLine(e.Name + " was burned for " + str(damage) + " damage!\n")
			e.TakeDamage(damage)
		status["Burning"] = Status.new("Burning", burn, null, null, preload("res://Assets/Icons/Status/Burning.png"))
	return status["Burning"]
	
static func Air():
	if "Refreshing Breeze" not in status:
		var air = func(e : Entity):
			var healing = e.Heal(1)
			if healing > 0:
				e.text.AddLine("The cool breeze healed " + e.Name + " for " + str(healing) + " HP!\n")
		status["Refreshing Breeze"] = Status.new("Refreshing Breeze", air, null, null, preload("res://Assets/Icons/Status/Breeze.png"))
	return status["Refreshing Breeze"]
	
#POW DEF MAG RES
static func Frost():
	if "Frostbite" not in status:
		var frost = func(sum : Array[float]):
			sum[0] -= .2
			sum[2] -= .2
			return sum
		status["Frostbite"] = Status.new("Frostbite", null, null, frost, preload("res://Assets/Icons/Status/Frostbite.png"))
	return status["Frostbite"]
	
#POW DEF MAG RES
static func Earth():
	if "Earthen Resistence" not in status:
		var earth = func(sum : Array[float]):
			sum[1] += .2
			sum[3] += .2
			return sum
		status["Earthen Resistence"] = Status.new("Earthen Resistence", null, null, earth, preload("res://Assets/Icons/Status/Resistence.png"))
	return status["Earthen Resistence"]
	
static func Stealth():
	if "Stealth" not in status:
		var stealth = func(stat : Stats):
			stat.CanBeTargeted = false
			return stat
		status["Stealth"] = Status.new("Stealth", null, stealth, null, preload("res://Assets/Icons/Status/Stealth.png"))
	return status["Stealth"]
	
static func Bleed():
	if "Bleed" not in status:
		var bleed = func(e : Entity):
			e.animator.Damage()
			e.text.AddLine(e.Name + " bled for " + str(1) + " damage!\n")
			e.TakeDamage(1)
		status["Bleed"] = Status.new("Bleed", bleed, null, null, preload("res://Assets/Icons/Status/Bleed.png"))
	return status["Bleed"]
