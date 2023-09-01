class_name Example
extends Unit

const asset_loc = "res://characters/example/moves/"

var shoot = preload(asset_loc+"shoot.gd")
var pointfiveoh = preload(asset_loc+"pointfiveoh.gd")
var spray = preload(asset_loc+"spray.gd")
var grenade = preload(asset_loc+"grenade.gd")
var rush = preload(asset_loc+"rush.gd")

func _init():
	base_stats = {
	"physical_power" : 10,
	"ability_power" : 50,
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
	moves.primary = shoot.new(self)
	moves.secondary = pointfiveoh.new(self)
	moves.utility = spray.new(self)
	moves.mobility = grenade.new(self)
	moves.ultimate = rush.new(self)

