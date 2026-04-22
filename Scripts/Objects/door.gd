extends StaticBody2D

class_name door

# Collision of the door
@onready var COLLISION : CollisionShape2D = $CollisionShape2D


# Area to perform open
@onready var OPEN_AREA : Area2D = $"Open Area"

# SPRITE
##
@onready var SPRITE_GROUP : Node2D = $Sprites
## 
@onready var SPRITE_SOLID : AnimatedSprite2D = $"Sprites/Sprite Solid"
@onready var SPRITE_WINDOWED : AnimatedSprite2D = $"Sprites/Sprite Windowed"
## Animation states
@onready var ANIMATION_PLAYER : AnimationPlayer = $AnimationPlayer
## Door types
### Available door types
var DOOR_TYPES : Array = ["solid", "windowed"]
### Door's type
@onready var door_type = DOOR_TYPES[get_meta("door_type")]

# DOOR STATE AND KEY
# If the door is closed or open
## Default to closed
var is_door_closed : bool = true
# If the door is locked and requires a key
var is_locked : bool
# The key required to unlock door
var door_key

# FUNCS

func _ready():
	var is_facing_left : bool = get_meta("is_facing_left")
	# FACING LEFT COLLISIONS
	if is_facing_left:
		COLLISION.position.x = abs(COLLISION.position.x)
		OPEN_AREA.position.x = 0
	
	
	# SPRITES
	## For all sprites
	for i : AnimatedSprite2D in SPRITE_GROUP.get_children():
		# Disable
		i.visible = false
		# Direction Facing
		if is_facing_left:
			i.flip_h = true
		else:
			i.flip_h = false
	## Enable correct sprite
	if door_type == "solid":
		SPRITE_SOLID.visible = true
	elif door_type == "windowed":
		SPRITE_WINDOWED.visible = true

func _process(_delta):
	# Detect player in front of door
	for body in OPEN_AREA.get_overlapping_bodies():
		if body is player_body:
			is_door_closed = false
	
	# DOOR STATE
	if is_door_closed:
		# When closed, enable collision
		COLLISION.disabled = false
	else:
		COLLISION.disabled = true
		ANIMATION_PLAYER.play("open")
