extends Spatial

export var score = 0
var current_token = null
var current_raycasts = []
var current_rotation = 0
var current_token_index = 0
var spawning_position = Vector3(0,18,0)
var tokens = []
var token_rotation = 0
var token_collision = null
var gravity_is_active = false
var gravity = -60
var grid_movement_velocity = 2
var velocity = Vector3()
var disable_input = false
var valid_movement = true
var glow_valid = null
var glow_invalid = null
var label = null

func _ready():
	randomize()
	tokens = self.get_children()
	tokens.shuffle()
	tokens[0].global_transform.origin = spawning_position
	current_token = tokens[0]
	set_ray_cast_current()
	set_current_glow_meshes()

func _physics_process(delta):
	if current_token == null:
		return
	velocity = Vector3()
	token_rotation = 0
	if not disable_input:
		get_input()
	check_ray_cast()
	move_by_gravity(delta)

func set_current_glow_meshes():
	for child in current_token.get_children():
		if child.get_name() == 'glow_valid':
			glow_valid = child
		if child.get_name() == 'glow_invalid':
			glow_invalid = child
	
func set_ray_cast_current():
	current_raycasts = []
	for child in current_token.get_children():
		if child.get_class() == 'RayCast':
			current_raycasts.append(child)

func check_ray_cast():
	var valid_same_overlapping = false
	var floor_first_token = current_raycasts[0].get_collider().current_floor;
	var valid_movement_floor = true
	
	for raycast in current_raycasts:
		if floor_first_token != raycast.get_collider().current_floor:
			valid_movement_floor = false
			break
		if raycast.get_collider().nmbr != current_token.nmbr:
			valid_same_overlapping = true
	valid_movement = valid_same_overlapping and valid_movement_floor 
	set_visible_glow()

func set_visible_glow():
	if valid_movement: 
		glow_valid.visible = true
		glow_invalid.visible = false
		return
	glow_valid.visible = false
	glow_invalid.visible = true

func select_next_token():
	current_token = null
	current_token_index = current_token_index + 1
	if current_token_index < len(tokens):
		current_token = tokens[current_token_index]
		current_token.current_floor = current_raycasts[0].get_collider().current_floor
		current_token.global_transform.origin = spawning_position
		gravity_is_active = false
		set_ray_cast_current()
		set_current_glow_meshes()

func move_by_gravity(delta):
	if not gravity_is_active:
		return
	velocity.y = gravity
	token_collision = current_token.move_and_collide(velocity * delta)
	if token_collision != null:
		disable_input = false
		set_current_token_properties()
		calc_score()
		select_next_token()

func calc_score():
	var n_score = current_token.nmbr * (current_token.current_floor - 1)
	score += n_score

func set_current_token_properties():
	current_token.current_floor = current_raycasts[0].get_collider().current_floor + 1

func rotate_token(direction):
	current_rotation = int(fposmod(current_rotation + (direction * 90), 360))
	token_rotation = direction * 1.5708
	if current_rotation == 90 or current_rotation == 180:
		velocity.x = 1
		velocity.z = 1
	else:
		velocity.x = -1
		velocity.z = -1

func select_action():
	check_ray_cast()
	if valid_movement:
		gravity_is_active = true
		disable_input = true

func get_input():
	if Input.is_action_just_pressed("ui_up"):
		velocity.x = grid_movement_velocity
	if Input.is_action_just_pressed("ui_down"):
		velocity.x = -grid_movement_velocity
	if Input.is_action_just_pressed("ui_right"):
		velocity.z = grid_movement_velocity
	if Input.is_action_just_pressed("ui_left"):
		velocity.z = -grid_movement_velocity
	if Input.is_action_just_pressed("ui_a"):
		rotate_token(1)
	if Input.is_action_just_pressed("ui_y"):
		rotate_token(-1)
	if Input.is_action_just_pressed("ui_select"):
		select_action()
	current_token.move_and_collide(velocity)
	current_token.rotate_y(token_rotation)
