extends TextureRect


enum {NodeEdit, EdgeEdit}
var state: int
var nodeIDCounter := 0;
var nodes: Dictionary
var edgeIDCounter := 0
var edges: Dictionary


var draggingEdge := false
var ghostEdge: Line2D
var draggingNode := false
var heldNode: VarNode 





func _ready():
	state = NodeEdit

func _process(delta):
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
	nodeIDCounter += 1


func on_node_clicked(node: VarNode, event: InputEventMouseButton) -> void:
	match state:
		NodeEdit:
			if Input.is_action_just_pressed("LMB"):
				draggingNode = true
				heldNode = node
			elif Input.is_action_just_released("LMB"):
				draggingNode = false
			elif Input.is_action_just_released("RMB"): 
				node.queue_free()
		EdgeEdit:
			if not draggingEdge and Input.is_action_just_pressed("LMB"):
				start_dragging_edge(node)
			elif draggingEdge and Input.is_action_just_pressed("LMB"):
				create_edge(node)


func start_dragging_edge(from: VarNode) -> void:
	draggingEdge = true
	ghostEdge = Line2D.new()
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
	edge.connect_edge(heldNode, to)

#Called when dragging ends before the edge was connected to 2 nodes
func stop_dragging_edge() -> void:
	draggingEdge = false
	ghostEdge.queue_free()


func update_edges_at(node: VarNode):
	node.update_edges()

#
#func can_drop_data(position: Vector2, data) -> bool:
#	return data is VarNode and state == NodeEdit
#
#
#func drop_data(position: Vector2, data: VarNode) -> void:
#	data.set_position(position - 0.5*data.rect_size)



