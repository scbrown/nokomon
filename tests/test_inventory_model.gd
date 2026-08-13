extends SceneTree

var _failures := 0


func _init() -> void:
	_test_add_caps_at_stack_limit()
	_test_remove_clears_empty_stack()
	_test_filter_and_sort_category()

	if _failures == 0:
		print("Inventory model tests passed.")
	quit(_failures)


func _test_add_caps_at_stack_limit() -> void:
	var definition := _make_definition(&"seed", "Seed", InventoryItemDefinition.Category.TREATS, 10)
	var model := InventoryModel.new()
	_expect_equal(model.add_item(definition, 8), 8, "adds the requested quantity")
	_expect_equal(model.add_item(definition, 8), 2, "reports only quantity added before the cap")
	_expect_equal(model.find_entry(&"seed").quantity, 10, "caps a stack at its authored limit")


func _test_remove_clears_empty_stack() -> void:
	var definition := _make_definition(&"scrap", "Scrap", InventoryItemDefinition.Category.MATERIALS, 99)
	var model := InventoryModel.new()
	model.add_item(definition, 3)
	_expect_equal(model.remove_item(&"scrap", 10), 3, "removes only the available quantity")
	_expect_true(model.find_entry(&"scrap") == null, "removes empty entries")


func _test_filter_and_sort_category() -> void:
	var model := InventoryModel.new()
	model.add_item(_make_definition(&"whistle", "Signal Whistle", InventoryItemDefinition.Category.TOOLS, 1))
	model.add_item(_make_definition(&"compass", "Wayfinder Compass", InventoryItemDefinition.Category.TOOLS, 1))
	model.add_item(_make_definition(&"letter", "Doctor's Letter", InventoryItemDefinition.Category.KEY_ITEMS, 1))

	_expect_equal(model.item_count(InventoryItemDefinition.Category.TOOLS), 2, "counts only entries in a category")
	model.sort_category(InventoryItemDefinition.Category.TOOLS)
	var tools := model.entries_for_category(InventoryItemDefinition.Category.TOOLS)
	_expect_equal(tools[0].definition.id, &"whistle", "sorts display names alphabetically")
	_expect_equal(tools[1].definition.id, &"compass", "keeps all sorted category entries")


func _make_definition(
	id: StringName,
	display_name: String,
	category: InventoryItemDefinition.Category,
	max_stack: int
) -> InventoryItemDefinition:
	var definition := InventoryItemDefinition.new()
	definition.id = id
	definition.display_name = display_name
	definition.category = category
	definition.max_stack = max_stack
	return definition


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures += 1
		push_error("%s: expected %s, got %s" % [message, expected, actual])


func _expect_true(value: bool, message: String) -> void:
	if not value:
		_failures += 1
		push_error(message)
