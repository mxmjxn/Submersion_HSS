extends Resource
class_name WeaponAimConfig

# Aim Configuration for different weapons
@export var weapon_name: String = "Default"
@export var fov: float = 70.0
@export var position_offset: Vector3 = Vector3(0, -0.1, 0.2)
@export var rotation_offset: Vector3 = Vector3(0, 0, 0)
@export var sensitivity_multiplier: float = 0.8
@export var zoom_speed: float = 8.0
@export var recoil_strength: Vector2 = Vector2(0.03, 0.05)
@export var recoil_recovery_speed: float = 5.0
@export var max_recoil: float = 0.1

# Advanced aiming features
@export var has_scope: bool = false
@export var scope_fov: float = 30.0
@export var scope_position_offset: Vector3 = Vector3(0, -0.2, 0.4)
@export var scope_sensitivity_multiplier: float = 0.3

# Aim assist settings (for future implementation)
@export var aim_assist_enabled: bool = false
@export var aim_assist_strength: float = 0.5
@export var aim_assist_range: float = 10.0

func get_aim_settings() -> Dictionary:
	return {
		"fov": fov,
		"position_offset": position_offset,
		"rotation_offset": rotation_offset,
		"sensitivity_multiplier": sensitivity_multiplier,
		"zoom_speed": zoom_speed,
		"recoil_strength": recoil_strength,
		"recoil_recovery_speed": recoil_recovery_speed,
		"max_recoil": max_recoil,
		"has_scope": has_scope,
		"scope_fov": scope_fov,
		"scope_position_offset": scope_position_offset,
		"scope_sensitivity_multiplier": scope_sensitivity_multiplier,
		"aim_assist_enabled": aim_assist_enabled,
		"aim_assist_strength": aim_assist_strength,
		"aim_assist_range": aim_assist_range
	}

func get_scope_settings() -> Dictionary:
	if has_scope:
		return {
			"fov": scope_fov,
			"position_offset": scope_position_offset,
			"sensitivity_multiplier": scope_sensitivity_multiplier
		}
	return get_aim_settings() 
