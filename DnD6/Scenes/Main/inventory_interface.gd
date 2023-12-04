extends Control

var grabbed_slot_data: SlotData
var external_inventory_owner

@onready var player_inventory := $PlayerInventory
@onready var grabbed_slot := $GrabbedSlot
@onready var external_inventory := $ExternalInventory
 
func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)


#desc Sets the player inventory view to [param inventory_data]
func set_player_inventory(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)

	
#desc Sets the external owner inventory view to the inventory owned by [param _external_inventory_owner]
func set_external_inventory(_external_inventory_owner) -> void:
	if external_inventory_owner == _external_inventory_owner:
		return
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)

	external_inventory.show()

	
#desc Clears the external inventory view and removes the refrence to the external owner
func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

		
#desc Gets called when the mouse interacts with a slot
func on_inventory_interact(inventory_data: InventoryData, index: int, button: int, double: bool) -> void:

	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			if Input.is_physical_key_pressed(KEY_SHIFT) \
					and external_inventory_owner:
				pass
			else:
				grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			if not double:
				grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
			else:
				grabbed_slot_data = inventory_data.merge_all_slot_data(grabbed_slot_data)
		[null, MOUSE_BUTTON_RIGHT]:
			if Input.is_physical_key_pressed(KEY_SHIFT):
				grabbed_slot_data = inventory_data.grab_half_slot_data(index)
			else:
				pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
		
	update_grabbed_slot()

#desc Toggles the visibility of the slot for a grabbed item
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func drop_grabbed_slot() -> void:
	if not grabbed_slot.visible:
		return
	
	
