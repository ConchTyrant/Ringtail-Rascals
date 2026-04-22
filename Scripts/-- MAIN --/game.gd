extends Node2D

# Game
@onready var GAME = $"."
# Player
@onready var PLAYER = $"Player Body"
# Player Camera
@onready var CAMERA : Camera2D = $"Player Body/Camera2D"

# All rooms
@onready var ROOM_BANK = get_tree().get_nodes_in_group("Room Group")
# All rooms' areas
var ROOM_AREA_BANK : Array
# All rooms' texture grounds
var TEXTURE_GROUNDS_BANK : Array


# --- ON READY ---
func _ready():
	# Get rooms' detection areas
	for i : Node2D in ROOM_BANK:
		var room_area : Area2D = i.get_node("Room Area")
		ROOM_AREA_BANK.append(room_area)
	
	# Get rooms' texture grounds
	for i in ROOM_BANK:
		var texture_grounds = i.get_node("Texture Grounds")
		TEXTURE_GROUNDS_BANK.append(texture_grounds)

# --- LOOP ---
func _process(_delta):
	detect()


# --- INDIVIDUAL FUNCS ---
var swap_queue : Array
func detect():
	for i : Area2D in ROOM_AREA_BANK:
		if i.overlaps_body(PLAYER):
			if not swap_queue.has(i):
				swap_queue.append(i)
		else:
			swap_queue.erase(i)
	# Call functions
	var current = swap_queue[0]
	camera(current)
	var ROOM = current.get_parent()
	roomOverlay(ROOM)

func camera(area):
	# Collision of room area
	var area_collision : CollisionShape2D = area.get_child(0)
	# Origin, aka midpoint, of room area
	var room_origin = area_collision.global_position
	# Dimensions of the room area [width,height]
	var room_size = area_collision.shape.size
	
	# - Limits -
	CAMERA.limit_left = room_origin.x - room_size.x/2
	CAMERA.limit_top = room_origin.y - room_size.y/2
	CAMERA.limit_right = room_origin.x + room_size.x/2
	CAMERA.limit_bottom = room_origin.y + room_size.y/2
	
	# - Zoom -
	# Dimensions of the viewport
	var VIEWPORT_RECT = get_viewport_rect()
	# How far to zoom in
	var zoom_aspect : float
	
	# Zoom proportions
	var zoom_by_y = VIEWPORT_RECT.size.y / room_size.y
	var zoom_by_x = VIEWPORT_RECT.size.x / room_size.x
	# If wide, zoom by x
	if zoom_by_y < zoom_by_x:
		zoom_aspect = zoom_by_x
	# If tall, zoom by y
	else:
		zoom_aspect = zoom_by_y
	
	# Apply zoom
	CAMERA.zoom = Vector2(zoom_aspect,zoom_aspect)

func roomOverlay(room): 
	for i : Node2D in ROOM_BANK:
		if i == room:
			i.visible = true
		else:
			i.visible = false
