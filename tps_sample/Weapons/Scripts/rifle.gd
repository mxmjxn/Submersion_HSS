extends WeaponBase
class_name Rifle

# Rifle-specific properties
@export var burst_mode: bool = false
@export var burst_count: int = 3
@export var burst_delay: float = 0.1

var is_bursting: bool = false
var burst_shots_fired: int = 0

func _ready() -> void:
	super._ready()
	
	# Set rifle-specific properties
	weapon_name = "Rifle"
	damage = 35.0
	fire_rate = 0.1  # Faster fire rate for automatic
	max_ammo = 30
	current_ammo = 30
	reload_time = 2.5
	weapon_range = 100.0
	is_automatic = true
	projectile_speed = 60.0

func fire() -> void:
	# Rifle-specific fire logic
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	
	var current_time = Time.get_time_dict_from_system()
	if current_time - last_fire_time < fire_rate:
		return
	
	# Handle burst mode
	if burst_mode and not is_bursting:
		start_burst()
		return
	
	# Fire the weapon
	last_fire_time = current_time
	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, max_ammo)
	
	# Create projectile with rifle-specific properties
	create_projectile()
	
	# Play rifle-specific effects
	play_fire_effects()
	
	emit_signal("weapon_fired", self)

func start_burst() -> void:
	is_bursting = true
	burst_shots_fired = 0
	fire_burst_shot()

func fire_burst_shot() -> void:
	if burst_shots_fired >= burst_count or current_ammo <= 0:
		is_bursting = false
		return
	
	# Fire a single shot
	last_fire_time = Time.get_time_dict_from_system()
	current_ammo -= 1
	burst_shots_fired += 1
	emit_signal("ammo_changed", current_ammo, max_ammo)
	
	create_projectile()
	play_fire_effects()
	emit_signal("weapon_fired", self)
	
	# Schedule next burst shot
	await get_tree().create_timer(burst_delay).timeout
	fire_burst_shot()

func play_fire_effects() -> void:
	# Rifle-specific fire effects
	if muzzle_flash:
		muzzle_flash.visible = true
		await get_tree().create_timer(0.08).timeout  # Medium flash for rifle
		muzzle_flash.visible = false
	
	# Add rifle recoil
	add_recoil()

func add_recoil() -> void:
	# Rifle-specific recoil (stronger)
	if camera_system and camera_system.has_method("add_recoil"):
		var recoil_strength = Vector2(
			randf_range(-0.05, 0.05),  # Horizontal recoil
			randf_range(0.05, 0.1)    # Vertical recoil (stronger)
		)
		camera_system.add_recoil(recoil_strength)

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	can_fire = false
	
	# Rifle-specific reload animation/sound
	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = max_ammo
	is_reloading = false
	can_fire = true
	
	emit_signal("ammo_changed", current_ammo, max_ammo)
	emit_signal("weapon_reloaded", self)

func toggle_burst_mode() -> void:
	burst_mode = !burst_mode

func get_weapon_mode() -> String:
	if burst_mode:
		return "Burst"
	else:
		return "Auto" 
