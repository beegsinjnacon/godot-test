class_name Move

#@warning_ignore("unused_private_class_variable")
#var _texture

var caster: Unit

@export
var base_cooldown = 3.0
@export
var current_cooldown = 0.0
@export
var cooling = false

@export
var max_charges = 1
@export
var current_charges = 1

var rank = 0

## used to account for tick delta not necessarily being consistent. could be buggy, prob wont be imo
## only used in a couple cases anyway (continuous abilities and buffering)
var excess_delta = 0

func _init(user, level: int = 0):
	caster = user
	rank = level

func use(buffered = false):
	if current_charges > 0:
		cool(get_reduced_cooldown(), buffered)
		current_charges -= 1
		return true
	return false

func get_reduced_cooldown():
	return base_cooldown * (100/(100+caster.base_stats.haste))

## puts this ability on cooldown for the specified duration
func cool(cooldown, buffered = false):
	current_cooldown += cooldown
	if(buffered):
		current_cooldown = 0 if excess_delta > current_cooldown else current_cooldown - excess_delta
	else:
		excess_delta = 0
	if current_cooldown > 0:
		cooling = true

func rank_up():
	rank += 1

## called every tick.
## should either implement its own cooling or call this super method.
func tick(delta):
	if(cooling):
		if(current_cooldown>delta):
			current_cooldown -= delta
			return
		else:
			excess_delta = delta - current_cooldown
			current_cooldown = 0
			current_charges += 1
			if current_charges==max_charges:
				cooling = false
			else:
				cool(get_reduced_cooldown())
