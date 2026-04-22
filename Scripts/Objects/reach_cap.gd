extends StaticBody2D

# Area
@onready var AREA = $Area2D

func _process(_delta):
	
	for body in AREA.get_overlapping_bodies():
		if body is player_body:
			if body.get_collision_mask_value(3):
				set_collision_layer_value(1,false)
			else:
				set_collision_layer_value(1,true)
