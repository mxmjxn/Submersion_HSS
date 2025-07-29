extends Control
class_name WeaponUI

# UI References
@export var ammo_label: Label
@export var weapon_name_label: Label
@export var health_bar: ProgressBar
@export var crosshair: TextureRect

# Connected systems
@export var weapon_manager: WeaponManager
@export var player: CharacterBody3D

func _ready() -> void:
	# Connect to weapon manager signals
	if weapon_manager:
		weapon_manager.weapon_switched.connect(_on_weapon_switched)
		weapon_manager.ammo_updated.connect(_on_ammo_updated)

func _process(delta: float) -> void:
	# Update health bar
	if player and health_bar:
		health_bar.value = player.get_health_percentage()

func update_ammo_display(current_ammo: int, max_ammo: int) -> void:
	if ammo_label:
		ammo_label.text = str(current_ammo) + " / " + str(max_ammo)

func _on_weapon_switched(weapon: WeaponBase) -> void:
	if weapon_name_label:
		weapon_name_label.text = weapon.weapon_name
	
	# Update ammo display
	var ammo_info = weapon.get_ammo_info()
	update_ammo_display(ammo_info.current, ammo_info.max)

func _on_ammo_updated(ammo_type: String, amount: int) -> void:
	# Update ammo type display if needed
	pass

func show_reload_indicator() -> void:
	# Show reload progress or indicator
	if ammo_label:
		ammo_label.text = "RELOADING..."

func hide_reload_indicator() -> void:
	# Hide reload indicator and show normal ammo
	if weapon_manager:
		var current_weapon = weapon_manager.get_current_weapon()
		if current_weapon:
			var ammo_info = current_weapon.get_ammo_info()
			update_ammo_display(ammo_info.current, ammo_info.max)

func update_crosshair(weapon_name: String) -> void:
	# Change crosshair based on weapon type
	if crosshair:
		match weapon_name:
			"Pistol":
				# Small, precise crosshair
				crosshair.modulate = Color.WHITE
			"Rifle":
				# Medium crosshair
				crosshair.modulate = Color.YELLOW
			_:
				# Default crosshair
				crosshair.modulate = Color.WHITE 
