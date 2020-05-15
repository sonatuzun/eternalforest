extends Node2D

export (Color) var day_color = Color.black
var night_color = Color.black
var fog_color setget ,get_fog_color
func get_fog_color():
	return _C.mix_color2( day_color, night_color, sin( _C.elapsed_time * 2 * PI / day_length) / 2 + 1 )
var fog_exp = 1.0
var fog_modulate = 0.8
var day_length = 20.0
var ground_color = Color.red
var world_seed
var last_delta = 0
var grounds = []
var Tre = preload("res://Tree.tscn")
var tree_density = 0.5
var vis_range = 800.0
var zone_res = 4
var zone_size = Vector2( vis_range / zone_res, vis_range / zone_res) * 1.2
var zones = {}
var curr_zone = Vector2()

var mid_screen2 = OS.window_size / 2.0
var mid_screen3 = Vector3( mid_screen2.x, 40.0, mid_screen2.y)
var position3 = Vector3()
var axx = Vector3.LEFT
var axy = Vector3.UP
var look = axx.cross(axy)
var ms = Vector2()
var update_visibles = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	world_seed = randi()
	$BG.color = day_color
	change_zone(Vector2())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

var speed = Vector2()
var walk_time = 0.0
func _process(delta):
#	update_visibile_list()
	last_delta = delta
	process_input(delta)
	var mov_for = look.slide(Vector3.UP).normalized() * delta * 200.0
	var mov_sid = axx.slide( Vector3.UP).normalized() * delta * 200.0
	walk_time += speed.length() * delta
	position3 += mov_for * speed.y
	position3 += mov_sid * speed.x
	position3.y = sin( walk_time * 10.0) * 5.0 + 50.0
	$FPS.text = "FPS: " + String( Engine.get_frames_per_second() ) + \
	"\n\nWASD, Mouse \nR: change world \nESC: focus/unfocus the mouse \nF4: Toggle Fullscreen"
	var new_zone = ( _C.xz(position3) / zone_size ).floor()
#	$Zone.text = "position: " + String( _C.xz(position3) ) + "\n" + \
#		"zone: " + String( new_zone ) + "\n" + \
#		"active zones: " + String( zones.keys().size() ) + "\n"
	if new_zone != curr_zone:
		change_zone(new_zone)
	$BG.color = self.fog_color
	$CM.color = _C.mix_color2( self.fog_color, Color.white, fog_modulate )
	if update_visibles:
		update_visibile_list()
	update()
	update_visibles = false
	pass

#zone functions
func change_zone( loc ):
	curr_zone = loc
	var sa = _C.square_array( loc, zone_res)
#	var sa = [loc]
	for v in sa:
		if not zones.has(v):
			generate_zone(v)
	for k in zones.keys():
		if not k in sa:
			delete_zone(k)
	update_visibles = true

func generate_zone( loc ):
	var sed = _C.v2_to_seed(loc) + world_seed
	if _C.randb( tree_density, sed ):
		var tre = Tre.instance()
		tre.position = loc * zone_size + _C.rand_range2(Vector2(), zone_size, sed )
		$Trees.add_child(tre)
		zones[loc] = tre
func delete_all_zones():
	for k in zones.keys():
		delete_zone(k)
func delete_zone( loc ):
	if zones[loc]:
		zones[loc].queue_free()
	zones.erase(loc)

func process_input(delta):
	var mov = Vector2()
	if Input.is_action_pressed("ui_up"):
		mov.y += 1
	if Input.is_action_pressed("ui_down"):
		mov.y -= 1
	if Input.is_action_pressed("ui_left"):
		mov.x -= 1
	if Input.is_action_pressed("ui_right"):
		mov.x += 1
	if mov == Vector2.ZERO:
		speed = _C.lerp2( speed, Vector2(), delta * 5.0 )
	else:
		mov = mov.normalized()
		speed.y = lerp( speed.y, mov.y, delta )
		speed.x = lerp( speed.x, mov.x, delta )
		update_visibles = true

func _input(event):
	if event is InputEventMouseMotion:
		ms += event.relative / 20.0 * last_delta
	if Input.is_action_just_pressed("fullscreen"):
		change_full_screen()
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == \
			Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE )
	if Input.is_action_just_pressed("refresh_zones"):
		randomize()
		day_color = _C.rand_color_range( Color.black, Color.white )
		ground_color = _C.rand_color()
		day_length = rand_range( 20.0, 60.0 )
		fog_modulate = rand_range( 0.7, 1.0 )
		world_seed = randi()
		delete_all_zones()
		change_zone(curr_zone)
	axx = Vector3.LEFT.rotated( Vector3.UP, ms.x * 2 * PI)
	axy = Vector3.UP.rotated( axx, ms.y * 2 * PI )
	look = axx.cross(axy)
	update_visibles = true

func change_full_screen():
	OS.window_fullscreen = not OS.window_fullscreen

func sort_branchs(a, b):
	return a.pos.dot(look) > b.pos.dot(look)

func proj( v3 ):
	var r = ( v3 - position3 ).normalized() * 1000.0
	return Vector2( r.dot( axx ), -r.dot( axy ) ) + mid_screen2
	pass

func in_fov( pts ):
	var ang = ( pts - position3 ).angle_to(look)
	return ang < PI / 4.0

#zone of consideration
func in_zoc( pts ):
	pass

var list = []
var glist = []
func update_visibile_list():
	list = []
	var trav = []
	var b
#	vis_range = lerp( vis_range, 20.0 * Engine.get_frames_per_second(), 0.1 )
	for tr in zones.values():
		if tr:
			tr.root.prepare()
			var tvis = ( tr.root.end - position3 ).dot(look)
			var in_fov = in_fov(tr.root.end)
			if  in_fov and tvis < vis_range:
				list.append(tr.root)
#				trav.append(tr.root)
			if tvis > -5.0 and tvis < vis_range * 1.5:
				trav.append(tr.root)
				tr.set_process(true)
			else:
				tr.set_process(false)
			while( ! trav.empty() ):
				b = trav[0]
				trav.remove(0)
				for c in b.children:
					trav.append(c)
					if in_fov( c.pos ) and tvis < vis_range:
						list.append(c)
#					else:
#						if _C.print_some( tvis, 1000 ):
#							print( c.end )
					$vlistsize.text = "Visible branches: " + String( list.size() ) + "\n" + \
						"Tree count: " + String( $Trees.get_child_count() ) + "\n"
	list.sort_custom(self, "sort_branchs")

var seg_size = 100.0
var seg_count = 6
var roughness = 20.0
var elevation = -5.0
func find_grpt(x,y ):
	return Vector3 (seg_size * x, _C.randf_seed(x * 100 + y ) * roughness + elevation, seg_size * y)

func _draw():
	var stx = int( position3.x / seg_size )
	var sty = int( position3.z / seg_size )
	for x in range(stx - seg_count, stx + seg_count ):
		for y in range(sty - seg_count, sty + seg_count ):
			var sp = 1
			var sds = [seg_count * x + y, seg_count * (x+sp) + y, seg_count * (x+sp) + y + sp, seg_count * x + y + sp]
			var gr_points = [ find_grpt( x, y ), find_grpt( x + sp, y ), find_grpt( x + sp, y + sp ), find_grpt( x , y + sp ) ]
			var gr_mid = ( gr_points[0] + gr_points[2] ) / 2.0
			var gvis = ( gr_mid - position3 ).dot(look)
			var disp = ( gr_mid - position3 )
			var gangle =  ( gr_mid - position3 ).angle_to(look)
			var ganglex = disp.angle_to(look.slide(Vector3.UP))
			var gangley = abs( disp.angle_to( Vector3.UP) - look.angle_to(Vector3.UP) )
			if look.angle_to(Vector3.UP) > PI / 2.5:
				if ganglex < PI / 2.0 and gvis < vis_range:
					var gr_color = _C.rand_color_mix3(ground_color, Color.brown, Color.gray, sds[0]  )
					gr_color = _C.mix_color2( gr_color, self.fog_color, pow( gvis / 600.0, 1.0) )
					var gr_pts = PoolVector2Array( [ proj(gr_points[0]), proj(gr_points[1]), proj(gr_points[2]) ] )
					draw_polygon( gr_pts, PoolColorArray([ gr_color  ]) )
					gr_pts = PoolVector2Array( [ proj(gr_points[0]), proj(gr_points[2]), proj(gr_points[3]) ] )
					draw_polygon( gr_pts, PoolColorArray([ gr_color ]) )
	var unit = 1.0
	for b in list:
		if b.end.y > 0:
			var dist = b.end.distance_to(position3) / 1000.0
			var start = proj(b.pos)
			var end = proj(b.end)
			var bvis = ( b.end - position3 ).dot(look)
			var bcolor = _C.rand_color(b.tid + 1)
			bcolor = _C.mix_color2(bcolor, Color( b.hue, b.hue, b.hue ), 0.8 )
			bcolor = _C.mix_color2( bcolor, self.fog_color, pow( bvis / vis_range, fog_exp ) )
			var lcolor = _C.mix_color2( _C.rand_color(b.tid), self.fog_color, pow( bvis / vis_range, fog_exp ) )
			draw_line( start, end, bcolor, unit * b.width / dist ) 
			if b.depth > 3.0 and b.id % 100 < 80:
				draw_circle( end, ( unit * ( rand_seed(b.id)[0] % 60 ) + 10 ) / dist  / 3.0 * b.leaves, lcolor ) 
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
