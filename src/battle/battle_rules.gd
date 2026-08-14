class_name BattleRules
extends RefCounted


static func technique_damage(power: int, attacker: CreatureInstance, defender: CreatureInstance, multiplier := 1.0) -> int:
	var scaled_attack := attacker.definition.attack + attacker.level
	var scaled_defense := defender.definition.defense + defender.level
	var base := maxi(1, power + scaled_attack - scaled_defense)
	return maxi(1, roundi(float(base) * multiplier))


static func effectiveness(attack_affinity: StringName, defense_affinity: StringName) -> float:
	if attack_affinity == &"Plant" and defense_affinity in [&"Water", &"Earth"]:
		return 2.0
	if attack_affinity == &"Plant" and defense_affinity in [&"Electric", &"Air"]:
		return 0.5
	if attack_affinity == &"Earth" and defense_affinity in [&"Electric", &"Poison", &"Mystic"]:
		return 2.0
	return 1.0


static func effectiveness_against(attack_affinity: StringName, defender: CreatureDefinition) -> float:
	var result := 1.0
	for defense_affinity in defender.affinities():
		result *= effectiveness(attack_affinity, defense_affinity)
	return result
