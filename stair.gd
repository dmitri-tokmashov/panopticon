extends Spatial


var occupation: bool = false
onready var animation: AnimationPlayer = get_node("Animation")
onready var areas: Array = [
	get_node("1/Area"),
	get_node("2/Area"),
	get_node("3/Area")
]
onready var holder: Spatial = get_node("Holder/Rotation/Position")


func _ready():
	for index in range(3):
		areas[index].connect("area_entered", self, "move", [index + 1])


func move(area, level):
	if not occupation and not area.get_child(0).is_disabled() and area.get_parent() and area.get_parent().name == "Mesh":
		var _sprite = area.get_parent()
		var _volk = _sprite.get_parent()
		#if randi() % 4 == 3:
		if true:
			area.get_child(0).set_disabled(true)
			occupation = true
			for _area in areas:
				_area.get_child(0).set_disabled(true)
			_volk.pause = true
			var _global_translation = _sprite.get_global_translation()
			_volk.remove_child(_sprite)
			holder.add_child(_sprite)
			match level:
				1:
					animation.play("1")
					_volk.set_level(2)
					_volk.rotation_degrees.y -= 30
					if _volk.right:
						_volk.change_direction()
				2:
					if randi() & 1:
						animation.play_backwards("1")
						_volk.set_level(1)
						_volk.rotation_degrees.y += 30
						if not _volk.right:
							_volk.change_direction()
					else:
						animation.play("2")
						_volk.set_level(3)
						_volk.rotation_degrees.y -= 15
						if _volk.right:
							_volk.change_direction()
				3:
					animation.play_backwards("2")
					_volk.set_level(2)
					_volk.rotation_degrees.y += 15
					if not _volk.right:
						_volk.change_direction()
			animation.advance(0)
			_sprite.set_global_translation(_global_translation)
			var tween = get_tree().create_tween()
			tween.tween_property(_sprite, "translation", Vector3(0, 1.25, 0), 1.5)
			yield(animation, "animation_finished")
			_global_translation = _sprite.get_global_translation()
			holder.remove_child(_sprite)
			_volk.add_child(_sprite)
			_sprite.set_global_translation(_global_translation)
			tween = get_tree().create_tween()
			tween.tween_property(_sprite, "translation", Vector3(0, 0.25, -14), 1.25)
			#yield(tween, "finished")
			_volk.pause = false
			area.get_child(0).set_disabled(false)
			yield(get_tree().create_timer(5), "timeout")
			occupation = false
			for _area in areas:
				_area.get_child(0).set_disabled(false)
