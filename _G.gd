extends Node


class Branch:
	var tid = randi()
	var id = randi()
	var age = 0.0
	var leaves = 0.0
	var pos = Vector3()
	var end = Vector3()
	var depth = 1.0
	var hue = 0.0
	var offset = 0.0
	var dirx = 0.0
	var dirz = 0.0
	var dir = Vector3.UP
	var length = 0.0
	var width = 0.0
	var children = []
	
	func prepare(p=null):
		if p:
			pos = p.pos + p.dir * p.length * offset
		end = pos + dir * length

class Ground:
	var points
	var mid
	var color = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
