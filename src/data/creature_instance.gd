class_name CreatureInstance
extends RefCounted

var definition: CreatureDefinition
var nickname: String
var level: int
var current_hp: int


func _init(creature_definition: CreatureDefinition, creature_level: int, given_name := "") -> void:
	definition = creature_definition
	level = creature_level
	nickname = given_name if not given_name.is_empty() else definition.species_name
	current_hp = max_hp()


func max_hp() -> int:
	return definition.base_max_hp + level * 2


func is_fainted() -> bool:
	return current_hp <= 0


func receive_damage(amount: int) -> int:
	var previous := current_hp
	current_hp = maxi(0, current_hp - maxi(amount, 0))
	return previous - current_hp
