class_name Controller
extends Node3D

var hud_visible = false;

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const CAMERA_SPEED = 0.2
const MOBA_CAM_DIRECTION = Vector3(0, -60, 0)
var destination: Vector3 = Vector3(0,0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var child: Unit;

enum {FPS = 1, MOBA = 2}
var control_scheme = MOBA
var unit_scene = load("res://characters/example/example.tscn")
#var enemy_scene = load("res://enemy.tscn")

var character_scene
var summon_scene

@onready var camera = $Camera
@onready var node_to_follow = self

var primary_button: TextureButton
var secondary_button: TextureButton
var utility_button: TextureButton
var mobility_button: TextureButton
var ultimate_button: TextureButton

var health_bar: ProgressBar

func _ready():
	set_process(false)
	#camera = Camera3D.new()
	#camera.name = "camera"
	#add_child(camera)
	
	child = character_scene.instantiate()
	child.name = "aaaa"
	#await get_parent().ready
	get_parent().add_child(child)
	#await child.ready
	switch_control_scheme(control_scheme)
	
	primary_button = $HUD/PanelContainer/VSplitContainer/Abilities/PrimaryButton
	primary_button.set_texture_normal(child.moves.primary.texture)
	secondary_button = $HUD/PanelContainer/VSplitContainer/Abilities/SecondaryButton
	secondary_button.set_texture_normal(child.moves.secondary.texture)
	utility_button = $HUD/PanelContainer/VSplitContainer/Abilities/UtilityButton
	utility_button.set_texture_normal(child.moves.utility.texture)
	mobility_button = $HUD/PanelContainer/VSplitContainer/Abilities/MobilityButton
	mobility_button.set_texture_normal(child.moves.mobility.texture)
	ultimate_button = $HUD/PanelContainer/VSplitContainer/Abilities/UltimateButton
	ultimate_button.set_texture_normal(child.moves.ultimate.texture)
	
	health_bar = $HUD/PanelContainer/VSplitContainer/HealthBar
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	health_bar.max_value = child.base_stats.max_health
	health_bar.value = child.base_stats.current_health
	match control_scheme:
		FPS:
			var input_dir = Input.get_vector("left", "right", "up", "down")
			child.direction = (child.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			#could move node_to_follow var
			if not node_to_follow == null:
				position = Vector3(child.position)
				camera.position = Vector3(node_to_follow.position)
				camera.rotation = Vector3(node_to_follow.rotation)
		MOBA:
			var camera_pos = node_to_follow
			var mouse_pos = get_viewport().get_mouse_position()
			if mouse_pos.x < 5:
				camera_pos.global_translate(Vector3(-CAMERA_SPEED,0,0))
			if mouse_pos.x > (get_viewport().size.x - 5):
				camera_pos.global_translate(Vector3(CAMERA_SPEED,0,0))
			if mouse_pos.y == 0:
				camera_pos.global_translate(Vector3(0,0,-CAMERA_SPEED))
			if mouse_pos.y > (get_viewport().size.y - 5):
				camera_pos.global_translate(Vector3(0,0,CAMERA_SPEED))
			if not node_to_follow == null:
				camera.position = Vector3(node_to_follow.position)
				camera.rotation = Vector3(node_to_follow.rotation)
				if Input.is_action_pressed("center camera"):
					position = Vector3(child.position)
			if child.position.distance_to(destination)>0.5:
				child.look_at(destination)
			var movement = -(destination - child.position).limit_length(1)
			child.direction = child.transform.basis * Vector3(movement.x, 0, movement.z)
			

func move_on_input(move: String, input: String):
	if Input.is_action_just_pressed(input):
			child.moves[move].use(false)
	else:
		if Input.is_action_pressed(input):
			child.moves[move].use(true)

func _unhandled_input(event):
	var camera_pos = node_to_follow
	
	match control_scheme:
		FPS:
			move_on_input("primary", "fps primary")
			move_on_input("secondary", "fps secondary")
			move_on_input("utility", "fps utility")
			move_on_input("mobility", "fps mobility")
			move_on_input("ultimate", "fps ultimate")
		MOBA:
			move_on_input("primary", "moba primary")
			move_on_input("secondary", "moba secondary")
			move_on_input("utility", "moba utility")
			move_on_input("mobility", "moba mobility")
			move_on_input("ultimate", "moba ultimate")
	
	#spawn thing
	if Input.is_action_pressed("spawn"):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.collide_with_areas = true
		var spawn_pos = space.intersect_ray(ray_query).get("position")
		var thing: Node3D = summon_scene.instantiate()
		thing.position = spawn_pos
		get_parent().add_child(thing)
	
	#toggle moba/fps
	if Input.is_action_just_pressed("switch control scheme"):
		match control_scheme:
			FPS:
				switch_control_scheme(MOBA)
			MOBA:
				switch_control_scheme(FPS)
	
	#control movement based on control scheme
	match control_scheme:
		FPS:
			if event is InputEventMouseMotion:
				child.rotate_y(-event.relative.x * 0.005)
				child.vertical_look = child.vertical_look + -event.relative.y * 0.005
				child.vertical_look = clamp(child.vertical_look, -PI/2, PI/2)
				camera_pos.rotation = Vector3(child.vertical_look, child.rotation.y, 0)
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
					child.look_at(destination)
					print_debug(destination)
					print_debug(child.global_position)
					print_debug(child.global_position.move_toward(destination, 1).limit_length(1))
					

func switch_control_scheme(scheme):
	control_scheme = scheme
	match scheme:
		FPS:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
			node_to_follow = child.find_child("CameraFPS")
		MOBA:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED;
			node_to_follow = child.find_child("CameraMOBA")
			position = Vector3(child.position)
			destination = child.position
	camera.position = Vector3(node_to_follow.position)
	camera.global_rotation = Vector3(node_to_follow.rotation)
	child.movement_mode = control_scheme

func set_hud_visible(visible):
	hud_visible = visible
	if(hud_visible):
		$HUD.show();
	else:
		$HUD.hide();
