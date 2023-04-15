extends Label
class_name ErrorMsg

var deathTime: float = 7
var deathCounter: float = 0


func _process(delta):
	modulate.a = (deathTime - deathCounter) / deathTime
	deathCounter += delta
	if deathCounter >= deathTime: queue_free()
