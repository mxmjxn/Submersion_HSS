extends Node3D
class_name WeaponManager

# Weapon Management
@export var weapons: Array[WeaponBase] = []
@export var current_weapon_index: int = 0
@export var max_weapons: int = 3

# Weapon Switching
@export var switch_delay: float = 0.3
var can_switch: bool = true
var last_switch_time: float = 0.0

# Ammo Management
@export var ammo_types: Dictionary = {
	"pistol": 100,
	"rifle": 200,
	"shotgun": 50
}

# References
@export var weapon_holder: Node3D  # Where weapons are attached
@export var ui_manager: Node  # For updating UI

# Signals
signal weapon_switched(weapon: WeaponBase)
signal ammo_updated(ammo_type: String, amount: int)

func _ready() -> void:
	# Initialize weapon manager
	setup_weapons()
	
	# Connect weapon signals
	for weapon in weapons:
		if weapon:
			weapon.ammo_changed.connect(_on_weapon_ammo_changed)
			weapon.weapon_fired.connect(_on_weapon_fired)

func _input(event: InputEvent) -> void:
	# Weapon switching
	if event.is_action_pressed("weapon_1") and weapons.size() > 0:
		switch_weapon(0)
	elif event.is_action_pressed("weapon_2") and weapons.size() > 1:
		switch_weapon(1)
	elif event.is_action_pressed("weapon_3") and weapons.size() > 2:
		switch_weapon(2)
	
	# Scroll wheel weapon switching
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			switch_to_next_weapon()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			switch_to_previous_weapon()

func setup_weapons() -> void:
	# Hide all weapons initially
	for weapon in weapons:
		if weapon:
			weapon.visible = false
	
	# Show current weapon
	if weapons.size() > 0 and weapons[current_weapon_index]:
		weapons[current_weapon_index].visible = true

func switch_weapon(index: int) -> void:
	if not can_switch or index >= weapons.size() or index == current_weapon_index:
		return
	
	var current_time = Time.get_time_dict_from_system()
	if current_time - last_switch_time < switch_delay:
		return
	
	# Hide current weapon
	if weapons[current_weapon_index]:
		weapons[current_weapon_index].visible = false
	
	# Switch to new weapon
	current_weapon_index = index
	last_switch_time = current_time
	
	# Show new weapon
	if weapons[current_weapon_index]:
		weapons[current_weapon_index].visible = true
	
	emit_signal("weapon_switched", weapons[current_weapon_index])

func switch_to_next_weapon() -> void:
	var next_index = (current_weapon_index + 1) % weapons.size()
	switch_weapon(next_index)

func switch_to_previous_weapon() -> void:
	var prev_index = current_weapon_index - 1
	if prev_index < 0:
		prev_index = weapons.size() - 1
	switch_weapon(prev_index)

func get_current_weapon() -> WeaponBase:
	if weapons.size() > 0 and current_weapon_index < weapons.size():
		return weapons[current_weapon_index]
	return null

func add_weapon(weapon: WeaponBase) -> bool:
	if weapons.size() >= max_weapons:
		return false
	
	weapons.append(weapon)
	
	# Connect signals
	weapon.ammo_changed.connect(_on_weapon_ammo_changed)
	weapon.weapon_fired.connect(_on_weapon_fired)
	
	# Hide weapon initially
	weapon.visible = false
	
	# If this is the first weapon, make it current
	if weapons.size() == 1:
		switch_weapon(0)
	
	return true

func remove_weapon(index: int) -> bool:
	if index >= weapons.size():
		return false
	
	var weapon = weapons[index]
	weapons.remove_at(index)
	
	# Disconnect signals
	if weapon:
		weapon.ammo_changed.disconnect(_on_weapon_ammo_changed)
		weapon.weapon_fired.disconnect(_on_weapon_fired)
	
	# Adjust current weapon index if needed
	if current_weapon_index >= weapons.size():
		current_weapon_index = max(0, weapons.size() - 1)
	
	# Show current weapon
	if weapons.size() > 0 and weapons[current_weapon_index]:
		weapons[current_weapon_index].visible = true
	
	return true

func add_ammo(ammo_type: String, amount: int) -> void:
	if ammo_types.has(ammo_type):
		ammo_types[ammo_type] += amount
		emit_signal("ammo_updated", ammo_type, ammo_types[ammo_type])

func get_ammo_count(ammo_type: String) -> int:
	return ammo_types.get(ammo_type, 0)

func reload_current_weapon() -> void:
	var current_weapon = get_current_weapon()
	if current_weapon:
		current_weapon.reload()

func _on_weapon_ammo_changed(current_ammo: int, max_ammo: int) -> void:
	# Update UI or handle ammo change
	if ui_manager and ui_manager.has_method("update_ammo_display"):
		ui_manager.update_ammo_display(current_ammo, max_ammo)

func _on_weapon_fired(weapon: WeaponBase) -> void:
	# Handle weapon fire effects
	pass

func get_weapon_info() -> Dictionary:
	var current_weapon = get_current_weapon()
	if current_weapon:
		return {
			"name": current_weapon.weapon_name,
			"ammo": current_weapon.get_ammo_info(),
			"index": current_weapon_index,
			"total_weapons": weapons.size()
		}
	return {} 
