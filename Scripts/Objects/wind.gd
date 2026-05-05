extends Node2D

class_name wind

# Detects bodies in wind
@onready var AREA = $Area2D

func _process(_delta):
	# Find wind direction; polarity of axes
	var SPRITE_END : AnimatedSprite2D = $"Sprite End"
	var SPRITE_BODY : AnimatedSprite2D = $"Sprite Body"
	## X-axis
	var dir_x = sign(abs(round(SPRITE_END.global_position.x)) - abs(round(SPRITE_BODY.global_position.x)))
	## Y-axis
	var dir_y = sign(abs(SPRITE_END.global_position.y) - abs(SPRITE_BODY.global_position.y))
	## Vector of x and y
	var DIRECTION : Vector2 = Vector2(dir_x,dir_y)
	
	
	for body in AREA.get_overlapping_bodies():
		if body is RigidBody2D or body is CharacterBody2D:
			# Check for attributes
			## Weight. Default of 1
			var weight : float = 5
			## Player
			if body is player_body:
				weight = body.weight
			## Object
			elif body.has_meta('weight'):
				weight = body.get_meta('weight')
			
			# - PUSH -
			## Max force of push for object
			var MAX_PUSH : Vector2 = DIRECTION * 300 / weight
			
			if body is player_body:
				if abs(body.velocity) < MAX_PUSH:
					body.velocity.x += 200 / weight * DIRECTION.x
					body.velocity.y += -150 / weight * DIRECTION.y
					# Play fall when pushed and not on floor
					if not body.is_on_floor():
						body.ANIMATE.play('fall')
			# Linear velocity for rigidbodies
			else:
				body.linear_velocity.x = 230 / weight * DIRECTION.x
				body.linear_velocity.y = -100 / weight * DIRECTION.y
