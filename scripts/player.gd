extends CharacterBody3D
#player nodes
@onready var neck = $neck
@onready var head = $neck/head
@onready var floor_sensor = $floor_sensor
@onready var ceiling_sensor = $ceiling_sensor
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var camera = $neck/head/Camera3D
@onready var eyescast = $neck/head/Camera3D/eyescast
@onready var splode = $"../splode"
@onready var barrelcast = $neck/head/Camera3D/barrelcast
@onready var weapon_of_mass_destruction = $neck/head/Camera3D/weapon_of_mass_destruction
@onready var compass = $neck/head/Camera3D/compass
@onready var player = $"."
@onready var wall_run_sensor = $wall_run_sensor
@onready var splode_2 = $"../splode2"
@onready var wallrunsensor_2 = $wallrunsensor2
@onready var direction_thing = $"direction thing"
@onready var dird = $"direction thing/dird"



#speed variables
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 12.0
@export var crouching_speed = 3.0

#states
var standing = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var airborn = false
var wall_running = false
var not_even_touching_a_wall_smh = false

#slide vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO

#mouse sensitivity
@export var mouse_vertical = 0.1
@export var mouse_horizontal = 0.15

#the other ones
var lerp_speed = 10.0
var direction = Vector3.ZERO
var crouching_depth = -0.5
var temporary_camera_rotation = Vector3.ZERO #this is for the freelook thing
var temporary_camera_rotation_y_2 #this is for sliding
@export var free_look_tilt_amount = 3.0
@export var jump_velocity = 4.5
var extra_jumps = 1
var input_dir = Vector2.ZERO
var targeted_spot = Vector3.ZERO
var reload_time = 0
var wall_normal = get_wall_normal()
var wall_parallel = Vector3.ZERO
var temp_direction = 0.0
var jump_this_tick
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func fix_camera():
			temporary_camera_rotation = neck.global_rotation
			rotation.y = temporary_camera_rotation.y
			neck.rotation.y = 0.0

func _input(event):
	
	if event is InputEventMouseMotion:
		if free_looking or sliding:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_horizontal))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-120),deg_to_rad(120))
		else:
			if sliding:
				neck.rotate_y(deg_to_rad(-event.relative.x * mouse_horizontal))
				neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-120),deg_to_rad(120))
			rotate_y(deg_to_rad(-event.relative.x * mouse_horizontal))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_vertical))
		if !airborn:
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	if Input.is_action_just_released("free_look"):
		fix_camera()
#looking around ↑
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() or Input.is_action_just_pressed("ui_accept") and extra_jumps >= 1 or wall_running and Input.is_action_just_pressed("ui_accept"):
		jump_this_tick = true

func _physics_process(delta):

	input_dir = Input.get_vector("left", "right", "forward", "backward")
	splode_2.global_position = wallrunsensor_2.get_collision_point()
	wallrunsensor_2.target_position = wallrunsensor_2.get_collision_normal()
	
	if get_floor_normal()+get_wall_normal():
		direction_thing.look_at(get_floor_normal()+get_wall_normal())
	else:
		direction_thing.look_at(lerp(get_floor_normal()+get_wall_normal(),Vector3(0,-1,0),delta * 5))
	##targeted_spot = eyescast.get_collision_point()
	##barrelcast.look_at(targeted_spot)
	##weapon_of_mass_destruction.look_at(targeted_spot)
	##weapon_of_mass_destruction.rotation = (lerp(weapon_of_mass_destruction.rotation,head.rotation, delta * 20))
	##weapon_of_mass_destruction.global_rotation = (lerp(weapon_of_mass_destruction.global_rotation,rotation, delta * 20))
	
	if reload_time < 60:
		reload_time = reload_time + 1

	compass.look_at(direction + compass.global_position)
	weapon_of_mass_destruction.look_at(weapon_of_mass_destruction.global_position + head.global_rotation)
	if is_on_floor() or wall_running:
		extra_jumps = 1

	if Input.is_action_pressed("shoot") and reload_time > 59:
		splode.position = barrelcast.get_collision_point()
		reload_time = reload_time - 60
	
	if Input.is_action_pressed("aim"):
		barrelcast.position.x = lerp(barrelcast.position.x,0.0,delta*lerp_speed)
		barrelcast.position.y = lerp(barrelcast.position.y,-0.3,delta*lerp_speed)
		weapon_of_mass_destruction.position.x = lerp(weapon_of_mass_destruction.position.x,0.0,delta*lerp_speed)
		weapon_of_mass_destruction.position.y = lerp(weapon_of_mass_destruction.position.y,-0.3,delta*lerp_speed)
	else:
		barrelcast.position.x = lerp(barrelcast.position.x,0.4,delta*lerp_speed)
		barrelcast.position.y = lerp(barrelcast.position.y,-0.6,delta*lerp_speed)
		weapon_of_mass_destruction.position.x = lerp(weapon_of_mass_destruction.position.x,0.4,delta*lerp_speed)
		weapon_of_mass_destruction.position.y = lerp(weapon_of_mass_destruction.position.y,-0.6,delta*lerp_speed)
	
	
	if Input.is_action_pressed("crouch") and is_on_floor() or ceiling_sensor.is_colliding() and is_on_floor():
		if sprinting and input_dir != Vector2.ZERO and !sliding:
			slide_timer = slide_timer_max
			slide_vector = Vector2(input_dir.x,input_dir.y)
			crouching = false
			standing = false
			sliding = true
			airborn = false
			print('started slide')
			#slide begin logic ↑
		else:
			current_speed = crouching_speed
			head.position.y = lerp(head.position.y,crouching_depth,delta*lerp_speed)
			standing_collision_shape.disabled = true
			crouching = true
			sprinting = false
			sliding = false
			airborn = false
			#crouching ↑
	elif Input.is_action_pressed("sprint")and is_on_floor():
		crouching = false
		standing = false
		sprinting = true
		sliding = false
		airborn = false
		wall_running = false
		current_speed = sprinting_speed
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
		#sprinting ↑
	elif is_on_floor():
		crouching = false
		standing = true
		sprinting = false
		sliding = false
		airborn = false
		wall_running = false
		current_speed = walking_speed
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
		#standing ↑
	else:
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
		crouching = false
		standing = false
		sprinting = false
		sliding = false
		airborn = true
		wall_running = false
		not_even_touching_a_wall_smh = true
		#airborn ↑
	if jump_this_tick:
		if wall_running:
			velocity.y = jump_velocity
			direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			wall_running = false
		else:
			velocity.y = jump_velocity
			if airborn and !wall_running:
				extra_jumps = extra_jumps -1
			direction = lerp(direction,transform.basis * Vector3(input_dir.x, 0, input_dir.y),delta * 30)
		jump_this_tick = false
	
			
	#handle free looking
	if Input.is_action_pressed("free_look"):
		free_looking = true
		camera.rotation.z = deg_to_rad(neck.rotation.y*free_look_tilt_amount)
	else:
		free_looking = false
		camera.rotation.z = lerp(camera.rotation.z,0.0,lerp_speed*delta)
	#handle sliding
	if sliding:
		slide_timer -= delta
		
		lerp(rotation.y,neck.rotation.y,lerp_speed*delta)
		current_speed = slide_timer * 15
		if slide_timer <= 0:
			sliding = false
			print('ended slide')
			fix_camera()
		current_speed = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		if wall_running:
			velocity.y -= gravity * delta / 3
		else:
			velocity.y -= gravity * delta

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		if sliding:
			direction = (transform.basis * Vector3(slide_vector.x,0.0,slide_vector.y)).normalized()
		else:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed/10)
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if sliding:
			velocity.x = direction.x * slide_timer
			velocity.z = direction.z * slide_timer
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)
		#velocity.y = move_toward(velocity.y, 0.0, current_speed)
	#print('free_looking = '+str(free_looking) +'. crouching = '+str(crouching) +'. sprinting = '+str(sprinting) +'. standing = '+str(standing) + '. airborn = '+str(airborn) + '. current_speed = '+str(current_speed) + '. extra_jumps = '+str(extra_jumps) + '. input_dir = '+str(input_dir))
	#print("velocity = "+str(velocity)+" is_on_wall = "+str(is_on_wall())+" wallrunning = "+str(wall_running)+" shapecast3d.collisionpoint = "+str(wallrunsensor_2.get_collision_point()))
	print(get_wall_normal()+get_floor_normal())
	move_and_slide()
