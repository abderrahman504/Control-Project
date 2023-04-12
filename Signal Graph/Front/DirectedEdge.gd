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
	from.outputs.append(self)
	to.inputs.append(self)
	line.clear_points()
	line.add_point(from.rect_position + 0.5*from.rect_size)
	line.add_point(to.rect_position + 0.5*from.rect_size)
	arrow.clear_points()
	var p2: Vector2 = 0.5 * (line.points[1] + line.points[0])
	var p1: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(45*PI/180)
	var p3: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(-45*PI/180)
	arrow.add_point(p1)
	arrow.add_point(p2)
	arrow.add_point(p3)
	


func update_pos():
	line.set_point_position(0, from.rect_position + 0.5*from.rect_size)
	line.set_point_position(1, to.rect_position + 0.5*to.rect_size)
	var p2: Vector2 = 0.5 * (line.points[1] + line.points[0])
	var p1: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(45*PI/180)
	var p3: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(-45*PI/180)
	arrow.set_point_position(0, p1)
	arrow.set_point_position(1, p2)
	arrow.set_point_position(2, p3)
