extends Spatial


var torch = 1.0
onready var door_area = get_node("Door/Area")
onready var torch_area = get_node("Wall/Holder/Area")
onready var torch_sound = get_node("Wall/Holder/Fire/Sound")
onready var light = get_node("Wall/Holder/Light")
onready var fire = get_node("Wall/Holder/Fire")


func _ready():
	_change_light()
	door_area.connect("area_entered", self, "door_area_entered")
	torch_area.connect("input_event", self, "torch_area_input")


func _physics_process(delta):
	if torch > 0:
		torch -= delta / (24 + randi() % 16)
		light.set_param(light.PARAM_ENERGY, 0.25 * torch)
		fire.set_translation(Vector3(0, -0.5, 0.375) + Vector3(0, 0, 0.625) * torch)
		fire.set_scale(Vector3.ONE * torch)
	elif light.is_visible():
		light.set_visible(false)
		fire.set_visible(false)


func _change_light():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "omni_range", rand_range(6.0, 8.0), 0.25)
	tween.tween_callback(self, "_change_light")


func door_area_entered(area):
	if not area.get_child(0).is_disabled() and area.get_parent() and area.get_parent().name == "Mesh":
		var _volk = area.get_parent().get_parent()
		if randi() & 1:
			_volk.change_direction()
#		elif randi() & 1:
#			_volk.pause()


func torch_area_input(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		torch = 1.0
		torch_sound.play()
		light.set_visible(true)
		fire.set_visible(true)
