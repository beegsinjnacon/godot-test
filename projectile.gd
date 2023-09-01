class_name Projectile
extends CharacterBody3D

var speed: float = 15.0
var speed_multiplier: float = 1.0
var direction: Vector3 = Vector3(1,0,0)

var owning_unit: Unit

func conjure(conjurer: Unit):
	owning_unit = conjurer
	position = conjurer.position + Vector3(0, 1.5, 0)
	direction = conjurer.direction
	add_collision_exception_with(conjurer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity = speed * speed_multiplier * direction
	move_and_slide()
