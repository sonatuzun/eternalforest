extends Node


var elapsed_time = 0.0
var sed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	elapsed_time += delta

var access_count = 0
func true_for_some( mod ):
	access_count += 1
	return access_count % mod == 0

func v2_to_seed( v, s1 = 2135023, s2 = 135295):
	return v.x * s1 + v.y * s2

func randf_seed( seeed = null, precision = 10000 ):
	if not seeed:
		seeed = sed
	var rnd = rand_seed(int(seeed))
	var res = ( rnd[0] % int(precision) ) / float(precision)
	sed = rnd[1]
	return abs(res)

func randb( chance = 0.5, s = null):
	return randf_seed(s) < chance

func rand_color( seeed = null ):
		var rnd1 = randf_seed( seeed )
		var rnd2 = randf_seed( null )
		var rnd3 = randf_seed( null )
		return Color( rnd1, rnd2, rnd3, 1.0 )

func mix_color2( c1, c2, mix = 0.5):
	var r = lerp( c1.r, c2.r, mix)
	var g = lerp( c1.g, c2.g, mix)
	var b = lerp( c1.b, c2.b, mix)
	var a = lerp( c1.a, c2.a, mix)
	return Color( r, g, b, a )

func mix_color3( c1, c2, c3, f1 = 0.33, f2 = 0.33, f3 = 0.34):
	var t = f1 + f2 + f3
	var r = ( c1.r * f1 + c2.r * f2 + c3.r * f3 ) / t
	var g = ( c1.g * f1 + c2.g * f2 + c3.g * f3 ) / t
	var b = ( c1.b * f1 + c2.b * f2 + c3.b * f3 ) / t
	var a = ( c1.a * f1 + c2.a * f2 + c3.a * f3 ) / t
	return Color( r, g, b, a )

func rand_color_range( c1, c2, s = null):
	var r = rand_range_seed( c1.r, c2.r, s)
	var g = rand_range_seed( c1.g, c2.g, s)
	var b = rand_range_seed( c1.b, c2.b, s)
	var a = rand_range_seed( c1.a, c2.a, s)
	return Color( r, g, b, a)
	

func square_array( v, d = 1):
	var res = []
	for x in range( -d, d + 1):
		for y in range( -d, d + 1):
			res.append( v + Vector2( x, y ) )
	return res

func rand_color_mix2( c1, c2, seeed = null ):
	return mix_color2( c1, c2, randf_seed( seeed ) )

func rand_color_mix3( c1, c2, c3, seeed = null ):
	return mix_color3( c1, c2, c3, randf_seed( seeed ), randf_seed( null ), randf_seed( null ) )

func change_a( c, a ):
	return Color( c.r, c.g, c.b, a)

func lerp2( v1, v2, m ):
	return Vector2( lerp(v1.x, v2.x, m), lerp(v1.y, v2.y, m ) )

func clamp2( v1, v2, l ):
	return Vector2( clamp(v1.x, v2.x, l), clamp(v1.y, v2.y, l ) )

func rand_range_seed( f1, f2, s = null):
	var mix = randf_seed(s)
	return f1 * mix + f2 * ( 1 - mix )

func rand_range2( v1, v2, s = null):
	return Vector2( rand_range_seed( v1.x, v2.x, s), rand_range_seed( v1.y, v2.y, s) )

func xy( v3 ):
	return Vector2( v3.x, v3.y )

func xz( v3 ):
	return Vector2( v3.x, v3.z )

func yz( v3 ):
	return Vector2( v3.y, v3.z )

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
