class_name CreatureDefinition
extends Resource

@export var id: StringName
@export var species_name: String
@export var affinity: StringName
@export var secondary_affinity: StringName
@export var base_max_hp := 40
@export var attack := 12
@export var defense := 10
@export var speed := 10
@export var battle_texture: Texture2D


func affinity_label() -> String:
	if secondary_affinity.is_empty():
		return affinity
	return "%s / %s" % [affinity, secondary_affinity]


func affinities() -> Array[StringName]:
	var result: Array[StringName] = [affinity]
	if not secondary_affinity.is_empty():
		result.append(secondary_affinity)
	return result
