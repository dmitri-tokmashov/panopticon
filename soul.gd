extends Spatial


signal losing_religion
signal death


var faith: String = "Cyan" setget change_faith
var level: int setget set_level
var alive: bool = true
var right: bool = true setget set_direction
var pause: bool = false
var animations: Array
var death: Array = [
	load("res://sounds/death/0.wav"),
	load("res://sounds/death/1.wav")
]
var mumble: Array = [
	load("res://sounds/mumble/0.ogg"),
	load("res://sounds/mumble/1.ogg"),
	load("res://sounds/mumble/2.ogg"),
	load("res://sounds/mumble/3.ogg")
]
onready var mesh = get_node("Mesh")
onready var area = mesh.get_node("Area")
onready var sound = mesh.get_node("Sound")


func _ready():
	mesh.get_surface_material(0).setup_local_to_scene()
	set_direction(bool(randi() & 1))
	sound.set_pitch_scale(rand_range(0.75, 1.0))
	area.connect("area_entered", self, "area_entered")
	area.connect("input_event", self, "area_input")


func _physics_process(delta):
	if not pause:
		set_rotation_degrees(Vector3(0, get_rotation_degrees().y + delta * (5 if right else -5), 0))


func change_faith(value: String):
	faith = value
	match faith:
		"Cyan":
			mesh.get_surface_material(0).set_emission(Color(0, 1, 1))
		"Magenta":
			mesh.get_surface_material(0).set_emission(Color(1, 0, 1))
			emit_signal("losing_religion")


func set_level(value):
	set_translation(Vector3(0, (value - 1) * 4, 0))
	level = value


func set_direction(value):
	mesh.scale.x = -6 if value else 6
	right = value


func change_direction():
	set_direction(not right)


func pause():
	pause = true
	var _texture = mesh.get_surface_material(0).get_texture(SpatialMaterial.TEXTURE_ALBEDO)
	_texture.set_pause(true)
	_texture.set_current_frame(0)
	yield(get_tree().create_timer(1.5), "timeout")
	pause = false
	_texture.set_pause(false)


func area_entered(area):
	if not area.get_child(0).is_disabled() and area.get_parent() and area.get_parent().name == "Mesh":
		var _volk = area.get_parent().get_parent()
		if not pause and not _volk.pause:
			if (faith == "Cyan" and randi() % 24 == 0) or (faith == "Magenta" and randi() % 2 == 0):
				talk(0, _volk)


func talk(index: int = 0, volk: Spatial = null):
	pause = true
	var _texture = mesh.get_surface_material(0).get_texture(SpatialMaterial.TEXTURE_ALBEDO)
	_texture.set_pause(true)
	_texture.set_current_frame(0)

	var _index: int = randi() % 4
	while _index == index:
		_index = randi() % 4
	sound.stream = mumble[_index]
	sound.play()
	if volk:
		volk.talk(_index)
	yield(get_tree().create_timer(2), "timeout")
	if alive:
		if volk and volk.alive and (faith != volk.faith):
			if volk.faith == "Magenta":
				change_faith("Magenta")
			if faith == "Magenta":
				volk.change_faith("Magenta")
		pause = false
		_texture.set_pause(false)


func area_input(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		alive = false
		pause = true
		area.get_child(0).set_disabled(true)
		var _animation = animations[1].duplicate()
		mesh.get_surface_material(0).set_texture(SpatialMaterial.TEXTURE_ALBEDO, _animation)
		mesh.get_surface_material(0).set_texture(SpatialMaterial.TEXTURE_EMISSION, _animation)
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(mesh, "translation", Vector3(0, 0.25, -13.75), 1)
		tween.tween_property(mesh.get_surface_material(0), "albedo_color", Color(0, 1, 1), 1)
		tween.tween_property(mesh.get_surface_material(0), "emission_energy", 1.0, 1)
		sound.set_pitch_scale(sound.get_pitch_scale() + 0.25)
		sound.stream = death[randi() % 2]
		sound.play()
		emit_signal("death", faith)
