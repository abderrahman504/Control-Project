extends Node2D
class_name DirectedEdge
signal deleted

var id: int
onready var line: Line2D = $Edge
onready var arrow: Line2D = $Arrow
var from: VarNode
var to: VarNode


func connect_edge(from: VarNode, to: VarNode):
	self.from = from
	self.to = to
	from.outputs[id] = self
	to.inputs[id] = self
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	arrow.clear_points()
	arrow.add_point(Vector2.ZERO)
	arrow.add_point(Vector2.ZERO)
	arrow.add_point(Vector2.ZERO)
	update_pos()
	


func update_pos():
	line.set_point_position(0, from.rect_position + 0.5*from.rect_size)
	line.set_point_position(1, to.rect_position + 0.5*to.rect_size)
	var p2: Vector2 = 0.42 * (line.points[1] - line.points[0]) + line.points[0]
	var p1: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(45*PI/180)
	var p3: Vector2 = p2 + 20*(line.points[0] - p2).normalized().rotated(-45*PI/180)
	arrow.set_point_position(0, p1)
	arrow.set_point_position(1, p2)
	arrow.set_point_position(2, p3)
	
	var gainEditPos: Vector2 = p2 - Vector2(0, 30) - 0.5*$Gain.rect_size
	$Gain.rect_position = gainEditPos


func get_gain() -> float:
	return float($Gain.text)


func delete():
	to.inputs.erase(id)
	from.outputs.erase(id)
	queue_free()
	emit_signal("deleted", id)




