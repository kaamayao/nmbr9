extends Spatial

var velocity = Vector3()
var tokens = []
var spawning_position = Vector3(0,18,0)
var current_token_index = 0
var gravity_is_active = false
var gravity = -60
var token_collision = null
var current_token = null
var grid_movement_velocity = 2

func _ready():
	randomize()
	tokens = self.get_children()
	tokens.shuffle()
	tokens[0].global_transform.origin = spawning_position
	current_token = tokens[0]
	
func _physics_process(delta):
	if current_token != null:
		velocity = Vector3()
		get_input()
		move_by_gravity(delta)

func select_next_token():
	current_token = null
	current_token_index = current_token_index + 1
	if current_token_index < len(tokens):
		current_token = tokens[current_token_index]
		current_token.global_transform.origin = spawning_position
		gravity_is_active = false

func move_by_gravity(delta):
	if (gravity_is_active):
		velocity.y = gravity
		token_collision = current_token.move_and_collide(velocity * delta)
		if token_collision != null:
			select_next_token()
		
func get_input():
	if Input.is_action_just_pressed("ui_up"):
		velocity.x = grid_movement_velocity
	if Input.is_action_just_pressed("ui_down"):
		velocity.x = -grid_movement_velocity
	if Input.is_action_just_pressed("ui_right"):
		velocity.z = grid_movement_velocity
	if Input.is_action_just_pressed("ui_left"):
		velocity.z = -grid_movement_velocity
	if Input.is_action_just_pressed("ui_select"):
		gravity_is_active = true
	current_token.move_and_collide(velocity)
