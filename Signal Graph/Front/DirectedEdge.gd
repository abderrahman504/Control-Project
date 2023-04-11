extends Node2D
class_name DirectedEdge

var id: int
onready var line: Line2D = $Edge
onready var arrow: Line2D = $Arrow
var from: VarNode
var to: VarNode


func connect_edge(from: VarNode, to: VarNode):
	self.from = from
	self.to = to
	line.clear_points()
	line.add_point(from.rect_position + 0.5*from.rect_size)
	line.add_point(to.rect_position + 0.5*from.rect_size)
