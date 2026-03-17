extends CharacterBody2D

# --- VARIABLES ---
# -- Sprite Variables --
## Player Sprites
@onready var animation_player = $"Animation Player"
@onready var mocha_sprite = $"Mocha Sprite"
@onready var pieface_sprite = $"Pieface Sprite"
## Player Sprites Group
### Creates an array of each player form sprite
@onready var player_sprites_group_members = get_tree().get_nodes_in_group("Player Sprites")

# -- Collision Variables --
## Base Collision
@onready var player_collision = $"Player Collision"
## Player Base Collision Options
@onready var mocha_collision = $"Player Collision/Mocha Collision"
@onready var pieface_collision = $"Player Collision/Pieface Collision"

## Crawl Check
@onready var crawl_upper_check = $"Crawl Upper-Check"
@onready var crawl_lower_check = $"Crawl Lower-Check"

# Group of collisions that will be flipped on the x-axis
@onready var collisions_x_axis_flip = get_tree().get_nodes_in_group("Collision x-Axis Flip")

# -- Blank Variables --
## 
@onready var swappable = false
var crawling = false

## Player Form
var player_form = 'Mocha'

## Movement
var speed = 50
var jump_force = -50

func _ready() -> void:
	## Mocha Form
	# Attributes
	speed = 100
	jump_force = -300
	# Sprite
	mocha_sprite.visible = true
	pieface_sprite.visible = false
	# Collision
	player_collision.shape = mocha_collision.shape
	player_collision.transform = mocha_collision.transform

# --- PHYSICS LOOP ---
func _physics_process(delta: float) -> void:
	# Form
	formController()
	# Actions
	walk()
	jump()
	crawl()
	# External Forces
	gravity(delta)
	# Central function for velocity
	move_and_slide()

# --- FUNCTIONS ---

## -- FORM --
func formController():
	# --- SWAP FORM ---
	## Swap Player Form when SWAP action pressed
	if Input.is_action_just_pressed("SWAP"):
		if player_form == 'Mocha':
			player_form = 'Pieface'
		elif player_form == 'Pieface':
			player_form = 'Mocha'
		print("Form: ", player_form)
		# -- FORM TRAITS --
		## Mocha Form
		if player_form == 'Mocha':
			# Attributes
			speed = 100
			jump_force = -300
			# Sprite
			mocha_sprite.visible = true
			pieface_sprite.visible = false
			# Collision
			player_collision.shape = mocha_collision.shape
			player_collision.transform = mocha_collision.transform
			
		## Pieface Form
		elif player_form == 'Pieface':
			# Attributes
			speed = 200
			jump_force = -200
			# Sprite
			mocha_sprite.visible = false
			pieface_sprite.visible = true
			# Collision
			player_collision.shape = pieface_collision.shape
			player_collision.transform = pieface_collision.transform

## -- MOVEMENT --

# Walk and Turn
func walk():
	var direction := Input.get_axis("LEFT","RIGHT")
	if direction:
		velocity.x = direction * speed
		# Only play walk animation if not moving vertically
		if not velocity.y:
			animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		# Only play idle animation if not moving
		if not velocity:
			animation_player.play("idle")

# Turn Animation
## Turn each player sprite when direction goes to the left, and vice versa
	if direction > 0:
		for playerSprites in player_sprites_group_members:
			playerSprites.flip_h = false
		# Collision Flipping
		## Reset Collision x-axis
		crawl_upper_check.position.x = abs(crawl_upper_check.position.x)
		crawl_lower_check.position.x = abs(crawl_lower_check.position.x)
	elif direction < 0:
		#get_tree().set_group("Player Sprites","flip_h", true)
		for playerSprites in player_sprites_group_members:
			playerSprites.flip_h = true
		# Collision Flipping
		## Since collision is right-facing, flip when facing left
		crawl_upper_check.position.x = abs(crawl_upper_check.position.x) * -1
		crawl_lower_check.position.x = abs(crawl_lower_check.position.x) * -1

# Jump
func jump():
	# -- Jump Conditions --
	## If true, allows the player to jump
	var can_jump : bool
	## Has to be on the floor
	if not is_on_floor():
		can_jump = false
	## Cannot be crawling
	elif crawling:
		can_jump = false
	else:
		can_jump = true
	
	# -- Jump Action --
	if Input.is_action_just_pressed("JUMP") and can_jump:
		velocity.y = jump_force
		animation_player.play("jump")

# Crawl
func crawl():
	# If true, the crawl action can be performed
	var can_crawl : bool
	if not is_on_floor():
		can_crawl = false
	else:
		can_crawl = true
	# Crawl Check
	if crawl_upper_check.has_overlapping_bodies() and not crawl_lower_check.has_overlapping_bodies() and can_crawl:
		crawling = true
	elif crawl_upper_check.has_overlapping_bodies():
		crawling = true
	else:
		crawling = false
		
	
	# Swap collision to crawl
	if crawling:
		player_collision.transform = mocha_collision.transform / 2
		animation_player.play("crawl")

## -- EXTERNAL FORCES --
# Gravity
func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
