extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.connect("clicked", self, "test_method")




func test_method():
	print("clicked")
