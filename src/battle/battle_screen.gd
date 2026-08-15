class_name BattleScreen
extends Control

signal battle_finished(player_won: bool)
signal treat_requested
signal creature_befriended(creature: CreatureInstance)

enum Phase { COMMAND, RESOLVING, FINISHED }

const AMPUST: CreatureDefinition = preload("res://src/data/creatures/ampust.tres")
const SRMIMILGHEL: CreatureDefinition = preload("res://src/data/creatures/srmimilghel.tres")
const CREAM := Color("#f0e2bd")
const GREEN := Color("#1d5948")
const TEAL := Color("#123f38")
const BRASS := Color("#d2a44f")
const INK := Color("#202c27")

var player_creature := CreatureInstance.new(AMPUST, 5, "Ampust")
var enemy_creature: CreatureInstance
var phase := Phase.COMMAND
var guarded := false
var enemy_behavior := "curious"
var _befriended := false

var player_name_label: Label
var player_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_name_label: Label
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var message_label: Label
var command_grid: GridContainer
var creature_texture: TextureRect
var enemy_texture: TextureRect


func _ready() -> void:
	_build_interface()
	hide()


func start_battle(enemy_name: String, enemy_behavior: String) -> void:
	var definition := _enemy_definition(enemy_name, enemy_behavior)
	enemy_creature = CreatureInstance.new(definition, 4)
	enemy_texture.texture = definition.battle_texture
	self.enemy_behavior = enemy_behavior
	_befriended = false
	phase = Phase.COMMAND
	guarded = false
	_update_hud()
	message_label.text = "A wild %s watches your next move." % enemy_name
	command_grid.show()
	show()
	_focus_first_command()


func _build_interface() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("#102a25")
	add_child(backdrop)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	var arena := PanelContainer.new()
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.add_theme_stylebox_override("panel", _style(Color("#376c55"), BRASS, 3, 14))
	page.add_child(arena)
	var field := Control.new()
	field.custom_minimum_size.y = 320
	arena.add_child(field)
	creature_texture = TextureRect.new()
	creature_texture.position = Vector2(35, 5)
	creature_texture.size = Vector2(430, 310)
	creature_texture.texture = AMPUST.battle_texture
	creature_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creature_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	field.add_child(creature_texture)
	enemy_texture = TextureRect.new()
	enemy_texture.position = Vector2(820, 140)
	enemy_texture.size = Vector2(220, 145)
	enemy_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	enemy_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	enemy_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	field.add_child(enemy_texture)

	var enemy_card := _make_status_card(true)
	enemy_card.position = Vector2(710, 38)
	enemy_card.size = Vector2(450, 116)
	field.add_child(enemy_card)
	var player_card := _make_status_card(false)
	player_card.position = Vector2(630, 195)
	player_card.size = Vector2(520, 116)
	field.add_child(player_card)

	var dialogue_panel := PanelContainer.new()
	dialogue_panel.custom_minimum_size.y = 82
	dialogue_panel.add_theme_stylebox_override("panel", _style(Color("#080b0a"), CREAM, 3, 0))
	page.add_child(dialogue_panel)
	message_label = Label.new()
	message_label.text = "* Battle narration appears here."
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", CREAM)
	message_label.add_theme_font_size_override("font_size", 20)
	dialogue_panel.add_child(message_label)

	command_grid = GridContainer.new()
	command_grid.columns = 2
	command_grid.add_theme_constant_override("h_separation", 12)
	command_grid.add_theme_constant_override("v_separation", 10)
	page.add_child(command_grid)
	_add_command("WRAITH POUNCE", 11, &"Ghost", false)
	_add_command("LOCUST RASP", 8, &"Bug", false)
	_add_command("TOMB DUST", 10, &"Ghost", false)
	_add_command("SHED HUSK · INSTINCT", 0, &"Bug", true)
	_add_special_command("OFFER MOSS BISCUIT", _on_offer_treat)
	_add_special_command("WITHDRAW", _on_withdraw)


func _make_status_card(enemy: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(CREAM, BRASS, 3, 10))
	var column := VBoxContainer.new()
	panel.add_child(column)
	var name_label := Label.new()
	name_label.add_theme_color_override("font_color", INK)
	name_label.add_theme_font_size_override("font_size", 20)
	column.add_child(name_label)
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 24
	bar.show_percentage = false
	column.add_child(bar)
	var hp_label := Label.new()
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hp_label.add_theme_color_override("font_color", INK)
	column.add_child(hp_label)
	if enemy:
		enemy_name_label = name_label
		enemy_hp_bar = bar
		enemy_hp_label = hp_label
	else:
		player_name_label = name_label
		player_hp_bar = bar
		player_hp_label = hp_label
	return panel


func _add_command(label: String, power: int, affinity: StringName, instinct: bool) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = label
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_stylebox_override("normal", _style(TEAL, BRASS, 2, 9))
	button.add_theme_stylebox_override("hover", _style(GREEN, CREAM, 3, 9))
	button.add_theme_stylebox_override("focus", _style(GREEN, CREAM, 4, 9))
	button.pressed.connect(_on_command.bind(label, power, affinity, instinct))
	command_grid.add_child(button)


func _add_special_command(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = label
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_stylebox_override("normal", _style(Color("#4a2c23"), BRASS, 2, 9))
	button.add_theme_stylebox_override("hover", _style(GREEN, CREAM, 3, 9))
	button.add_theme_stylebox_override("focus", _style(GREEN, CREAM, 4, 9))
	button.pressed.connect(callback)
	command_grid.add_child(button)


func _on_command(label: String, power: int, affinity: StringName, instinct: bool) -> void:
	if phase != Phase.COMMAND:
		return
	phase = Phase.RESOLVING
	_set_commands_disabled(true)
	guarded = instinct
	if instinct:
		message_label.text = "* %s leaves a spectral husk to soften the next blow!" % player_creature.nickname
	else:
		var multiplier := BattleRules.effectiveness_against(affinity, enemy_creature.definition)
		var damage := BattleRules.technique_damage(power, player_creature, enemy_creature, multiplier)
		enemy_creature.receive_damage(damage)
		message_label.text = "* %s used %s for %d damage%s" % [player_creature.nickname, label, damage, " — effective!" if multiplier > 1.0 else "."]
	_update_hud()
	if enemy_creature.is_fainted():
		_finish_battle(true)
		return
	await get_tree().create_timer(0.8).timeout
	_resolve_enemy_turn()


func _resolve_enemy_turn() -> void:
	var power := 9
	var damage := BattleRules.technique_damage(power, enemy_creature, player_creature)
	if guarded:
		damage = maxi(1, ceili(float(damage) * 0.4))
	player_creature.receive_damage(damage)
	message_label.text = "* %s struck back for %d damage%s" % [
		enemy_creature.nickname,
		damage,
		" — Brace softened the blow." if guarded else ".",
	]
	_update_hud()
	if player_creature.is_fainted():
		_finish_battle(false)
		return
	guarded = false
	await get_tree().create_timer(0.8).timeout
	phase = Phase.COMMAND
	message_label.text = "* What will %s do?" % player_creature.nickname
	_set_commands_disabled(false)
	_focus_first_command()


func _on_offer_treat() -> void:
	if phase != Phase.COMMAND:
		return
	phase = Phase.RESOLVING
	_set_commands_disabled(true)
	message_label.text = "* You offer the wild %s a moss biscuit..." % enemy_creature.nickname
	treat_requested.emit()


func resolve_treat_offer(had_treat: bool) -> void:
	if phase != Phase.RESOLVING:
		return
	if not had_treat:
		message_label.text = "* Your treat pocket is empty."
		await get_tree().create_timer(0.8).timeout
		_return_to_commands()
		return
	var hp_ratio := float(enemy_creature.current_hp) / float(enemy_creature.max_hp())
	var succeeds := enemy_behavior == "curious"
	if enemy_behavior == "wary":
		succeeds = hp_ratio <= 0.7
	elif enemy_behavior == "aggressive":
		succeeds = hp_ratio <= 0.4
	if succeeds:
		_befriended = true
		message_label.text = "* %s accepts the food and chooses to travel with you!" % enemy_creature.nickname
		creature_befriended.emit(enemy_creature)
		_finish_battle(true)
		return
	message_label.text = "* %s eats, but still keeps its distance." % enemy_creature.nickname
	await get_tree().create_timer(0.9).timeout
	_resolve_enemy_turn()


func _on_withdraw() -> void:
	if phase != Phase.COMMAND:
		return
	phase = Phase.FINISHED
	command_grid.hide()
	message_label.text = "* You give the wild Nokomon space and withdraw."
	await get_tree().create_timer(1.0).timeout
	hide()
	battle_finished.emit(false)


func _return_to_commands() -> void:
	phase = Phase.COMMAND
	_set_commands_disabled(false)
	message_label.text = "* What will %s do?" % player_creature.nickname
	_focus_first_command()


func _finish_battle(player_won: bool) -> void:
	phase = Phase.FINISHED
	command_grid.hide()
	if not _befriended:
		message_label.text = "* %s" % ("Ampust prevailed! The wild Nokomon withdraws." if player_won else "Ampust can no longer battle. Return to the clinic.")
	await get_tree().create_timer(1.5).timeout
	hide()
	battle_finished.emit(player_won)


func _set_commands_disabled(disabled: bool) -> void:
	for child in command_grid.get_children():
		(child as Button).disabled = disabled


func _update_hud() -> void:
	player_name_label.text = "%s · Lv.%d · %s" % [player_creature.nickname, player_creature.level, player_creature.definition.affinity_label()]
	player_hp_bar.max_value = player_creature.max_hp()
	player_hp_bar.value = player_creature.current_hp
	player_hp_label.text = "%d / %d HP" % [player_creature.current_hp, player_creature.max_hp()]
	enemy_name_label.text = "%s · Lv.%d · %s" % [enemy_creature.nickname, enemy_creature.level, enemy_creature.definition.affinity_label()]
	enemy_hp_bar.max_value = enemy_creature.max_hp()
	enemy_hp_bar.value = enemy_creature.current_hp
	enemy_hp_label.text = "%d / %d HP" % [enemy_creature.current_hp, enemy_creature.max_hp()]


func _enemy_definition(enemy_name: String, behavior: String) -> CreatureDefinition:
	if enemy_name == SRMIMILGHEL.species_name:
		return SRMIMILGHEL
	var definition := CreatureDefinition.new()
	definition.id = StringName(enemy_name.to_snake_case())
	definition.species_name = enemy_name
	definition.affinity = &"Fire" if enemy_name == "Cindervole" else (&"Ghost" if enemy_name == "Gloamoth" else &"Plant")
	definition.base_max_hp = 28
	definition.attack = 10 if behavior != "aggressive" else 13
	definition.defense = 9
	definition.speed = 8
	return definition


func _focus_first_command() -> void:
	if command_grid.get_child_count() > 0:
		(command_grid.get_child(0) as Button).grab_focus()


func _style(color: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(12)
	return style
