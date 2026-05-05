extends StaticBody2D

# Area detecting extending
@onready var AREA : Area2D = $Area2D
## Area's collision
@onready var AREA_COLLISION : CollisionShape2D = AREA.get_child(0)

# If ladder is already extended
var is_extended = false

func _ready():
	# Extend area size to starting ladder length
	## Starting ladder length, start at 0.
	var STARTING_LENGTH : int = 0
	## Find ladder length
	for i in get_children():
		if i is StaticBody2D:
			STARTING_LENGTH += 1
	## Define size
	var STARTING_SIZE : float = (16 * STARTING_LENGTH)
	## Extend and fit area collision to starting ladder
	AREA_COLLISION.shape.size.y = STARTING_SIZE
	AREA_COLLISION.position.y = STARTING_SIZE / 2

func _process(_delta):
	#  Check for pull down
	for body in AREA.get_overlapping_bodies():
		if body is player_body and is_extended == false:
			# If player is in Cotton form and is climbing on ladder
			if body.player_form == 'Cotton' and body.is_climbing:
				extend()

# Extends
func extend():
	is_extended = true
	# Length of full ladder
	var LENGTH : int = get_meta('length')
	#
	for i in range(LENGTH):
		# Create ladder node
		var new_ladder = $Ladder.duplicate()
		## Reparent as sibling
		get_parent().add_child(new_ladder)
		# Position ladder
		new_ladder.global_position.x = $Ladder.global_position.x
		new_ladder.global_position.y = $Ladder.global_position.y + (16 * i)
		
