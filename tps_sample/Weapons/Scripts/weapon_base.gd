extends Node3D
class_name WeaponBase

# Weapon Properties
@export var weapon_name: String = "Weapon"
@export var damage: float = 25.0
@export var fire_rate: float = 0.5  # Time between shots in seconds
@export var max_ammo: int = 30
@export var current_ammo: int = 30
@export var reload_time: float = 2.0
@export var weapon_range: float = 100.0
@export var is_automatic: bool = false
@export var projectile_speed: float = 50.0

# Weapon State
var can_fire: bool = true
var is_reloading: bool = false
var last_fire_time: float = 0.0

# References
@export var muzzle_flash: Node3D
@export var weapon_model: Node3D
@export var projectile_scene: PackedScene
@export var camera_system: Node3D  # Reference to camera system for recoil
@export var aim_config: WeaponAimConfig  # Aim configuration for this weapon

# Signals
signal weapon_fired(weapon: WeaponBase)
signal weapon_reloaded(weapon: WeaponBase)
signal ammo_changed(current_ammo: int, max_ammo: int)

func _ready() -> void:
	# Initialize weapon
	current_ammo = max_ammo
	emit_signal("ammo_changed", current_ammo, max_ammo)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		if is_automatic:
			start_firing()
		else:
			fire()
	
	if event.is_action_released("fire"):
		if is_automatic:
			stop_firing()
	
	if event.is_action_pressed("reload"):
		reload()

func _process(delta: float) -> void:
	# Handle automatic firing
	if is_automatic and Input.is_action_pressed("fire"):
		fire()

func fire() -> void:
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	
	var current_time = Time.get_time_dict_from_system()
	if current_time - last_fire_time < fire_rate:
		return
	
	# Fire the weapon
	last_fire_time = current_time
	current_ammo -= 1
	emit_signal("ammo_changed", current_ammo, max_ammo)
	
	# Create projectile
	create_projectile()
	
	# Play effects
	play_fire_effects()
	
	emit_signal("weapon_fired", self)

func create_projectile() -> void:
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	if projectile:
		# Add to scene
		get_tree().current_scene.add_child(projectile)
		
		# Set projectile properties
		projectile.global_transform = global_transform
		projectile.damage = damage
		projectile.speed = projectile_speed
		projectile.range_limit = weapon_range
		
		# Set direction based on camera
		var camera = get_viewport().get_camera_3d()
		if camera:
			projectile.direction = -camera.global_transform.basis.z

func play_fire_effects() -> void:
	# Play muzzle flash
	if muzzle_flash:
		muzzle_flash.visible = true
		await get_tree().create_timer(0.1).timeout
		muzzle_flash.visible = false
	
	# Add recoil to camera
	add_recoil()
	
	# Play sound (you can add AudioStreamPlayer3D to the weapon)
	# if fire_sound:
	#     fire_sound.play()

func add_recoil() -> void:
	if camera_system and camera_system.has_method("add_recoil"):
		var recoil_strength = Vector2(
			randf_range(-0.05, 0.05),
			randf_range(0.02, 0.08)
		)
		
		# Use weapon-specific recoil if available
		if aim_config:
			recoil_strength = aim_config.recoil_strength
		
		camera_system.add_recoil(recoil_strength)

func get_aim_config() -> WeaponAimConfig:
	return aim_config

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	can_fire = false
	
	# Play reload animation/sound here
	await get_tree().create_timer(reload_time).timeout
	
	current_ammo = max_ammo
	is_reloading = false
	can_fire = true
	
	emit_signal("ammo_changed", current_ammo, max_ammo)
	emit_signal("weapon_reloaded", self)

func start_firing() -> void:
	# Called when automatic weapon starts firing
	pass

func stop_firing() -> void:
	# Called when automatic weapon stops firing
	pass

func get_ammo_info() -> Dictionary:
	return {
		"current": current_ammo,
		"max": max_ammo,
		"percentage": float(current_ammo) / float(max_ammo) * 100.0
	}

func add_ammo(amount: int) -> void:
	current_ammo = min(current_ammo + amount, max_ammo)
	emit_signal("ammo_changed", current_ammo, max_ammo) 
