extends Control

var missingInOut := "Input and output nodes not set!"



func _ready():
	$WindowDialog.popup()
	$Canvas.connect("line_from_output", self, "show_error")
	$Canvas.connect("line_to_input", self, "show_error")


func _on_Node_button_up():
	$Canvas.state = $Canvas.NodeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Nodes"


func _on_Line_button_up():
	$Canvas.state = $Canvas.EdgeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Edges"


func _on_Clear_button_up():
	$Canvas.clear_canvas()


func _on_SetInput_button_up():
	$Canvas.state = $Canvas.ChooseIn
	$TopPanel/HBoxContainer/Label.text = "Choose Input"


func _on_SetOutput_button_up():
	$Canvas.state = $Canvas.ChooseOut
	$TopPanel/HBoxContainer/Label.text = "Choose Output"


func show_error(msg: String):
	var error: ErrorMsg = ErrorMsg.new()
	error.text = msg
	$ErrorConsole.add_child(error)


func _on_Evaluate_button_up():
	if $Canvas.input == null or $Canvas.output == null:
		show_error(missingInOut)
		return
	

func prep_graph() -> Dictionary:
	
	return {}







