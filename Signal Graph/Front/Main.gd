extends Control

var missingInOut := "Input and output nodes not set!"
var invalidGain := "Some gains can't be interpreted as numbers!"



func _ready():
	OS.set_window_title("Signal Flow Graph Solver");
	$WindowDialog.popup()
	$Canvas.connect("line_from_output", self, "show_error")
	$Canvas.connect("line_to_input", self, "show_error")

func _process(delta):
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	pass

func _on_Node_button_up():
	$Canvas.state = $Canvas.NodeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Nodes"
	$SoundAddNode.play()


func _on_Line_button_up():
	$Canvas.state = $Canvas.EdgeEdit
	$TopPanel/HBoxContainer/Label.text = "Add Edges"
	$SoundAddNode.play()


func _on_Clear_button_up():
	$Canvas.clear_canvas()
	$SoundAddNode.play()


func _on_SetInput_button_up():
	$Canvas.state = $Canvas.ChooseIn
	$TopPanel/HBoxContainer/Label.text = "Choose Input"
	$SoundAddNode.play()


func _on_SetOutput_button_up():
	$Canvas.state = $Canvas.ChooseOut
	$TopPanel/HBoxContainer/Label.text = "Choose Output"
	$SoundAddNode.play()


func show_error(msg: String):
	var error: ErrorMsg = ErrorMsg.new()
	error.text = msg
	$ErrorConsole.add_child(error)


func _on_Evaluate_button_up():
	$SoundEvaluate.play()
	if $Canvas.input == null or $Canvas.output == null:
		show_error(missingInOut)
		return
	for edge in $Canvas.edges.values():
		if not edge.get_node("Gain").text.is_valid_float():
			show_error(invalidGain)
			return
	var evaluator = load(Constants.evaluatorPath).new()
	evaluator.Initialize(prep_graph(), $SolutionWindow)
	

func prep_graph() -> Dictionary:
	var graph := {}
	for node in $Canvas.nodes.values():
		graph[node.label.text] = []
		for edge in node.outputs.values():
			graph[node.label.text].append([edge.get_gain(), edge.to.label.text])

	return graph

# Graph in dict form:
# {
# 	x1: [[gain, dest_node.name], [gain, dest_node.name], [gain, dest_node.name]]  
# 	x2: ...
# 	x3: ...
# 	x4: ...
# 	R: ...
# 	C: ...
# }
