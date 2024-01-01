class_name Stats
extends Resource

var maxHP : int
var HP : int
var POW : int
var DEF : int
var MAG : int
var RES : int
var CRIT : float

var CanMove : bool
var CanAttack : bool
var CanBeTargeted : bool

func _init(hp : int, Pow : int, def : int, mag : int, res : int, move : bool = true, attack : bool = true, cbt : bool = true, crit : float = 0):
	HP = hp
	maxHP = hp
	POW = Pow
	DEF = def
	MAG = mag
	RES = res
	CRIT = crit
	CanMove = move
	CanAttack = attack
	CanBeTargeted = cbt

func Copy():
	var copy = Stats.new(maxHP, POW, DEF, MAG, RES, CanMove, CanAttack, CanBeTargeted)
	copy.HP = HP
	copy.CRIT = CRIT
	return copy

func CopyAll(stats : Stats):
	maxHP = stats.maxHP
	POW = stats.POW
	DEF = stats.DEF
	MAG = stats.MAG
	RES = stats.RES
	CRIT = stats.CRIT
	CanMove = stats.CanMove
	CanAttack = stats.CanAttack
	CanBeTargeted = stats.CanBeTargeted
	
func Distribute(numStats : int):
	var statDistributed = Copy()
	for i in range(numStats):
		var chance =  randi_range(0, 4)
		if chance == 0:
			statDistributed.maxHP += 1
			statDistributed.HP += 1
		elif chance == 1:
			statDistributed.POW += 1
		elif chance == 2:
			statDistributed.DEF += 1
		elif chance == 3:
			statDistributed.MAG += 1
		elif chance == 4:
			statDistributed.RES += 1
	return statDistributed
	
func Modified(mods : Array[float]):
	return Stats.new(maxHP, int(POW * mods[0]), int(DEF * mods[1]), int(MAG * mods[2]), int(RES * mods[3]), CanMove, CanAttack, CanBeTargeted, CRIT + mods[4])

static func GetDamage(attacker : Stats, defender : Stats, Magic : bool = false, pierce : int = 0):
	if Magic:
		var res = defender.RES - pierce if defender.RES - pierce >= 0 else 0
		return attacker.MAG - res if attacker.MAG > res else 0
	else:
		var def = defender.DEF - pierce if defender.DEF - pierce >= 0 else 0
		return attacker.POW - def if attacker.POW > def else 0
