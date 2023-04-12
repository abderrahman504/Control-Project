extends TextureRect
class_name VarNode
signal clicked
signal deleted

var id: int
onready var label: Label = $Label
var inputs: Dictionary = {}
var outputs: Dictionary = {}


func _gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("clicked", self, event)


func update_edges() -> void:
	for edge in inputs.values():
		edge.update_pos()
	for edge in outputs.values():
		edge.update_pos()
	


func delete():
	for edge in inputs.values():
		edge.delete()
	for edge in outputs.values():
		edge.delete()
	queue_free()
	emit_signal("deleted", id)
