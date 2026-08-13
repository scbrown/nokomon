class_name InventoryModel
extends RefCounted

signal changed

var _entries: Array[InventoryEntry] = []


func add_item(definition: InventoryItemDefinition, amount: int = 1) -> int:
	if definition == null or amount <= 0:
		return 0

	var entry := find_entry(definition.id)
	if entry == null:
		entry = InventoryEntry.new(definition, 0)
		_entries.append(entry)

	var previous_quantity := entry.quantity
	entry.quantity = mini(entry.quantity + amount, definition.max_stack)
	var added := entry.quantity - previous_quantity
	if added > 0:
		changed.emit()
	return added


func remove_item(id: StringName, amount: int = 1) -> int:
	var entry := find_entry(id)
	if entry == null or amount <= 0:
		return 0

	var removed := mini(entry.quantity, amount)
	entry.quantity -= removed
	if entry.quantity == 0:
		_entries.erase(entry)
	if removed > 0:
		changed.emit()
	return removed


func find_entry(id: StringName) -> InventoryEntry:
	for entry in _entries:
		if entry.definition.id == id:
			return entry
	return null


func entries_for_category(category: InventoryItemDefinition.Category) -> Array[InventoryEntry]:
	var result: Array[InventoryEntry] = []
	for entry in _entries:
		if entry.definition.category == category:
			result.append(entry)
	return result


func sort_category(category: InventoryItemDefinition.Category) -> void:
	var category_entries := entries_for_category(category)
	category_entries.sort_custom(
		func(left: InventoryEntry, right: InventoryEntry) -> bool:
			return left.definition.display_name.naturalnocasecmp_to(right.definition.display_name) < 0
	)

	var replacement_index := 0
	for index in _entries.size():
		if _entries[index].definition.category == category:
			_entries[index] = category_entries[replacement_index]
			replacement_index += 1
	changed.emit()


func item_count(category: InventoryItemDefinition.Category) -> int:
	return entries_for_category(category).size()
