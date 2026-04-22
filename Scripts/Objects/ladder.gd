extends StaticBody2D

class_name ladder

@onready var LADDER_CHECK = $"Area2D"

var player_on_ladder
func _process(_delta):
	for i in LADDER_CHECK.get_overlapping_bodies():
		if i is player_body:
			if Input.is_action_pressed('UP'):
				i.velocity.y = -50
				i.ANIMATE.play('climb flat')
