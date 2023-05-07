extends TextureRect
signal line_from_output
signal line_to_input


enum {NodeEdit, EdgeEdit, ChooseIn, ChooseOut}
var state: int
var nodeIDCounter := 1
var nodes: Dictionary
var edgeIDCounter := 1
var edges: Dictionary
var input: VarNode = null
var output: VarNode = null

var draggingEdge := false
var ghostEdge: Line2D
var draggingNode := false
var heldNode: VarNode 

var lineToInputMsg := "Cannot draw an edge to the input node!"
var lineFromOutputMsg := "Cannot draw an edge from the output node!"




func _ready():
	state = NodeEdit

func _process(_delta):
	if draggingNode:
		heldNode.set_position(get_local_mouse_position() - 0.5*heldNode.rect_size)
		update_edges_at(heldNode)
	if draggingEdge:
		ghostEdge.set_point_position(1, get_local_mouse_position())



func _gui_input(event):
	if event is InputEventMouseButton:
		match state:
			NodeEdit:
				if Input.is_action_just_pressed("LMB"):
					create_node_at(get_global_mouse_position())
			
			EdgeEdit:
				if Input.is_action_just_released("LMB"):
					if draggingEdge: stop_dragging_edge()


func create_node_at(pos: Vector2) -> void:
	var node: VarNode = load(Constants.varNodePath).instance()
	add_child(node)
	var actualPos: Vector2 = pos - 0.5*node.rect_size
	node.rect_global_position = actualPos
	node.connect("clicked", self, "on_node_clicked")
	nodes[nodeIDCounter] = node
	node.id = nodeIDCounter
	node.label.text = "x" + str(node.id)
	nodeIDCounter += 1


func on_node_clicked(node: VarNode, _event: InputEventMouseButton) -> void:
	match state:
		NodeEdit:
			if Input.is_action_just_pressed("LMB"):
				draggingNode = true
				heldNode = node
			elif Input.is_action_just_released("LMB"):
				draggingNode = false
			elif Input.is_action_just_released("RMB"): 
				delete_node(node)
		EdgeEdit:
			if not draggingEdge and Input.is_action_just_pressed("LMB"):
				if (node == output):
					emit_signal("line_from_output", lineFromOutputMsg)
					return
				start_dragging_edge(node)
			elif draggingEdge and Input.is_action_just_pressed("LMB"):
				if (node == input):
					emit_signal("line_to_input", lineToInputMsg)
					stop_dragging_edge()
					return
				create_edge(node)
		ChooseIn:
			set_input(node)
		ChooseOut:
			set_output(node)


func start_dragging_edge(from: VarNode) -> void:
	draggingEdge = true
	ghostEdge = load(Constants.ghostEdgePath).instance()
	ghostEdge.clear_points()
	add_child(ghostEdge)
	heldNode = from
	ghostEdge.add_point(from.rect_position + 0.5*from.rect_size)
	ghostEdge.add_point(from.rect_position + 0.5*from.rect_size)


#Called when dragging ends after the edge has been connected to 2 nodes
func create_edge(to: VarNode) -> void:
	draggingEdge = false
	ghostEdge.queue_free()
	if to == heldNode: return
	var edge = load(Constants.directedEdgePath).instance()
	add_child(edge)
	edge.id = edgeIDCounter
	edge.connect_edge(heldNode, to)
	edges[edgeIDCounter] = edge
	edgeIDCounter += 1
	edge.connect("deleted", self, "on_edge_deleted")


#Called when dragging ends before the edge was connected to 2 nodes
func stop_dragging_edge() -> void:
	draggingEdge = false
	ghostEdge.queue_free()


func update_edges_at(node: VarNode):
	node.update_edges()


func clear_canvas():
	for node in nodes.values():
		node.queue_free()
	for edge in edges.values():
		edge.queue_free()
	nodes = {}
	edges = {}
	input = null
	output = null
	nodeIDCounter = 1
	edgeIDCounter = 1


func set_input(node: VarNode):
	if input != null:
		input.label.text = "x" + str(input.id)
	while(not node.inputs.empty()):
		node.inputs.values()[0].delete()
	node.label.text = "R"
	input = node
	if output == node: output = null

func set_output(node: VarNode):
	if output != null:
		output.label.text = "x" + str(output.id)
	while(not node.outputs.empty()):
		node.outputs.values()[0].delete()
	node.label.text = "C"
	output = node
	if input == node: input = null


func on_node_deleted(id: int):
	nodes.erase(id)

func on_edge_deleted(id: int):
	edges.erase(id)


func delete_node(node: VarNode):
	if input != null and input.id == node.id: input = null
	if output != null and output.id == node.id: output = null
	nodes.erase(node.id)
	node.delete()
