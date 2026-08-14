extends SceneTree

var failures := 0


func _init() -> void:
	var attacker := CreatureInstance.new(_definition(&"Plant", 13, 10), 5)
	var defender := CreatureInstance.new(_definition(&"Water", 10, 11), 4)
	var multiplier := BattleRules.effectiveness(&"Plant", &"Water")
	_expect(multiplier == 2.0, "Plant is effective against Water")
	_expect(BattleRules.effectiveness(&"Plant", &"Air") == 0.5, "Plant is resisted by Air")
	var dual_defender := _definition(&"Ghost", 10, 11)
	dual_defender.secondary_affinity = &"Bug"
	_expect(BattleRules.effectiveness_against(&"Plant", dual_defender) == 1.0, "dual affinities combine deterministically")
	_expect(dual_defender.affinity_label() == "Ghost / Bug", "dual affinities have a readable label")
	_expect(BattleRules.technique_damage(8, attacker, defender, multiplier) == 22, "damage is deterministic")
	_expect(defender.receive_damage(999) == defender.max_hp(), "damage cannot remove more than current HP")
	_expect(defender.current_hp == 0, "HP cannot fall below zero")
	if failures == 0:
		print("Battle rules tests passed.")
	quit(failures)


func _definition(affinity: StringName, attack: int, defense: int) -> CreatureDefinition:
	var result := CreatureDefinition.new()
	result.species_name = "Test"
	result.affinity = affinity
	result.base_max_hp = 30
	result.attack = attack
	result.defense = defense
	return result


func _expect(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
