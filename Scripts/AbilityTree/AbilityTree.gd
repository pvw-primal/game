class_name AbilityTree
extends Resource

const COLUMNS_MIN : int = 1
const COLUMNS_MAX : int = 4

static var ABT : PackedScene = preload("res://Scripts/AbilityTree/AbilityTreeNode.tscn")

var tree : Array

func _init(rows : int, c : bool = true, t : Array = []):
	tree = t
	if tree.size() < 1:
		for i in range(rows):
			if i == 0 || i == rows - 1:
				tree.append([ABT.instantiate()] as Array[AbilityTreeNode])
				continue
			tree.append([] as Array[AbilityTreeNode])
			for x in range(randi_range(COLUMNS_MIN, COLUMNS_MAX)):
				tree[i].append(ABT.instantiate())
	if c:
		ConnectTree()
				
func ConnectTree():
	for row in range(0, tree.size() - 1):
		if tree[row].size() > tree[row + 1].size():
			for column in range(tree[row].size()):
				for connection in GetConnections(column, tree[row].size(), tree[row + 1].size()):
					Connect(tree[row][column], tree[row + 1][connection])
		else:
			for column in range(tree[row + 1].size()):
				for connection in GetConnections(column, tree[row + 1].size(), tree[row].size()):
					Connect(tree[row][connection], tree[row + 1][column])
				
func GetConnections(fromPos : int, fromSize : int, toSize : int) -> Array[int]:
	if toSize == 0:
		return []
	if toSize == 1:
		return [0]
	if fromSize == 1:
		return range(toSize)
	
	var ratio : float = (fromPos + 1) / float(fromSize)
	var pos : int = ceili(toSize * ratio)
	return [clampi(pos - 1, 0, toSize - 1)]

func Connect(nodeLower : AbilityTreeNode, nodeUpper : AbilityTreeNode):
	nodeLower.to.append(nodeUpper)
	nodeUpper.from.append(nodeLower)

func Disconnect(nodeLower : AbilityTreeNode, nodeUpper : AbilityTreeNode):
	nodeLower.to.erase(nodeUpper)
	nodeUpper.from.erase(nodeLower)

static func StarterTree() -> AbilityTree:
	var starterTree : Array = [[] as Array[AbilityTreeNode], [] as Array[AbilityTreeNode], [] as Array[AbilityTreeNode]]
	var size : int = 0
	for cl in Classes.BaseClass.values():
		if cl == Classes.BaseClass.None:
			continue
		var data : AbilityTreeData = AbilityTreeData.new()
		data.AddClassNode(Classes.GetClass(cl))
		var node : AbilityTreeNode = ABT.instantiate()
		node._init(data)
		starterTree[size % 3].append(node)
		size += 1
	return AbilityTree.new(-1, false, starterTree)
	
static func NewClassTree(options : int = 3) -> AbilityTree:
	var start : AbilityTreeNode = ABT.instantiate()
	start._init(null)
	var newClassTree : Array = [[start] as Array[AbilityTreeNode], [] as Array[AbilityTreeNode]]
	var bases = Classes.BaseClass.values()
	bases.erase(Classes.BaseClass.None)
	
	var remaining : int = options
	while remaining > 0:
		var cl : Classes.BaseClass = bases[randi_range(0, bases.size() - 1)]
		bases.erase(cl)
		if Global.player.classE.HasBase(cl):
			continue
		var data : AbilityTreeData = AbilityTreeData.new()
		data.AddClassNode(Classes.ClassDict[Classes.GetClassNum(cl) + Global.player.classE.classBit], Global.player.classE.moves, Global.player.classE.passives)
		var node : AbilityTreeNode = ABT.instantiate()
		node._init(data)
		newClassTree[1].append(node)
		remaining -= 1
	return AbilityTree.new(-1, true, newClassTree)

static func RandomAbilityTree(options : int = 3) -> AbilityTree:
	var abilities : Array[AbilityTreeData] = RandomAbility.Get(options)
	var start : AbilityTreeNode = ABT.instantiate()
	start._init(null)
	var abilityTree : Array = [[start] as Array[AbilityTreeNode], [] as Array[AbilityTreeNode]]
	for data in abilities:
		var node : AbilityTreeNode = ABT.instantiate()
		node._init(data)
		abilityTree[1].append(node)
	return AbilityTree.new(-1, true, abilityTree)

static func GetNextTree(stage : int) -> AbilityTree:
	match stage:
		0: return StarterTree()
		2: return NewClassTree(Global.options)
		_: return RandomAbilityTree(Global.options)
		

	
	
	
	
	
	
