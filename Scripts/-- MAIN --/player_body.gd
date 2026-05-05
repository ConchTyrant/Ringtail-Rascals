extends CharacterBody2D

class_name player_body

# --- VARIABLES ---

# Player Body
@onready var PLAYER_BODY : CharacterBody2D = $"."

# 
var FORM_LIST : Array = ['Pieface', 'Mocha', 'Cotton']
var player_form : String = FORM_LIST[1]

# -- SPRITES --
## Animation player for form sprites
@onready var ANIMATE = $"Body Sprites/AnimationPlayer"
## Individual forms' sprites
@onready var COTTON_SPRITE = $"Body Sprites/Cotton Sprite"
@onready var MOCHA_SPRITE = $"Body Sprites/Mocha Sprite"
@onready var PIEFACE_SPRITE = $"Body Sprites/Pieface Sprite"
## List of forms' sprites
@onready var PLAYER_SPRITES = [COTTON_SPRITE, MOCHA_SPRITE, PIEFACE_SPRITE]

# -- COLLISION --
## Main collision
@onready var body_collision = $"Body Collision"
## Individual forms' collision measures
### Measure array : [radius,height, position.y]
var COTTON_COLLISION_MEASURE = [5,12, -5]
var MOCHA_COLLISION_MEASURE = [4, 12, -4]
var PIEFACE_COLLISION_MEASURE = [3,8, -3]


# Attributes
## 
var speed : float
## Determines jump forces: [high,wide].
var jump_force : Array
## 
var weight : float

# --- PHYSICS LOOP ---
# Direction of input movement
var direction : float
## Direction player is facing, default of 1.
var facing_direction : float = 1
func _physics_process(delta):
	direction = Input.get_axis('LEFT','RIGHT')
	if direction != 0:
		facing_direction = direction
	
	formAttributes()
	
	shape()
	
	# Base physics
	move_and_slide()
	
	steady()
	walk()
	jump()
	crawl()
	climb()
	grab()
	
	gravity(delta)



# --- FORM ATTRIBUTES ---
# Current form's sprite
var form_sprite : AnimatedSprite2D
func formAttributes():
	# - Forms' Attributes -
	var form_collision_measure : Array
	## PIEFACE
	if player_form == 'Pieface':
		form_sprite = PIEFACE_SPRITE
		form_collision_measure = PIEFACE_COLLISION_MEASURE
		#
		speed = 8
		jump_force = [3,1.1]
		weight = 1
	
	## MOCHA
	elif player_form == 'Mocha':
		form_sprite = MOCHA_SPRITE
		form_collision_measure = MOCHA_COLLISION_MEASURE
		#
		speed = 5
		jump_force = [1,3]
		weight = 2
		
	## COTTON
	elif player_form =='Cotton':
		form_sprite = COTTON_SPRITE
		form_collision_measure = COTTON_COLLISION_MEASURE
		#
		speed = 4
		jump_force = [2,2.5]
		weight = 4
	
	# Sprite visibility
	for i in PLAYER_SPRITES:
		if i == form_sprite:
			i.visible = true
		else:
			i.visible = false
	
	# Apply collision values
	## Apply crawling values
	if is_crawling:
		body_collision.shape.radius = form_collision_measure[0] / 2
		body_collision.shape.height = form_collision_measure[1] / 2
		body_collision.position.y = form_collision_measure[2] / 2
	## Apply basic values
	else:
		body_collision.shape.radius = form_collision_measure[0]
		body_collision.shape.height = form_collision_measure[1]
		body_collision.position.y = form_collision_measure[2]


# --- FORM SWAP ---
# Triggered externally by trash heaps
func formSwap():
	# Current form
	var current_form = FORM_LIST.find(player_form)
	# Loop array neatly
	if current_form + 1 == 3:
		current_form = -1
	# Next form in array to swap to
	var next_form = FORM_LIST[current_form + 1]
	# Swap form
	player_form = next_form
	# Propel player up


# --- SHAPE ---
# List of every area check
@onready var AREA_CHECK = $"Area Checks"
# Alter the shape of collisions
func shape():
	# - Turn sprites -
	## Flip all sprites based on input direction.
	for i in PLAYER_SPRITES:
		if direction < 0:
			i.flip_h = true
		elif direction > 0:
			i.flip_h = false
	
	# - Area checks -
	# Flip area check collisions
	if direction != 0:
		for i in AREA_CHECK.get_children():
			var area_child = i.get_child(0)
			area_child.position.x = abs(area_child.position.x) * direction
	
	# Reposition crawl upper check based on player form
	var CRAWL_UPPER_COLLISION = $"Area Checks/Crawl Checks/Crawl Upper-Check/CollisionShape2D"
	if player_form == 'Mocha':
		CRAWL_UPPER_COLLISION.position.y = -7
	elif player_form == 'Pieface':
		CRAWL_UPPER_COLLISION.position.y = -4
	else:
		pass

# --- MOVEMENT ---

# -- steady --
# If steadying
var is_steadying : bool
func steady():
	# If can steady
	var can_steady : bool
	if is_crawling:
		can_steady = false
	elif is_climbing:
		can_steady = false
	else:
		can_steady = true
	
	if can_steady and Input.is_action_pressed('UP'):
		is_steadying = true
		# Add steady mask value
		set_collision_mask_value(3,true)
		# Set to steady z-index
		z_index = 0
	else:
		is_steadying = false
		# Remove steady mask value
		set_collision_mask_value(3,false)
		# Set to default z-index
		z_index = 3


# -- WALK --
func walk():
	#
	if direction != 0 and is_on_floor():
		# Check if steadying
		if is_steadying:
			ANIMATE.play('reach')
		else:
			ANIMATE.play('walk')
		# Move
		velocity.x = speed*15 * direction
	# If no direction and is on floor, stop x-velocity.
	elif is_on_floor():
		if Input.is_action_pressed('UP'):
			ANIMATE.play('reach')
		else:
			ANIMATE.play('idle')
		velocity.x = move_toward(velocity.x,0, speed*15)



# -- JUMP --
func jump():
	# Determine if can jump
	var can_jump : bool
	## Cannot jump if off floor
	if not is_on_floor():
		can_jump = false
	elif is_crawling:
		can_jump = false
	elif is_climbing:
		can_jump = false
	else:
		can_jump = true
	
	# Perform jump on press
	if Input.is_action_just_pressed("JUMP") and can_jump:
		ANIMATE.play('jump')
		velocity.y = jump_force[1]*-90
	
	# Jump move
	if velocity.y < 0:
		velocity.x = jump_force[0]*50 * direction
	elif velocity.y > 0:
		velocity.x = jump_force[0]*30 * direction

# -- CRAWL --
@onready var CRAWL_UPPER_CHECK = $"Area Checks/Crawl Checks/Crawl Upper-Check"
@onready var CRAWL_LOWER_CHECK = $"Area Checks/Crawl Checks/Crawl Lower-Check"
var is_crawling : bool
func crawl():
	var can_crawl : bool
	if not is_on_floor():
		can_crawl = false
	elif player_form == 'Cotton':
		can_crawl = false
	else:
		can_crawl = true
	
	# Check for tilemaplayer collisions
	var upper_check : bool = false
	for body in CRAWL_UPPER_CHECK.get_overlapping_bodies():
		if body is TileMapLayer:
			upper_check = true
	var lower_check : bool = false
	for body in CRAWL_LOWER_CHECK.get_overlapping_bodies():
		if body is TileMapLayer:
			lower_check = true
	
	# If need crawl to enter and space for crawl, then crawl
	if upper_check and not lower_check and can_crawl:
		is_crawling = true
	else:
		is_crawling = false
	
	# 
	if is_crawling:
		ANIMATE.play('crawl')



# -- CLIMB --
# Ladder func is in ladder object
@onready var CLIMB_CHECK : Area2D = $"Area Checks/Climb Check"
# If climbing
var is_climbing : bool
func climb():
	var can_climb : bool
	# Determine if can climb
	## Cannot climb from crawl
	if is_crawling:
		can_climb = false
	else:
		can_climb = true
	
	#
	if Input.is_action_pressed('UP') and CLIMB_CHECK.has_overlapping_bodies() and can_climb:
		# If form is Cotton, check if climbable is ladder
		if player_form == 'Cotton':
			for x in CLIMB_CHECK.get_overlapping_bodies():
				if x.has_meta('ladder'):
					is_climbing = true
		else:
			is_climbing = true
	else:
		is_climbing = false
	
	if is_climbing:
		ANIMATE.play('climb flat')
		velocity.y = -50
		velocity.x = 5 * direction


# -- GRAB --
# Range of grab
@onready var GRAB_RANGE : Area2D = $"Area Checks/Grab Range"
# The object being grabbed
var grabbed_object : RigidBody2D
## The object's collision
var object_collision
# If player is grabbing an object
var is_grabbing : bool
func grab():
	# - Able -
	var can_grab : bool
	# Individual actions
	if is_grabbing or is_crawling or is_climbing:
		can_grab = false
	else:
		can_grab = true
	
	# -- Interact --
	if is_grabbing:
		# - Drop -
		if Input.is_action_just_pressed('INTERACT'):
			drop(grabbed_object)
	# - Range -
	else:
		for i in GRAB_RANGE.get_overlapping_bodies():
			# If is grabbable object and can grab
			if i is RigidBody2D and can_grab:
				## Input to grab
				if Input.is_action_just_pressed("INTERACT"):
					grabbed_object = i
					is_grabbing = true
	
	# - Collision -
	if is_grabbing:
		for i in grabbed_object.get_children():
			if i is CollisionShape2D or i is CollisionPolygon2D:
				object_collision = i
	
	
	# - Type -
	## The type of grab; 'carry' or 'drag'.
	var grab_type : String
	## Object weight
	var object_weight : float
	if is_grabbing:
		object_weight = grabbed_object.get_meta('weight')
		## If player weighs more than object, then carry.
		if weight > object_weight:
			grab_type = 'carry'
		## If player weighs up to 1 less than object, then drag.
		elif weight >= object_weight-1:
			grab_type = 'drag'
		# If object weighs too much, then cannot grab.
		else:
			drop(grabbed_object)
	
	# - Grab -
	## Carry
	if grab_type == 'carry':
		carry(grabbed_object)
	## Drag
	elif grab_type == 'drag':
		drag(grabbed_object)

# - Carry -
func carry(object : RigidBody2D):
	# Restrict object's individual movement
	## Freeze
	object.freeze = true
	## Remove collision
	object_collision.disabled = true
	
	
	# Move object to above player
	object.global_position.x = position.x + (10*facing_direction)
	object.global_position.y = position.y - 10
	
	# Animation
	ANIMATE.play('reach')


# - Drag -
func drag(object : RigidBody2D):
	# Ungrab
	## If y-axis is unstable ore not on floor, drop.
	if abs(object.linear_velocity.y) > 5 or abs(velocity.y) > 5 or not is_on_floor():
		drop(grabbed_object)
	
	# Move
	velocity.x = object.linear_velocity.x
	if direction != 0:
		object.linear_velocity.x = 40*facing_direction


# - Drop -
func drop(object: RigidBody2D):
	# Undo restrictions to object
	## Enable physics
	object.freeze = false
	## Enable collision
	object_collision.disabled = false
	# Remove object from grab
	is_grabbing = false
	grabbed_object = null



# --- MISC ---

# -- GRAVITY --
func gravity(delta):
	var max_fall_speed = weight*100
	if not is_on_floor():
		# Fall
		## If reaches max fall speed, limit fall.
		if velocity.y > max_fall_speed:
			pass
		## Regular gravity
		else:
			velocity.y += 300 *  weight * delta
		# If falling
		if velocity.y > 0:
			ANIMATE.play('fall')
