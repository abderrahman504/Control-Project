extends TextureRect
class_name VarNode
signal clicked

var id: int
var inputs: Array = []
var outputs: Array = []

#
#func get_drag_data(position) -> VarNode:
#	var preview: VarNode = load(Constants.varNodePath).instance()
#	preview.modulate = Color(1,1,1,0.25)
#	set_drag_preview(preview);
#
#	return self


func _gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("clicked", self, event)


func update_edges() -> void:
	for edge in inputs:
		edge.update_pos()
	for edge in outputs:
		edge.update_pos()
	
