extends Control






func _on_Node_button_up():
	$Canvas.state = $Canvas.NodeEdit


func _on_Line_button_up():
	$Canvas.state = $Canvas.EdgeEdit


func _on_Clear_button_up():
	$Canvas.clear_canvas()
