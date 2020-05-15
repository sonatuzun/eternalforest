extends Node2D

var elapsed_time = 0.0

var active = true
var root
var wind = 2.0
var length
var width
var limit
var growth_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	_C.sed = _C.v2_to_seed( global_position )
	root = _G.Branch.new()
	root.pos = Vector3( position.x, 0, position.y )
	root.tid = rand_seed(_C.sed)[0]
	length = _C.rand_range_seed( 20.0, 100.0 )
	width = _C.rand_range_seed( 10.0, 60.0 )
	limit = _C.rand_range_seed( 4.0, 10.0 )
	growth_speed = _C.rand_range_seed( 5.0, 10.0 )
	trav_and_generate(root, 1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	trav_and_grow(root, 1.0, delta)
#	update()
	pass

func trav_and_generate(b, depth):
	b.hue = _C.rand_range_seed(0.0, 1.0)
	for i in pow( _C.rand_range_seed(0, 1.6), 2 )  * int(depth <= limit):
		var c = _G.Branch.new()
		c.dirx = _C.rand_range_seed(-PI / 8.0 * ( i + 1 ), PI / 8.0 * ( i + 1 ) )
		c.dirz = _C.rand_range_seed(-PI / 8.0 * ( i + 1 ), PI / 8.0 * ( i + 1 ) )
		c.offset = _C.rand_range_seed( 0.9, 1)
		c.depth = depth + 1.0
		b.children.append(c)
	for c in b.children:
		c.pos = b.pos + b.dir * b.length * c.offset
		c.tid = b.tid
		trav_and_generate(c, depth + 1.0)

func trav_and_grow(b,depth,delta):
#	grown
#	b.age = 90.0
#	#growing
#	b.age += delta
#	bionic
#	b.age = sin(elapsed_time + b.id / 5.0) * 10.0 + 10
#	shrinking
	b.age = sin(elapsed_time / growth_speed + root.tid ) * 10.0 + 10
	b.leaves = clamp( b.age / 3.0 - 0.5, 0, 1)
	if b.age < 100.0:
		b.length = lerp( 0.0, length / pow( depth + 1.0, 0.1), clamp( b.age - depth / 4.0, 0, 1) )
		b.width = lerp( 0, width / pow( depth + 1.0, 0.8), clamp( b.age - depth / 4.0 , 0, 1) )
	for c in b.children:
		c.prepare(b)
#		c.pos = b.pos + b.dir * b.length * c.offset
		var tempdir = b.dir.rotated( b.dir.cross(Vector3.FORWARD).normalized(), c.dirx + sin( elapsed_time * depth + c.pos.x) / 40.0 / depth )
		c.dir = tempdir.rotated( b.dir.cross(Vector3.LEFT).normalized(), c.dirz + sin(elapsed_time * depth + c.pos.x) / 40.0 / depth)
		trav_and_grow(c, depth + 1.0, delta)

#var axx = Vector3.LEFT
#var axy = Vector3.UP
#func _input(event):
#	var ms = get_global_mouse_position()
#	axx = Vector3.FORWARD.rotated( Vector3.UP, ms.x / 50.0)
#	axy = Vector3.UP.rotated( axx, ms.y / 50.0 )
##	axx = axx.project( axy ).normalized()

#func sort_branchs(a, b):
#	var look = axx.cross(axy)
#	return a.end.dot(look) > b.end.dot(look)

#func _draw():
#	pass
#	var trav = []
#	var list = []
#	var b
#	trav.append(root)
#	list.append(root)
#	while( ! trav.empty() ):
#		b = trav[0]
#		trav.remove(0)
#		for c in b.children:
#			trav.append(c)
#			list.append(c)
#	list.sort_custom(self, "sort_branchs")
#	for b in list:
#		b.end = b.pos + b.dir * b.length
#		var brot = elapsed_time
#		var start = Vector2( b.pos.dot( axx ), -b.pos.dot( axy ) )
#		var end = Vector2( b.end.dot(axx), -b.end.dot(axy) )
#		draw_line( start, end, Color( b.hue, b.hue, b.hue), b.width)
#		if b.depth > 3.0 and b.id % 100 < 100:
#			draw_circle( end, ( ( rand_seed(b.id)[0] % 40 ) + 10 ) * b.leaves, Color( 0.0, b.hue, b.hue, 1.0))
