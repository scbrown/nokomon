class_name InventoryScreen
extends Control

signal item_action_requested(item_id: StringName)
signal close_requested

const ITEM_DEFINITIONS: Array[InventoryItemDefinition] = [
	preload("res://src/data/items/field_journal.tres"),
	preload("res://src/data/items/wayfinder_compass.tres"),
	preload("res://src/data/items/signal_whistle.tres"),
	preload("res://src/data/items/railway_pass.tres"),
	preload("res://src/data/items/clinic_letter.tres"),
	preload("res://src/data/items/moss_biscuit.tres"),
	preload("res://src/data/items/honeyed_seed.tres"),
	preload("res://src/data/items/copper_goggles.tres"),
	preload("res://src/data/items/green_neckerchief.tres"),
	preload("res://src/data/items/copper_scrap.tres"),
	preload("res://src/data/items/ghostcap_spores.tres"),
]

const STARTING_QUANTITIES: Dictionary[StringName, int] = {
	&"field_journal": 1,
	&"wayfinder_compass": 1,
	&"signal_whistle": 3,
	&"railway_pass": 1,
	&"clinic_letter": 1,
	&"moss_biscuit": 8,
	&"honeyed_seed": 12,
	&"copper_goggles": 1,
	&"green_neckerchief": 1,
	&"copper_scrap": 18,
	&"ghostcap_spores": 6,
}

const CATEGORIES: Array[InventoryItemDefinition.Category] = [
	InventoryItemDefinition.Category.TOOLS,
	InventoryItemDefinition.Category.KEY_ITEMS,
	InventoryItemDefinition.Category.TREATS,
	InventoryItemDefinition.Category.COSMETICS,
	InventoryItemDefinition.Category.MATERIALS,
]

const CATEGORY_MARKS: Array[String] = ["⌖", "◆", "●", "◇", "▦"]

const IRON := Color("#172422")
const DEEP_TEAL := Color("#123f38")
const FOREST := Color("#1d5948")
const BRASS := Color("#c9943d")
const BRASS_LIGHT := Color("#f0c86d")
const COPPER := Color("#8f4d2f")
const LEATHER := Color("#4a2c23")
const PARCHMENT := Color("#eadbb5")
const INK := Color("#2b211b")
const MUTED_INK := Color("#665443")

var _model := InventoryModel.new()
var _current_category: InventoryItemDefinition.Category = InventoryItemDefinition.Category.TOOLS
var _selected_index := 0
var _visible_entries: Array[InventoryEntry] = []
var _category_buttons: Array[Button] = []
var _item_buttons: Array[Button] = []

var _category_list: VBoxContainer
var _items_title: Label
var _item_list: VBoxContainer
var _detail_mark: Label
var _detail_name: Label
var _detail_category: Label
var _detail_description: Label
var _detail_quantity: Label
var _action_button: Button
var _status_label: Label


func _ready() -> void:
	for definition in ITEM_DEFINITIONS:
		_model.add_item(definition, STARTING_QUANTITIES.get(definition.id, 1))
	_build_interface()
	_refresh_all()
	call_deferred("_focus_first_item")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_requested.emit()
		_set_status("The satchel can be closed from the surrounding game.")
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_Q:
				_step_category(-1)
			KEY_E:
				_step_category(1)
			KEY_S:
				_sort_current_category()
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_LEFT_SHOULDER:
				_step_category(-1)
			JOY_BUTTON_RIGHT_SHOULDER:
				_step_category(1)


func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = IRON
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	page.add_child(_build_header())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	page.add_child(body)
	body.add_child(_build_category_panel())
	body.add_child(_build_item_panel())
	body.add_child(_build_detail_panel())
	page.add_child(_build_footer())


func _build_header() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 74
	panel.add_theme_stylebox_override("panel", _panel_style(LEATHER, BRASS, 3, 12))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)

	var badge := Label.new()
	badge.custom_minimum_size.x = 64
	badge.text = "▣"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_color_override("font_color", BRASS_LIGHT)
	badge.add_theme_font_size_override("font_size", 34)
	row.add_child(badge)

	var title := Label.new()
	title.text = "FIELD SATCHEL"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", PARCHMENT)
	title.add_theme_font_size_override("font_size", 30)
	row.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "EXPEDITION INVENTORY"
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", BRASS_LIGHT)
	subtitle.add_theme_font_size_override("font_size", 15)
	row.add_child(subtitle)
	return panel


func _build_category_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 210
	panel.add_theme_stylebox_override("panel", _panel_style(LEATHER, COPPER, 2, 10))

	_category_list = VBoxContainer.new()
	_category_list.add_theme_constant_override("separation", 8)
	panel.add_child(_category_list)

	for index in CATEGORIES.size():
		var button := Button.new()
		button.custom_minimum_size = Vector2(188, 72)
		button.text = "%s  %s" % [CATEGORY_MARKS[index], InventoryItemDefinition.category_name(CATEGORIES[index])]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_category_pressed.bind(CATEGORIES[index]))
		_category_buttons.append(button)
		_category_list.add_child(button)
	return panel


func _build_item_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 430
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(PARCHMENT, BRASS, 3, 12))

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)

	_items_title = Label.new()
	_items_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_items_title.add_theme_color_override("font_color", INK)
	_items_title.add_theme_font_size_override("font_size", 25)
	column.add_child(_items_title)

	var rule := HSeparator.new()
	rule.add_theme_color_override("separator", COPPER)
	column.add_child(rule)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	_item_list = VBoxContainer.new()
	_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_item_list)
	return panel


func _build_detail_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 400
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(DEEP_TEAL, BRASS, 3, 12))

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)

	_detail_category = Label.new()
	_detail_category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_category.add_theme_color_override("font_color", BRASS_LIGHT)
	_detail_category.add_theme_font_size_override("font_size", 15)
	column.add_child(_detail_category)

	_detail_name = Label.new()
	_detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_name.add_theme_color_override("font_color", PARCHMENT)
	_detail_name.add_theme_font_size_override("font_size", 25)
	column.add_child(_detail_name)

	var display_frame := PanelContainer.new()
	display_frame.custom_minimum_size.y = 245
	display_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	display_frame.add_theme_stylebox_override("panel", _panel_style(IRON, COPPER, 2, 10))
	column.add_child(display_frame)

	_detail_mark = Label.new()
	_detail_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_detail_mark.add_theme_color_override("font_color", BRASS_LIGHT)
	_detail_mark.add_theme_font_size_override("font_size", 92)
	display_frame.add_child(_detail_mark)

	var description_frame := PanelContainer.new()
	description_frame.custom_minimum_size.y = 120
	description_frame.add_theme_stylebox_override("panel", _panel_style(PARCHMENT, BRASS, 2, 10))
	column.add_child(description_frame)

	_detail_description = Label.new()
	_detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_detail_description.add_theme_color_override("font_color", INK)
	_detail_description.add_theme_font_size_override("font_size", 17)
	description_frame.add_child(_detail_description)

	_detail_quantity = Label.new()
	_detail_quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_quantity.add_theme_color_override("font_color", PARCHMENT)
	_detail_quantity.add_theme_font_size_override("font_size", 16)
	column.add_child(_detail_quantity)

	_action_button = Button.new()
	_action_button.custom_minimum_size.y = 58
	_action_button.text = "USE"
	_action_button.add_theme_font_size_override("font_size", 20)
	_action_button.add_theme_stylebox_override("normal", _panel_style(FOREST, BRASS, 2, 10))
	_action_button.add_theme_stylebox_override("hover", _panel_style(Color("#26705b"), BRASS_LIGHT, 3, 10))
	_action_button.add_theme_stylebox_override("focus", _panel_style(Color("#26705b"), BRASS_LIGHT, 4, 10))
	_action_button.add_theme_stylebox_override("disabled", _panel_style(Color("#34413d"), Color("#72634b"), 1, 10))
	_action_button.add_theme_color_override("font_color", PARCHMENT)
	_action_button.pressed.connect(_on_action_pressed)
	column.add_child(_action_button)
	return panel


func _build_footer() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 54
	panel.add_theme_stylebox_override("panel", _panel_style(LEATHER, COPPER, 2, 10))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	panel.add_child(row)

	_status_label = Label.new()
	_status_label.text = "Choose a pocket or inspect an item."
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", PARCHMENT)
	_status_label.add_theme_font_size_override("font_size", 15)
	row.add_child(_status_label)

	var hints := Label.new()
	hints.text = "Q/E or LB/RB  POCKET    S  SORT    ESC  BACK"
	hints.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hints.add_theme_color_override("font_color", BRASS_LIGHT)
	hints.add_theme_font_size_override("font_size", 14)
	row.add_child(hints)
	return panel


func _refresh_all() -> void:
	_refresh_categories()
	_refresh_item_list()


func _refresh_categories() -> void:
	for index in _category_buttons.size():
		var button := _category_buttons[index]
		var is_current := CATEGORIES[index] == _current_category
		button.text = "%s  %s  %d" % [
			CATEGORY_MARKS[index],
			InventoryItemDefinition.category_name(CATEGORIES[index]),
			_model.item_count(CATEGORIES[index]),
		]
		button.add_theme_color_override("font_color", PARCHMENT if is_current else BRASS_LIGHT)
		button.add_theme_stylebox_override(
			"normal",
			_panel_style(FOREST if is_current else LEATHER, BRASS_LIGHT if is_current else COPPER, 3 if is_current else 1, 8)
		)
		button.add_theme_stylebox_override("hover", _panel_style(FOREST, BRASS_LIGHT, 2, 8))
		button.add_theme_stylebox_override("focus", _panel_style(FOREST, BRASS_LIGHT, 4, 8))


func _refresh_item_list() -> void:
	for child in _item_list.get_children():
		child.queue_free()
	_item_buttons.clear()

	_visible_entries = _model.entries_for_category(_current_category)
	_selected_index = clampi(_selected_index, 0, maxi(_visible_entries.size() - 1, 0))
	_items_title.text = InventoryItemDefinition.category_name(_current_category)

	for index in _visible_entries.size():
		var entry := _visible_entries[index]
		var button := Button.new()
		button.custom_minimum_size.y = 68
		button.text = "  [%s]  %s                                 ×%d" % [
			entry.definition.icon_label,
			entry.definition.display_name,
			entry.quantity,
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.clip_text = true
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", INK)
		button.add_theme_color_override("font_hover_color", PARCHMENT)
		button.add_theme_color_override("font_focus_color", PARCHMENT)
		button.add_theme_stylebox_override("normal", _panel_style(Color("#dfcc9f"), Color("#b79760"), 1, 7))
		button.add_theme_stylebox_override("hover", _panel_style(FOREST, BRASS_LIGHT, 2, 7))
		button.add_theme_stylebox_override("focus", _panel_style(FOREST, BRASS_LIGHT, 4, 7))
		button.pressed.connect(_select_entry.bind(index, false))
		button.focus_entered.connect(_select_entry.bind(index, false))
		_item_buttons.append(button)
		_item_list.add_child(button)

	_refresh_detail()


func _refresh_detail() -> void:
	if _visible_entries.is_empty():
		_detail_mark.text = "—"
		_detail_name.text = "POCKET EMPTY"
		_detail_category.text = InventoryItemDefinition.category_name(_current_category)
		_detail_description.text = "There are no items in this pocket."
		_detail_quantity.text = ""
		_action_button.disabled = true
		return

	var entry := _visible_entries[_selected_index]
	_detail_mark.text = entry.definition.icon_label
	_detail_name.text = entry.definition.display_name.to_upper()
	_detail_category.text = InventoryItemDefinition.category_name(entry.definition.category)
	_detail_description.text = entry.definition.description
	_detail_quantity.text = "IN SATCHEL: %d" % entry.quantity
	_action_button.disabled = not entry.definition.can_use
	_action_button.text = "USE" if entry.definition.can_use else "KEY ITEM"


func _select_entry(index: int, focus_button: bool = false) -> void:
	if index < 0 or index >= _visible_entries.size():
		return
	_selected_index = index
	_refresh_detail()
	if focus_button and index < _item_buttons.size():
		_item_buttons[index].grab_focus()


func _on_category_pressed(category: InventoryItemDefinition.Category) -> void:
	_current_category = category
	_selected_index = 0
	_refresh_all()
	call_deferred("_focus_first_item")


func _step_category(direction: int) -> void:
	var index := CATEGORIES.find(_current_category)
	index = wrapi(index + direction, 0, CATEGORIES.size())
	_on_category_pressed(CATEGORIES[index])


func _sort_current_category() -> void:
	_model.sort_category(_current_category)
	_selected_index = 0
	_refresh_item_list()
	_set_status("Sorted %s alphabetically." % InventoryItemDefinition.category_name(_current_category).to_lower())
	call_deferred("_focus_first_item")


func _on_action_pressed() -> void:
	if _visible_entries.is_empty():
		return
	var entry := _visible_entries[_selected_index]
	if not entry.definition.can_use:
		return
	item_action_requested.emit(entry.definition.id)
	_set_status("Selected %s. The surrounding game decides its effect." % entry.definition.display_name)


func _focus_first_item() -> void:
	if not _item_buttons.is_empty():
		_item_buttons[_selected_index].grab_focus()


func _set_status(message: String) -> void:
	_status_label.text = message


func consume_item(item_id: StringName, amount := 1) -> bool:
	var entry := _model.find_entry(item_id)
	if entry == null or entry.quantity < amount:
		return false
	_model.remove_item(item_id, amount)
	_refresh_all()
	return true


func item_quantity(item_id: StringName) -> int:
	var entry := _model.find_entry(item_id)
	return entry.quantity if entry != null else 0


func _panel_style(color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style
