extends Area2D

class_name trash_heap


func _on_body_entered(body):
		if body is player_body:
			body.formSwap()
