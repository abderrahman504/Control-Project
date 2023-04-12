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
	node.connect("deleted", self, "on_node_deleted")
	nodes[nodeIDCounter] = node
	node.id = nodeIDCounter
	node.label.text = "x" + str(node.id+1)
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
				node.delete()
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
	nodeIDCounter = 0
	edgeIDCounter = 0


func on_node_deleted(id: int):
	nodes.erase(id)

func on_edge_deleted(id: int):
	edges.erase(id)
