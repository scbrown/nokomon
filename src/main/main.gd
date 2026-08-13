class_name Main
extends Node

@onready var world: ExplorationWorld = $ExplorationWorld
@onready var inventory: InventoryScreen = $Interface/InventoryScreen
@onready var battle: BattleScreen = $Interface/BattleScreen
@onready var prompt: Label = $Interface/Hud/Prompt
@onready var notice: Label = $Interface/Hud/Notice

var _known_companions: Array[CreatureInstance] = []


func _ready() -> void:
	if not OS.has_feature("web"):
		get_viewport().get_window().min_size = Vector2i(640, 360)
	inventory.hide()
	battle.battle_finished.connect(_on_battle_finished)
	battle.treat_requested.connect(_on_treat_requested)
	battle.creature_befriended.connect(_on_creature_befriended)
	_known_companions.append(battle.player_creature)
	inventory.close_requested.connect(_close_inventory)
	inventory.item_action_requested.connect(_on_item_action_requested)
	world.encounter_requested.connect(_on_encounter_requested)
	prompt.text = "WASD / LEFT STICK  MOVE    F / A  INTERACT    TAB / Y  SATCHEL"
	notice.text = "Explore Brassleaf and approach a visible Nokomon."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory") and not battle.visible:
		if inventory.visible:
			_close_inventory()
		else:
			_open_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and not inventory.visible and not battle.visible:
		if not world.try_interact():
			notice.text = "There is nothing close enough to interact with."


func _open_inventory() -> void:
	inventory.show()
	world.set_player_input_enabled(false)


func _close_inventory() -> void:
	inventory.hide()
	world.set_player_input_enabled(true)
	notice.text = "Satchel closed."


func _on_encounter_requested(creature_name: String, behavior: String) -> void:
	world.set_player_input_enabled(false)
	$Interface/Hud.hide()
	battle.start_battle(creature_name, behavior)


func _on_battle_finished(player_won: bool) -> void:
	world.set_player_input_enabled(true)
	$Interface/Hud.show()
	if battle.player_creature.is_fainted():
		notice.text = "Bramblet needs care at the clinic."
	elif player_won:
		notice.text = "Encounter resolved. Companions: %d." % _known_companions.size()
	else:
		notice.text = "You withdrew safely."


func _on_treat_requested() -> void:
	var consumed := inventory.consume_item(&"moss_biscuit")
	battle.resolve_treat_offer(consumed)


func _on_creature_befriended(creature: CreatureInstance) -> void:
	if _known_companions.size() >= 6:
		return
	_known_companions.append(creature)


func _on_item_action_requested(item_id: StringName) -> void:
	notice.text = "Used inventory hook: %s" % item_id
