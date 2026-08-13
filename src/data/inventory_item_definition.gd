class_name InventoryItemDefinition
extends Resource

enum Category {
	TOOLS,
	KEY_ITEMS,
	TREATS,
	COSMETICS,
	MATERIALS,
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var category: Category = Category.TOOLS
@export var icon_label: String = "?"
@export var can_use: bool = false
@export_range(1, 999, 1) var max_stack: int = 99


static func category_name(value: Category) -> String:
	match value:
		Category.TOOLS:
			return "TOOLS"
		Category.KEY_ITEMS:
			return "KEY ITEMS"
		Category.TREATS:
			return "TREATS"
		Category.COSMETICS:
			return "COSMETICS"
		Category.MATERIALS:
			return "MATERIALS"
	return "UNKNOWN"
