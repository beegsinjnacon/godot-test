class_name Controller

extends Node3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const CAMERA_SPEED = 0.2
const MOBA_CAM_DIRECTION = Vector3(0, -60, 0)
var destination = Vector3(0,0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var child;

enum {FPS = 1, MOBA = 2}
var ControlScheme = MOBA

@onready var camera = $Camera
@onready var nodeToFollow = self

func _ready():
	var childscene = load("res://unit.tscn")
	child = childscene.instantiate()
	child.name = "aaaa"
	await get_parent().ready
	get_parent().add_child(child)
	switch_control_scheme(ControlScheme)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match ControlScheme:
		FPS:
			var input_dir = Input.get_vector("left", "right", "up", "down")
			child.direction = (child.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			#could move nodeToFollow var
			if not nodeToFollow == null:
				position = Vector3(child.position)
				camera.position = Vector3(nodeToFollow.position)
				camera.rotation = Vector3(nodeToFollow.rotation)
		MOBA:
			var cameraPos = nodeToFollow
			var mousePos = get_viewport().get_mouse_position()
			if mousePos.x < 5:
				cameraPos.global_translate(Vector3(-CAMERA_SPEED,0,0))
			if mousePos.x > (get_viewport().size.x - 5):
				cameraPos.global_translate(Vector3(CAMERA_SPEED,0,0))
			if mousePos.y == 0:
				cameraPos.global_translate(Vector3(0,0,-CAMERA_SPEED))
			if mousePos.y > (get_viewport().size.y - 5):
				cameraPos.global_translate(Vector3(0,0,CAMERA_SPEED))
			if not nodeToFollow == null:
				camera.position = Vector3(nodeToFollow.position)
				camera.rotation = Vector3(nodeToFollow.rotation)
				if Input.is_action_pressed("center camera"):
					position = Vector3(child.position)
			child.look_at(destination)
			var movement = -(destination - child.position).limit_length(1)
			child.direction = child.transform.basis * Vector3(movement.x, 0, movement.z)
			

func _unhandled_input(event):
	var cameraPos = nodeToFollow
	if Input.is_action_just_pressed("switch control scheme"):
		match ControlScheme:
			FPS:
				switch_control_scheme(MOBA)
			MOBA:
				switch_control_scheme(FPS)
	match ControlScheme:
		FPS:
			if event is InputEventMouseMotion:
				child.rotate_y(-event.relative.x * 0.005)
				child.vertical_look = child.vertical_look + -event.relative.y * 0.005
				child.vertical_look = clamp(child.vertical_look, -PI/2, PI/2)
				cameraPos.rotation = Vector3(child.vertical_look, child.rotation.y, 0)
		MOBA:
			if event is InputEventMouseButton:
				if Input.is_action_pressed("move to point"):
					var mouse_pos = get_viewport().get_mouse_position()
					var ray_length = 100
					var from = camera.project_ray_origin(mouse_pos)
					var to = from + camera.project_ray_normal(mouse_pos) * ray_length
					var space = get_world_3d().direct_space_state
					var ray_query = PhysicsRayQueryParameters3D.new()
					ray_query.from = from
					ray_query.to = to
					ray_query.collide_with_areas = true
					destination = space.intersect_ray(ray_query).get("position")
					print_debug(destination)
					print_debug(child.global_position)
					print_debug(child.global_position.move_toward(destination, 1).limit_length(1))
					

func switch_control_scheme(scheme):
	ControlScheme = scheme
	match scheme:
		FPS:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
			nodeToFollow = child.find_child("CameraFPS")
		MOBA:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED;
			nodeToFollow = child.find_child("CameraMOBA")
			position = Vector3(child.position)
			destination = child.position
	camera.position = Vector3(nodeToFollow.position)
	camera.global_rotation = Vector3(nodeToFollow.rotation)
	child.movementMode = ControlScheme
