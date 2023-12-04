extends StaticBody2D

signal toggle_inventory(external_inventory_owner, keep_open)

@export var inventory_data: InventoryData

func player_interact() -> void:
	toggle_inventory.emit(self, true)
