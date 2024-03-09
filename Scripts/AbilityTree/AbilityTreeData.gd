class_name AbilityTreeData
extends Resource

var name : String
var desc : String

var showDifficulty : bool
var difficulty : int
var difficultyName : String

var icon : Texture2D
var color : Color = Color.BLACK
var item : PackedScene
	
var OnLevelStart : Callable

func _init(n : String = "Test Node", d : String = ""):
	name = n
	desc = d
	showDifficulty = false
	difficulty = 0
	difficultyName = Level.GetDifficultyName(difficulty)

func SetDifficulty(difficult : int):
	showDifficulty = true
	difficulty = difficult
	difficultyName = Level.GetDifficultyName(difficulty)
	
func AddClassNode(c : Class, currentMoves : Array[Move] = [], currentPassives : Array[Passive] = []):
	name = c.name
	var showMove : int = 0 if c.moves.size() == 1 else 2
	icon = c.moves[showMove].icon
	desc = c.description
	if showMove == 2:
		desc += "\n[b][i][font_size=25]![/font_size][/i][/b]New skills:"
	desc += "\n[img=64x64]" + c.moves[showMove].icon.resource_path + "[/img] " + c.moves[showMove].name + " -\n[indent]" + c.moves[showMove].description + "[/indent]"
	for i in range(c.moves.size()):
		if i == showMove || c.moves[i] in currentMoves:
			continue
		desc += "\n[img=64x64]" + c.moves[i].icon.resource_path + "[/img] " + c.moves[i].name + " -\n[indent]" + c.moves[i].description + "[/indent]"
	for i in range(c.passives.size()):
		if i == showMove || c.passives[i] in currentPassives || c.passives[i].internal:
			continue
		desc += "\n[b][i][font_size=25]m[/font_size][/i][/b] " + c.passives[i].name + " (Passive) -\n[indent]" + c.passives[i].description + "[/indent]"
	
	OnLevelStart = func(p : Player, _tp : AbilityTreePlayer):
		p.SetClass(c)

