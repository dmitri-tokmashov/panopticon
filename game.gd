extends Node


var difficulty: int = 1
var intro: bool = true
var progress: bool = false
var soul: PackedScene = load("res://soul.scn")
var sound: PackedScene = load("res://sound.scn")
var cursors: Dictionary = {
	"hand": load("res://textures/cursors/hand.png"),
	"dagger": load("res://textures/cursors/dagger.png"),
	"eye": load("res://textures/cursors/eye.png"),
	"fire": load("res://textures/cursors/fire.png")
}
var count: Dictionary = {
	"Cyan": 33,
	"Magenta": 0,
	"Killed": 0,
	"Dead": 0
}
var devil_faces: Array = [
	load("res://textures/devil/1.png"),
	load("res://textures/devil/2.png")
]
var devil_voices: Array = [
	load("res://sounds/laugh/0.ogg"),
	load("res://sounds/laugh/1.ogg"),
	load("res://sounds/laugh/2.ogg"),
	load("res://sounds/laugh/3.ogg")
]
onready var viewport: Viewport = get_node("View/Container/Viewport")
onready var opening = get_node("Opening")
onready var setup = get_node("Setup")
onready var world = get_node("World")
onready var cursor: TextureRect = world.get_node("Cursor")
onready var camera = world.get_node("Camera")
onready var devil = world.get_node("Devil")
onready var volk = world.get_node("Volk")


func _ready():
	viewport.connect("size_changed", self, "size_changed")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	size_changed()
	#get_tree().set_pause(true)

	for child in devil.get_children():
		child.connect("camera_entered", self, "hide_devil", [child])

	remove_child(opening)
	viewport.add_child(opening)
	#camera.set_current(false)
	get_tree().create_timer(0.5).connect("timeout", self, "opening")


func _input(event):
	cursor.rect_position = viewport.get_size() * viewport.get_mouse_position() / OS.get_window_size() - 0.5 * cursor.rect_size


func _physics_process(delta):
#	for _volk in volk.get_children():
#		_volk.set_rotation_degrees(Vector3(0, _volk.get_rotation_degrees().y + delta * (15 if _volk.right else -15), 0))

	if progress:
		if Input.is_action_pressed("ui_right"):
			camera.rotation.y -= PI * delta
		if Input.is_action_pressed("ui_left"):
			camera.rotation.y += PI * delta
		devil.rotation.y -= (devil.rotation.y - camera.rotation.y) * 4 * delta

		var _from = camera.project_ray_origin(viewport.get_mouse_position() / 4)
		var _to = _from + camera.project_ray_normal(viewport.get_mouse_position() / 4) * 128.0
		var _pointed_object = world.get_world().direct_space_state.intersect_ray(_from, _to, [], 0x7FFFFFFF, true, true)
		if _pointed_object.has("collider"):
			if _pointed_object.collider.get_parent():
				match _pointed_object.collider.get_parent().name:
					"Holder":
						change_cursor("fire")
					"Mesh":
						change_cursor("dagger")
					_:
						change_cursor("eye")
		else:
			change_cursor("eye")
	else:
		if Input.is_action_pressed("game_restart") and world.get_parent() == viewport and world.get_node("Abyss").get_frame_color().a == 1.0:
			restart()


func opening():
	if intro:
		opening.get_node("Music").play()
		yield(get_tree().create_timer(0.5), "timeout")
		var angel = opening.get_node("Angel")
		var angel_eyes: Array = [
			load("res://textures/angel/eye/1.png"),
			load("res://textures/angel/eye/2.png"),
			load("res://textures/angel/eye/3.png"),
			load("res://textures/angel/eye/4.png"),
			load("res://textures/angel/eye/5.png")
		]
		var eye = angel.get_node("1").mesh.surface_get_material(1)
		#eye.set_current_frame(0)
		#eye.set_oneshot(true)
		#eye.set_pause(true)
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(opening.get_node("Abyss"), "color", Color(0.0, 0.0, 0.0, 0.0), 2.5)
		tween.tween_property(opening.get_node("Camera"), "translation", Vector3(0.0, 8.0, 18.0), 6.25).set_trans(Tween.TRANS_SINE)
	#	tween.tween_property(angel.get_node("1"), "rotation", Vector3(PI * 2, 0, 0), 8.75).set_trans(Tween.TRANS_SINE)
	#	tween.tween_property(angel.get_node("1/2"), "rotation", Vector3(0, PI * 2, 0), 8.75).set_trans(Tween.TRANS_SINE)
	#	tween.tween_property(angel.get_node("1/2/3"), "rotation", Vector3(0, 0, PI * 2), 8.75).set_trans(Tween.TRANS_SINE)
		tween.tween_property(angel.get_node("1"), "rotation", Vector3(PI * 2 / 4, 0, 0), 8.75).set_trans(Tween.TRANS_SINE)
		tween.tween_property(angel.get_node("1/2"), "rotation", Vector3(0, PI * 2 / 4, 0), 8.75).set_trans(Tween.TRANS_SINE)
		tween.tween_property(angel.get_node("1/2/3"), "rotation", Vector3(0, 0, PI * 2 / 4), 8.75).set_trans(Tween.TRANS_SINE)
		yield(get_tree().create_timer(2.5), "timeout")
		angel.get_node("Soul").play()
		angel.get_node("Soul").set_volume_db(-15)
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(angel.get_node("Soul"), "volume_db", 15, 3.75)
		tween.tween_property(opening.get_node("Devil"), "translation", Vector3(0.0, 8.0, -16.0), 6.25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(opening.get_node("Devil"), "modulate", Color(1.0, 0.0, 1.0, 1.0), 6.25).set_trans(Tween.TRANS_SINE)
		yield(get_tree().create_timer(6.25), "timeout")
		for texture in angel_eyes:
			eye.albedo_texture = texture
			yield(get_tree().create_timer(0.125), "timeout")
		yield(get_tree().create_timer(0.25), "timeout")
		opening.get_node("Abyss/Sound").play()
		opening.get_node("Abyss").set_frame_color(Color(0, 0, 0, 1))
		opening.get_node("Title").set_visible(true)
		yield(get_tree().create_timer(1.25), "timeout")
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(opening.get_node("Title"), "modulate", Color(1.0, 0.0, 1.0, 0.0), 2.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(opening.get_node("Music"), "volume_db", -80, 2.5).set_trans(Tween.TRANS_SINE)
		yield(get_tree().create_timer(2.5), "timeout")
	#get_node("View/Container/Viewport").remove_child(opening)
	opening.queue_free()
	setup()
	#tween.tween_property(opening.get_node("Devil"), "modulate", Color(1.0, 0.0, 1.0, 1.0), 6.25).set_trans(Tween.TRANS_SINE)
	
	#tween.tween_property(opening.get_node("Angel"), "scale", Vector3(0.5, 0.5, 0.5), 10)


func setup():
	setup.set_visible(true)
	remove_child(setup)
	viewport.add_child(setup)
	world.remove_child(cursor)
	setup.add_child(cursor)
	cursor.set_visible(true)
	change_cursor("hand")
	setup.connect("gui_input", self, "_input")
	setup.get_node("Difficulty/Normal").connect("pressed", self, "set_difficulty", [1])
	setup.get_node("Difficulty/Hard").connect("pressed", self, "set_difficulty", [2])


func set_difficulty(value):
	difficulty = value
	setup.remove_child(cursor)
	setup.queue_free()

	var _rooms: Array = [
		30, 60, 90, 120, 150, 180, 210, 240, 270, 300,
		0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300,
		0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330
	]
	var _animations: Array = [
		load("res://walk.res"),
		load("res://death.res")
	]
	_animations[1].set_oneshot(true)
	for _index in range(33):
		volk.add_child(soul.instance())
		volk.get_child(_index).connect("losing_religion", self, "change_faith")
		volk.get_child(_index).connect("death", self, "volk_death", [-1])
		volk.get_child(_index).animations = _animations
		volk.get_child(_index).set_level(1 if _index < 10 else 2 if _index < 21 else 3)
		volk.get_child(_index).set_rotation_degrees(Vector3(0, _rooms[_index], 0))
	while count["Magenta"] != [1, 3][difficulty - 1]:
		volk.get_child(randi() % 33).change_faith("Magenta")

	start()


func start():
	if cursor.get_parent() != world:
		world.add_child(cursor)
	else:
		cursor.set_visible(true)
	world.set_visible(true)
	world.get_node("Cyan").set_visible(true)
	world.get_node("Magenta").set_visible(true)
	world.get_node("Music").set_volume_db(-20)
	world.get_node("Music").play(0)

	var _levels: Array = [
		[2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	]
	for index in range(3):
		for room in _levels[index]:
			world.get_node("Levels/" + str(index + 1) + "/Rooms/" + str(room)).torch = 1.0
			world.get_node("Levels/" + str(index + 1) + "/Rooms/" + str(room)).light.set_visible(true)
			world.get_node("Levels/" + str(index + 1) + "/Rooms/" + str(room)).fire.set_visible(true)

	if world.get_parent() != viewport:
		remove_child(world)
		viewport.add_child(world)
	progress = true


func size_changed():
	var _viewport_resolution = Vector2(200 * viewport.get_size().x / viewport.get_size().y, 200)
	viewport.get_parent().get_material().set_shader_param("resolution", _viewport_resolution)
	cursor.rect_size = viewport.get_size() / _viewport_resolution * 24
	#if setup:
		#setup.rect_size = _viewport_resolution
		#setup.rect_scale = Vector2(0.5, 0.5)


func change_cursor(type: String):
	cursor.set_texture(cursors[type])


func change_faith():
	update_counter("Cyan", -1)
	update_counter("Magenta", 1)


func volk_death(type, value):
	update_counter(type, value)
	if type == "Cyan":
		count["Killed"] += 1
		if difficulty == 2 and count["Killed"] > 2:
			finish(false)

		var _sound: AudioStreamPlayer = sound.instance()
		add_child(_sound)
		_sound.stream = devil_voices[randi() % 4]
		_sound.set_volume_db(-20.0)
		_sound.set_bus("Devil")
		_sound.play()
		yield(_sound, "finished")
		remove_child(_sound)
		_sound.queue_free()


func update_counter(type, value):
	count[type] += value
	if count["Cyan"] < 3:
		finish(false)
	if not count["Magenta"] and (count["Cyan"] != 32 or value == -1):
		finish(true)
	var _label: Label = world.get_node(type)
	var _text: String
	for _index in range(count[type] / 10):
		_text += "X"
	if count[type] % 10 < 4:
		for _index in range(count[type] % 10):
			_text += "I"
	elif count[type] % 10 == 4:
		_text += "IV"
	elif count[type] % 10 < 9:
		_text += "V"
		for _index in range(count[type] % 10 - 5):
			_text += "I"
	else:
		_text += "IX"
	_label.set_text(_text)


func hide_devil(camera: Camera, notifier: VisibilityNotifier):
	var _sprite: Sprite3D = notifier.get_node("Sprite")
	var _sound: AudioStreamPlayer3D = notifier.get_node("Sound")
	if _sprite.modulate.a == 1.0:
		_sprite.set_visible(true)
		notifier.disconnect("camera_entered", self, "hide_devil")
		yield(get_tree().create_timer(0.125), "timeout")
		if notifier.is_on_screen():
			_sound.play()
			yield(get_tree().create_timer(0.25), "timeout")
			var tween = get_tree().create_tween()
			tween.tween_property(_sprite, "modulate", Color(1.0, 0.0, 1.0, 0.0), 0.125)
		else:
			_sprite.modulate.a = 0.0
		notifier.connect("camera_entered", self, "hide_devil", [notifier])
	else:
		_sprite.set_visible(false)
		_sprite.set_texture(devil_faces[randi() % 2])
		yield(get_tree().create_timer(rand_range(60.0, 240.0)), "timeout")
		_sprite.modulate.a = 1.0


func finish(state: bool):
	if progress:
		progress = false
		var message: String
		var color: Color
		world.get_node("Finish/Message").text += "ТЫ ПОБЕДИЛ!" if state else "ТЫ ПРОИГРАЛ!"
		world.get_node("Finish/Restart").set_visible(not state)
		world.get_node("Finish").set_modulate(Color(0, 1, 1, 0) if state else Color(1, 0, 1, 0))
		world.get_node("Finish").set_visible(true)
		world.get_node("Cyan").set_visible(false)
		world.get_node("Magenta").set_visible(false)
		cursor.set_visible(false)
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(world.get_node("Abyss"), "color", Color(0.0, 0.0, 0.0, 1.0), 2.5)
		tween.tween_property(world.get_node("Finish"), "modulate", Color(0, 1, 1, 1) if state else Color(1, 0, 1, 1), 2.5)
		tween.tween_property(world.get_node("Music"), "volume_db", -80, 2.5)


func restart():
	#for soul in volk.get_children():
		#soul.queue_free()
	world.get_node("Abyss").set_frame_color(Color(0.0, 0.0, 0.0, 0.0))
	world.get_node("Finish/Message").text = "ИГРА ОКОНЧЕНА.\n"
	world.get_node("Finish").set_visible(false)

	count = {
		"Cyan": 33,
		"Magenta": 0,
		"Killed": 0,
		"Dead": 0
	}

	var _rooms: Array = [
		30, 60, 90, 120, 150, 180, 210, 240, 270, 300,
		0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300,
		0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330
	]
	for _index in range(33):
		volk.get_child(_index).change_faith("Cyan")
		volk.get_child(_index).set_level(1 if _index < 10 else 2 if _index < 21 else 3)
		volk.get_child(_index).set_rotation_degrees(Vector3(0, _rooms[_index], 0))
		volk.get_child(_index).alive = true
		volk.get_child(_index).pause = false
		volk.get_child(_index).mesh.get_surface_material(0).set_albedo(Color8(192, 192, 192))
		volk.get_child(_index).mesh.get_surface_material(0).set_emission_energy(0)
		var _animation = volk.get_child(_index).animations[0].duplicate()
		volk.get_child(_index).mesh.get_surface_material(0).set_texture(SpatialMaterial.TEXTURE_ALBEDO, _animation)
		volk.get_child(_index).mesh.get_surface_material(0).set_texture(SpatialMaterial.TEXTURE_EMISSION, null)
		if volk.get_child(_index).has_node("Mesh/Area/Shape"):
			volk.get_child(_index).get_node("Mesh/Area/Shape").set_disabled(false)
	while count["Magenta"] != [1, 3][difficulty - 1]:
		volk.get_child(randi() % 33).change_faith("Magenta")

	start()
