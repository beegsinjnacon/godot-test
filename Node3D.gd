class_name Enemy
extends Unit

func _init():
	super._init()
	base_stats = {
	"physical_power" : 10,
	"ability_power" : 50,
	"max_health" : 69.0,
	"current_health" : 69.0,
	"armor" : 20.0,
	"magic_resist" : 20.0,
	"movement_speed" : 330.0,
	"attack_speed" : 1.0,
	"haste" : 0.0,
	"height" : 2.0,
	"width" : 1.0,
	}
