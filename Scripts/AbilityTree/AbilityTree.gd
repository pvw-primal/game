class_name AbilityTree
extends Resource

const COLUMNS_MIN : int = 1
const COLUMNS_MAX : int = 4

var ABT : PackedScene = preload("res://Scripts/AbilityTree/AbilityTreeNode.tscn")

var tree : Array

func _init(rows : int):
	tree = []
	for i in range(rows):
		if i == 0 || i == rows - 1:
			tree.append([ABT.instantiate()] as Array[AbilityTreeNode])
			continue
		tree.append([] as Array[AbilityTreeNode])
		for x in range(randi_range(COLUMNS_MIN, COLUMNS_MAX)):
			tree[i].append(ABT.instantiate())
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
