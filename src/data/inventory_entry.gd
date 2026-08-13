class_name InventoryEntry
extends RefCounted

var definition: InventoryItemDefinition
var quantity: int


func _init(item_definition: InventoryItemDefinition, starting_quantity: int) -> void:
	definition = item_definition
	quantity = clampi(starting_quantity, 0, definition.max_stack)
