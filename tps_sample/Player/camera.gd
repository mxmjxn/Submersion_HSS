extends Node3D

@export var character: CharacterBody3D
@export var camera_node: Camera3D
@export var weapon_manager: WeaponManager

# Camera Control
var camera_rotation: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.001 
var max_y_rotation: float = 1.2

# Aiming System
var is_aiming: bool = false
var aim_transition_speed: float = 8.0
var current_aim_state: AimState = AimState.NORMAL

# Aiming States
enum AimState {
	NORMAL,
	AIMING,
	ADS  # Aim Down Sights
}

# Default camera settings
var default_fov: float = 75.0
var default_position: Vector3
var default_rotation: Vector3

# Aiming settings for different weapons
var aim_settings: Dictionary = {
	"pistol": {
		"fov": 65.0,
		"position_offset": Vector3(0, -0.1, 0.2),
		"rotation_offset": Vector3(0, 0, 0),
		"sensitivity_multiplier": 0.7,
		"zoom_speed": 10.0
	},
	"rifle": {
		"fov": 55.0,
		"position_offset": Vector3(0, -0.15, 0.3),
		"rotation_offset": Vector3(0, 0, 0),
		"sensitivity_multiplier": 0.5,
		"zoom_speed": 12.0
	},
	"default": {
		"fov": 70.0,
		"position_offset": Vector3(0, -0.1, 0.2),
		"rotation_offset": Vector3(0, 0, 0),
		"sensitivity_multiplier": 0.8,
		"zoom_speed": 8.0
	}
}

# Recoil System
var recoil_offset: Vector2 = Vector2.ZERO
var recoil_recovery_speed: float = 5.0
var max_recoil: float = 0.1

# Smoothing
var target_position: Vector3
var target_rotation: Vector3
var target_fov: float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Store default camera settings
	if camera_node:
		default_fov = camera_node.fov
		default_position = position
		target_position = default_position
		target_fov = default_fov
	
	# Connect to weapon manager
	if weapon_manager:
		weapon_manager.weapon_switched.connect(_on_weapon_switched)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Aiming input
	if event.is_action_pressed("aim"):
		start_aiming()
	elif event.is_action_released("aim"):
		stop_aiming()

	if event is InputEventMouseMotion:
		var sensitivity = mouse_sensitivity
		if is_aiming:
			var current_weapon = get_current_weapon_type()
			var aim_setting = aim_settings.get(current_weapon, aim_settings["default"])
			sensitivity *= aim_setting.sensitivity_multiplier
		
		var mouse_event: Vector2 = event.screen_relative * sensitivity
		camera_look(mouse_event)

func _process(delta: float) -> void:
	# Handle aiming transitions
	update_aiming_transition(delta)
	
	# Handle recoil recovery
	update_recoil_recovery(delta)

func camera_look(mouse_movement: Vector2) -> void:
	# Apply recoil offset
	mouse_movement += recoil_offset
	
	camera_rotation += mouse_movement
	
	transform.basis = Basis()
	character.transform.basis = Basis()
	
	character.rotate_object_local(Vector3(0, 1, 0), -camera_rotation.x)
	rotate_object_local(Vector3(1, 0, 0), -camera_rotation.y)
	camera_rotation.y = clamp(camera_rotation.y, -max_y_rotation, max_y_rotation)

func start_aiming() -> void:
	if not is_aiming:
		is_aiming = true
		current_aim_state = AimState.AIMING
		update_aim_settings()

func stop_aiming() -> void:
	if is_aiming:
		is_aiming = false
		current_aim_state = AimState.NORMAL
		update_aim_settings()

func update_aim_settings() -> void:
	var current_weapon = get_current_weapon_type()
	var settings = aim_settings.get(current_weapon, aim_settings["default"])
	
	# Try to get weapon-specific aim config
	if weapon_manager:
		var weapon = weapon_manager.get_current_weapon()
		if weapon and weapon.has_method("get_aim_config"):
			var aim_config = weapon.get_aim_config()
			if aim_config:
				settings = aim_config.get_aim_settings()
	
	if is_aiming:
		target_position = default_position + settings.position_offset
		target_fov = settings.fov
		target_rotation = default_rotation + settings.rotation_offset
	else:
		target_position = default_position
		target_fov = default_fov
		target_rotation = default_rotation

func update_aiming_transition(delta: float) -> void:
	if not camera_node:
		return
	
	var current_weapon = get_current_weapon_type()
	var settings = aim_settings.get(current_weapon, aim_settings["default"])
	var transition_speed = settings.zoom_speed if is_aiming else aim_transition_speed
	
	# Smooth position transition
	position = position.lerp(target_position, transition_speed * delta)
	
	# Smooth FOV transition
	camera_node.fov = lerp(camera_node.fov, target_fov, transition_speed * delta)
	
	# Smooth rotation transition
	rotation = rotation.lerp(target_rotation, transition_speed * delta)

func update_recoil_recovery(delta: float) -> void:
	# Gradually reduce recoil offset
	recoil_offset = recoil_offset.lerp(Vector2.ZERO, recoil_recovery_speed * delta)

func add_recoil(recoil_strength: Vector2) -> void:
	# Add recoil to the camera
	recoil_offset += recoil_strength
	recoil_offset.x = clamp(recoil_offset.x, -max_recoil, max_recoil)
	recoil_offset.y = clamp(recoil_offset.y, -max_recoil, max_recoil)

func get_current_weapon_type() -> String:
	if weapon_manager:
		var current_weapon = weapon_manager.get_current_weapon()
		if current_weapon:
			return current_weapon.weapon_name.to_lower()
	return "default"

func _on_weapon_switched(weapon: WeaponBase) -> void:
	# Update aim settings when weapon changes
	if is_aiming:
		update_aim_settings()

func set_weapon_aim_settings(weapon_name: String, settings: Dictionary) -> void:
	# Allow runtime modification of aim settings
	aim_settings[weapon_name.to_lower()] = settings

func get_aim_info() -> Dictionary:
	return {
		"is_aiming": is_aiming,
		"aim_state": AimState.keys()[current_aim_state],
		"current_weapon": get_current_weapon_type(),
		"fov": camera_node.fov if camera_node else default_fov,
		"recoil_offset": recoil_offset
	}

func reset_camera() -> void:
	# Reset camera to default state
	is_aiming = false
	current_aim_state = AimState.NORMAL
	recoil_offset = Vector2.ZERO
	update_aim_settings()
