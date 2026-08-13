class_name BattleScreen
extends Control

signal battle_finished(player_won: bool)

enum Phase { COMMAND, DODGE, FINISHED }

const BRAMBLET: CreatureDefinition = preload("res://src/data/creatures/bramblet.tres")
const CREAM := Color("#f0e2bd")
const GREEN := Color("#1d5948")
const TEAL := Color("#123f38")
const BRASS := Color("#d2a44f")
const INK := Color("#202c27")

var player_creature := CreatureInstance.new(BRAMBLET, 5, "Bramblet")
var enemy_creature: CreatureInstance
var phase := Phase.COMMAND
var guarded := false
var _dodge_time := 0.0
var _spawn_time := 0.0
var _hazards: Array[ColorRect] = []

var player_name_label: Label
var player_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_name_label: Label
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var message_label: Label
var command_grid: GridContainer
var dodge_box: Control
var guard_marker: ColorRect
var creature_texture: TextureRect


func _ready() -> void:
	_build_interface()
	hide()
	set_process(false)


func start_battle(enemy_name: String, enemy_behavior: String) -> void:
	var definition := CreatureDefinition.new()
	definition.id = StringName(enemy_name.to_snake_case())
	definition.species_name = enemy_name
	definition.affinity = _enemy_affinity(enemy_name)
	definition.base_max_hp = 28
	definition.attack = 10 if enemy_behavior != "aggressive" else 13
	definition.defense = 9
	definition.speed = 8
	enemy_creature = CreatureInstance.new(definition, 4)
	phase = Phase.COMMAND
	guarded = false
	_update_hud()
	message_label.text = "A wild %s watches your next move." % enemy_name
	command_grid.show()
	dodge_box.hide()
	show()
	set_process(true)
	_focus_first_command()


func _process(delta: float) -> void:
	if phase != Phase.DODGE:
		return
	_dodge_time -= delta
	_spawn_time -= delta
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	guard_marker.position += movement * 250.0 * delta
	guard_marker.position.x = clampf(guard_marker.position.x, 4.0, dodge_box.size.x - guard_marker.size.x - 4.0)
	guard_marker.position.y = clampf(guard_marker.position.y, 4.0, dodge_box.size.y - guard_marker.size.y - 4.0)
	if _spawn_time <= 0.0:
		_spawn_hazard()
		_spawn_time = 0.34
	for hazard in _hazards.duplicate():
		hazard.position.y += 190.0 * delta
		if hazard.get_rect().intersects(guard_marker.get_rect()):
			player_creature.receive_damage(3 if not guarded else 1)
			_remove_hazard(hazard)
			_update_hud()
			if player_creature.is_fainted():
				_finish_battle(false)
				return
		elif hazard.position.y > dodge_box.size.y:
			_remove_hazard(hazard)
	if _dodge_time <= 0.0:
		_end_dodge_phase()


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
	field.custom_minimum_size.y = 410
	arena.add_child(field)
	creature_texture = TextureRect.new()
	creature_texture.position = Vector2(65, 70)
	creature_texture.size = Vector2(360, 300)
	creature_texture.texture = BRAMBLET.battle_texture
	creature_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creature_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	field.add_child(creature_texture)

	var enemy_card := _make_status_card(true)
	enemy_card.position = Vector2(710, 38)
	enemy_card.size = Vector2(450, 116)
	field.add_child(enemy_card)
	var player_card := _make_status_card(false)
	player_card.position = Vector2(630, 270)
	player_card.size = Vector2(520, 116)
	field.add_child(player_card)

	message_label = Label.new()
	message_label.custom_minimum_size.y = 54
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", CREAM)
	message_label.add_theme_font_size_override("font_size", 20)
	page.add_child(message_label)

	command_grid = GridContainer.new()
	command_grid.columns = 2
	command_grid.add_theme_constant_override("h_separation", 12)
	command_grid.add_theme_constant_override("v_separation", 10)
	page.add_child(command_grid)
	_add_command("ROOT RUSH", 11, &"Plant", false)
	_add_command("LEAF FLICK", 8, &"Plant", false)
	_add_command("BURROW BASH", 10, &"Earth", false)
	_add_command("BRACE · INSTINCT", 0, &"Plant", true)

	dodge_box = Control.new()
	dodge_box.custom_minimum_size = Vector2(0, 150)
	dodge_box.clip_contents = true
	dodge_box.add_theme_stylebox_override("panel", _style(Color("#172422"), BRASS, 3, 8))
	page.add_child(dodge_box)
	guard_marker = ColorRect.new()
	guard_marker.size = Vector2(18, 18)
	guard_marker.color = Color("#91df79")
	dodge_box.add_child(guard_marker)
	dodge_box.hide()


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
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = label
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_stylebox_override("normal", _style(TEAL, BRASS, 2, 9))
	button.add_theme_stylebox_override("hover", _style(GREEN, CREAM, 3, 9))
	button.add_theme_stylebox_override("focus", _style(GREEN, CREAM, 4, 9))
	button.pressed.connect(_on_command.bind(label, power, affinity, instinct))
	command_grid.add_child(button)


func _on_command(label: String, power: int, affinity: StringName, instinct: bool) -> void:
	if phase != Phase.COMMAND:
		return
	guarded = instinct
	if instinct:
		message_label.text = "%s braces behind a wall of roots!" % player_creature.nickname
	else:
		var multiplier := BattleRules.effectiveness(affinity, enemy_creature.definition.affinity)
		var damage := BattleRules.technique_damage(power, player_creature, enemy_creature, multiplier)
		enemy_creature.receive_damage(damage)
		message_label.text = "%s used %s for %d damage%s" % [player_creature.nickname, label, damage, " — effective!" if multiplier > 1.0 else "."]
	_update_hud()
	if enemy_creature.is_fainted():
		_finish_battle(true)
		return
	await get_tree().create_timer(0.65).timeout
	_begin_dodge_phase()


func _begin_dodge_phase() -> void:
	phase = Phase.DODGE
	command_grid.hide()
	dodge_box.show()
	guard_marker.position = dodge_box.size * 0.5 - guard_marker.size * 0.5
	_dodge_time = 3.6
	_spawn_time = 0.05
	message_label.text = "Dodge the attack! Move the green guard marker."


func _spawn_hazard() -> void:
	var hazard := ColorRect.new()
	hazard.size = Vector2(12, 22)
	hazard.color = Color("#e7bc62")
	hazard.position = Vector2(randf_range(8.0, maxi(9.0, dodge_box.size.x - 20.0)), -24.0)
	dodge_box.add_child(hazard)
	_hazards.append(hazard)


func _remove_hazard(hazard: ColorRect) -> void:
	_hazards.erase(hazard)
	hazard.queue_free()


func _end_dodge_phase() -> void:
	for hazard in _hazards.duplicate():
		_remove_hazard(hazard)
	phase = Phase.COMMAND
	guarded = false
	dodge_box.hide()
	command_grid.show()
	message_label.text = "Choose Bramblet's next technique."
	_focus_first_command()


func _finish_battle(player_won: bool) -> void:
	phase = Phase.FINISHED
	command_grid.hide()
	dodge_box.hide()
	message_label.text = "%s" % ("Bramblet prevailed! The wild Nokomon withdraws." if player_won else "Bramblet can no longer battle. Return to the clinic.")
	await get_tree().create_timer(1.5).timeout
	hide()
	set_process(false)
	battle_finished.emit(player_won)


func _update_hud() -> void:
	player_name_label.text = "%s · Lv.%d · %s" % [player_creature.nickname, player_creature.level, player_creature.definition.affinity]
	player_hp_bar.max_value = player_creature.max_hp()
	player_hp_bar.value = player_creature.current_hp
	player_hp_label.text = "%d / %d HP" % [player_creature.current_hp, player_creature.max_hp()]
	enemy_name_label.text = "%s · Lv.%d · %s" % [enemy_creature.nickname, enemy_creature.level, enemy_creature.definition.affinity]
	enemy_hp_bar.max_value = enemy_creature.max_hp()
	enemy_hp_bar.value = enemy_creature.current_hp
	enemy_hp_label.text = "%d / %d HP" % [enemy_creature.current_hp, enemy_creature.max_hp()]


func _enemy_affinity(enemy_name: String) -> StringName:
	match enemy_name:
		"Cindervole":
			return &"Fire"
		"Gloamoth":
			return &"Ghost"
	return &"Plant"


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
