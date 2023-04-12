extends Control






func _on_Node_button_up():
	$Canvas.state = $Canvas.NodeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Nodes"


func _on_Line_button_up():
	$Canvas.state = $Canvas.EdgeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Edges"


func _on_Clear_button_up():
	$Canvas.clear_canvas()
