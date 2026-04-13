extends CharacterBody2D

# --- VARIABLES ---

# Player Body
## Used to clarify code.
@onready var PLAYER_BODY = $"."

# 
var form_list = ['Pieface', 'Mocha', 'Cotton']
var player_form = form_list[1]


# -- SPRITES --
## Individual forms' sprites
@onready var COTTON_SPRITE = $"Body Sprites/Cotton Sprite"
@onready var MOCHA_SPRITE = $"Body Sprites/Mocha Sprite"
@onready var PIEFACE_SPRITE = $"Body Sprites/Pieface Sprite"
## List of forms' sprites
@onready var PLAYER_SPRITES = [COTTON_SPRITE, MOCHA_SPRITE, PIEFACE_SPRITE]

# -- COLLISION --
## Main collision
@onready var body_collision = $"Body Collision"
## Individual forms' collisions
@onready var COTTON_COLLISION = $"Body Collision/Cotton Collision"
@onready var MOCHA_COLLISION = $"Body Collision/Mocha Collision"
@onready var PIEFACE_COLLISION = $"Body Collision/Pieface Collision"
## List of forms' collisions
@onready var PLAYER_COLLISIONS = [COTTON_COLLISION, MOCHA_COLLISION, PIEFACE_COLLISION]

# Attributes
## 
var speed : float
## Determines jump forces: [wide,high].
var jump_force : Array
## 
var weight : float

# --- PHYSICS LOOP ---
## 
func _physics_process(delta):
	formAttributes()
	formSwap()
	
	animate()
	
	# Base physics
	move_and_slide()
	
	walk()
	jump()
	
	gravity(delta)


# --- FORM STABILIZER ---
## Current form's sprite
var form_sprite : AnimatedSprite2D
var form_collision : CollisionShape2D
func formAttributes():
	# MOCHA
	if player_form == 'Pieface':
		form_sprite = PIEFACE_SPRITE
		form_collision = PIEFACE_COLLISION
		#
		speed = 8
		jump_force = [3,1]
		weight = 1
	
	# MOCHA
	elif player_form == 'Mocha':
		form_sprite = MOCHA_SPRITE
		form_collision = MOCHA_COLLISION
		#
		speed = 5
		jump_force = [1,3]
		weight = 3
		
	# COTTON
	elif player_form =='Cotton':
		form_sprite = COTTON_SPRITE
		form_collision = COTTON_COLLISION
		#
		speed = 3
		jump_force = [2,2]
		weight = 5
	
	# Sprite visibility
	for i in PLAYER_SPRITES:
		if i == form_sprite:
			i.visible = true
		else:
			i.visible = false
	
	# Apply collision values
	body_collision.shape = form_collision.shape
	body_collision.transform = form_collision.transform


# --- FORM SWAP ---
func formSwap():
	if Input.is_action_just_pressed("INTERACT"):
		if player_form == 'Pieface':
			player_form = 'Mocha'
		elif player_form == 'Mocha':
			player_form = 'Cotton'
		elif player_form == 'Cotton':
			player_form = 'Pieface'


# --- ANIMATION ---
##
@onready var ANIMATE = $"Body Sprites/AnimationPlayer"
func animate():
	# If no movement, play idle animation.
	if not velocity:
		ANIMATE.play('idle')
	
	# - Turn sprites -
	var direction = Input.get_axis('LEFT','RIGHT')
	## Flip all sprites based on input direction.
	for i in PLAYER_SPRITES:
		if direction <0:
			i.flip_h = true
		elif direction >0:
			i.flip_h = false


# --- MOVEMENT ---

# -- WALK --
func walk():
	
	var direction = Input.get_axis('LEFT','RIGHT')
	#
	if direction != 0 and is_on_floor():
		ANIMATE.play('walk')
		velocity.x = speed*15 * direction
	# If no direction and is on floor, stop x-velocity.
	elif is_on_floor():
		velocity.x = move_toward(velocity.x,0, speed*15)

# -- JUMP --
func jump():
	var direction = Input.get_axis('LEFT','RIGHT')
	# Determine if can jump
	var can_jump : bool
	## Cannot jump if off floor
	if not is_on_floor():
		can_jump = false
	## Can jump
	else:
		can_jump = true
	
	# Perform jump on press
	if Input.is_action_just_pressed("JUMP") and can_jump:
		ANIMATE.play('jump')
		velocity.y = jump_force[1]*-125
	
	# Jump move
	if velocity.y < 0:
		velocity.x = jump_force[0]*50 * direction
	elif velocity.y > 0:
		velocity.x = jump_force[0]*30 * direction


# --- MISC ---

# -- GRAVITY --
func gravity(delta):
	var max_fall_speed = weight*50
	if not is_on_floor():
		# Fall
		## If reaches max fall speed, limit fall.
		if velocity.y >= max_fall_speed:
			pass
		## Regular gravity
		else:
			velocity.y += get_gravity().y * delta *  weight / 3
		# If falling
		if velocity.y > 0:
			ANIMATE.play('fall')
