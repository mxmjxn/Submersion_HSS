extends WeaponBase
class_name Pistol

func _ready() -> void:
	super._ready()
	
	# Set pistol-specific properties
	weapon_name = "Pistol"
	damage = 25.0
	fire_rate = 0.5
	max_ammo = 12
	current_ammo = 12
	reload_time = 1.5
	weapon_range = 50.0
	is_automatic = false
	projectile_speed = 40.0

func fire() -> void:
	# Pistol-specific fire logic
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	
	var current_time = Time.get_time_dict_from_system()
	if current_time - last_fire_time < fire_rate:
		return
	
	# Fire the weapon
	last_fire_time = current_time
	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, max_ammo)
	
	# Create projectile with pistol-specific properties
	create_projectile()
	
	# Play pistol-specific effects
	play_fire_effects()
	
	emit_signal("weapon_fired", self)

func play_fire_effects() -> void:
	# Pistol-specific fire effects
	if muzzle_flash:
		muzzle_flash.visible = true
		await get_tree().create_timer(0.05).timeout  # Shorter flash for pistol
		muzzle_flash.visible = false
	
	# Add pistol recoil
	add_recoil()

func add_recoil() -> void:
	# Pistol-specific recoil (moderate)
	if camera_system and camera_system.has_method("add_recoil"):
		var recoil_strength = Vector2(
			randf_range(-0.03, 0.03),  # Horizontal recoil
			randf_range(0.03, 0.06)   # Vertical recoil
		)
		camera_system.add_recoil(recoil_strength)

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	can_fire = false
	
	# Pistol-specific reload animation/sound
	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = max_ammo
	is_reloading = false
	can_fire = true
	
	emit_signal("ammo_changed", current_ammo, max_ammo)
	emit_signal("weapon_reloaded", self) 
