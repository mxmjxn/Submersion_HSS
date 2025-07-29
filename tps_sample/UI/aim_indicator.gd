extends Control
class_name AimIndicator

# UI References
@export var aim_indicator: TextureRect
@export var scope_overlay: TextureRect
@export var crosshair: TextureRect
@export var camera_system: Node3D

# Aim states
var is_aiming: bool = false
var is_scoped: bool = false

func _ready() -> void:
	# Connect to camera system
	if camera_system:
		# You can connect to camera signals here if needed
		pass
	
	# Initialize UI state
	update_aim_display()

func _process(delta: float) -> void:
	# Update aim state from camera system
	if camera_system and camera_system.has_method("get_aim_info"):
		var aim_info = camera_system.get_aim_info()
		var was_aiming = is_aiming
		is_aiming = aim_info.is_aiming
		
		# Update display if state changed
		if was_aiming != is_aiming:
			update_aim_display()

func update_aim_display() -> void:
	if aim_indicator:
		aim_indicator.visible = is_aiming
	
	if scope_overlay:
		scope_overlay.visible = is_aiming and is_scoped
	
	if crosshair:
		# Change crosshair based on aiming state
		if is_aiming:
			crosshair.modulate = Color.YELLOW
			crosshair.scale = Vector2(0.8, 0.8)  # Smaller crosshair when aiming
		else:
			crosshair.modulate = Color.WHITE
			crosshair.scale = Vector2(1.0, 1.0)  # Normal crosshair

func set_scope_mode(enabled: bool) -> void:
	is_scoped = enabled
	update_aim_display()

func show_aim_effect() -> void:
	# Add visual effect when starting to aim
	if aim_indicator:
		# Add a brief flash or animation
		aim_indicator.modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(aim_indicator, "modulate", Color.WHITE, 0.1)
		tween.tween_property(aim_indicator, "modulate", Color(1, 1, 1, 0.8), 0.2)

func hide_aim_effect() -> void:
	# Add visual effect when stopping aim
	if aim_indicator:
		aim_indicator.modulate = Color(1, 1, 1, 0.8) 
