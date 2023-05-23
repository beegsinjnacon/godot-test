extends CharacterBody3D

var movementMode

const SPEED = 8.0
#this is wierd, look at this later lmao
const ACCELERATION = 3
const JUMP_VELOCITY = 4.5

var vertical_look = 0
var direction = Vector3(0,0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	match movementMode:
		Controller.FPS:
			# Add the gravity.
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.x = move_toward(velocity.x, direction.x*SPEED, SPEED/ACCELERATION)
				velocity.z = move_toward(velocity.z, direction.z*SPEED, SPEED/ACCELERATION)

			# Handle Jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			#if direction:
			#	velocity.x = direction.x * SPEED
			#	velocity.z = direction.z * SPEED
			#else:
				
			move_and_slide()
		Controller.MOBA:
			print_debug(direction.length())
			# Add the gravity.
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.x = move_toward(velocity.x, direction.x*SPEED, SPEED/ACCELERATION)
				velocity.z = move_toward(velocity.z, direction.z*SPEED, SPEED/ACCELERATION)
			
			move_and_slide()
