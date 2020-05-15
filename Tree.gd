extends Node2D


class Branch:
	var id = randi()
	var age = 0.0
	var leaves = 0.0
	var pos = Vector2()
	var depth = 1.0
	var hue = 0.0
	var offset = 0.0
	var dir = 0.0
	var tdir = 0.0
	var length = 0.0
	var width = 0.0
	var children = []

var root
var wind = 10.0
var length = rand_range( 20.0, 100.0 )
var width = rand_range( 5.0, 20.0 )
var limit = rand_range( 4.0, 10.0 )

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	modulate = Color( rand_range(0.5,1), rand_range(0,0.5), rand_range(0,0.5) )
	root = Branch.new()
	trav_and_generate(root, 1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.get_frames_per_second() > 30:
		trav_and_grow(root, 1.0, delta)
	pass

func trav_and_generate(b, depth):
	for i in pow( rand_range(0, 2.0), 2 )  * int(depth <= limit):
		var c = Branch.new()
		c.dir = b.dir + rand_range(-PI / 8.0 * ( i + 1 ), PI / 8.0 * ( i + 1 ) )
		c.offset = rand_range( 0.9, 1)
		c.hue = rand_range(0.0, 1.0)
		c.depth = depth + 1.0
		b.children.append(c)
	for c in b.children:
		c.pos = b.pos + Vector2.UP.rotated(b.tdir) * b.length * c.offset
		trav_and_generate(c, depth + 1.0)

func trav_and_grow(b,depth,delta):
	b.age += delta
	b.leaves = clamp( b.age - 1.0, 0, 1)
	if b.age < 100.0:
		b.length = lerp( 0.0, length / pow( depth, 0.1), clamp( b.age - depth / 4.0, 0, 1) )
		b.width = lerp( 0, width / pow( depth, 0.8), clamp( b.age - depth / 4.0, 0, 1) )
		b.tdir = b.dir + sin( ( b.age * depth + (b.pos.x + position.x) / 100.0) * 1.0 * pow( depth, 0.5) ) * 0.01 * wind * int( depth > 2.0 ) / depth
		b.tdir /= 1.0 + int(b.pos.y > 0)
	for c in b.children:
		c.pos = b.pos + Vector2.UP.rotated(b.tdir) * b.length * c.offset
		trav_and_grow(c, depth + 1.0, delta)

#func _draw():
#	var trav = []
#	var b
#	trav.append(root)
#	while( ! trav.empty() ):
#		b = trav[0]
#		trav.remove(0)
#		for c in b.children:
#			trav.append(c)
#		draw_line(b.pos, b.pos + Vector2.UP.rotated(b.tdir) * b.length, Color( 0.5 + b.hue / 2.0, 0.5 + b.hue / 2.0, 0.5 + b.hue / 2.0 ), b.width)
#		if b.depth > 3.0 and b.id % 100 > 50:
#			draw_circle( b.pos + Vector2.UP.rotated(b.tdir) * b.length, ( ( rand_seed(b.id)[0] % 10 ) + 10 ) * b.leaves, Color( 0.0, b.hue, b.hue, 0.9))
