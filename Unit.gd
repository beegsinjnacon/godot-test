class_name Unit
extends CharacterBody3D

var movement_mode

#this is weird, look at this later lmao
var ACCELERATION = 3.0
var JUMP_VELOCITY = 4.5

@export
var base_stats: Dictionary = {
	"physical_power" : 20,
	"ability_power" : 20,
	"max_health" : 420.0,
	"current_health" : 69.0,
	"armor" : 20.0,
	"magic_resist" : 20.0,
	"movement_speed" : 330.0,
	"attack_speed" : 1.0,
	"haste" : 0.0,
	"height" : 2.0,
	"width" : 1.0,
}
@export
var statuses: Dictionary = {}
@export
var ticked_statuses: Dictionary = {}
var struggle = load("res://moves/struggle.gd").new(self)
@export
var moves: Dictionary = {
	"primary" : struggle,
	"secondary" : struggle,
	"utility" : struggle,
	"mobility" : struggle,
	"ultimate" : struggle,
}

var vertical_look: float = 0
var direction: Vector3 = Vector3(0,0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in moves:
		moves[i].tick(delta)

func _physics_process(delta):
	var ms = base_stats.get("movement_speed")/40
	match movement_mode:
		Controller.FPS:
			# Add the gravity.
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.x = move_toward(velocity.x, direction.x*ms, ms/ACCELERATION)
				velocity.z = move_toward(velocity.z, direction.z*ms, ms/ACCELERATION)

			# Handle Jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			#if direction:
			#	velocity.x = direction.x * SPEED
			#	velocity.z = direction.z * SPEED
			#else:
				
			move_and_slide()
		Controller.MOBA:
			#print_debug(direction.length())
			# Add the gravity.
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.x = move_toward(velocity.x, direction.x*ms, ms/ACCELERATION)
				velocity.z = move_toward(velocity.z, direction.z*ms, ms/ACCELERATION)
			
			move_and_slide()
