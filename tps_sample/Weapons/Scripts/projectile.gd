extends Area3D
class_name Projectile

# Projectile Properties
@export var damage: float = 25.0
@export var speed: float = 50.0
@export var range_limit: float = 100.0
@export var gravity_affected: bool = false
@export var bounce_count: int = 0

# Internal variables
var direction: Vector3 = Vector3.FORWARD
var distance_traveled: float = 0.0
var start_position: Vector3
var current_bounces: int = 0

# References
@export var trail_effect: Node3D
@export var impact_effect: PackedScene

func _ready() -> void:
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Store start position
	start_position = global_position
	
	# Set up collision detection
	monitoring = true
	monitorable = true

func _physics_process(delta: float) -> void:
	# Move projectile
	var movement = direction * speed * delta
	global_position += movement
	
	# Apply gravity if needed
	if gravity_affected:
		direction.y -= 9.8 * delta
	
	# Track distance traveled
	distance_traveled = start_position.distance_to(global_position)
	
	# Check if projectile has exceeded range
	if distance_traveled >= range_limit:
		destroy_projectile()

func _on_body_entered(body: Node3D) -> void:
	# Check if we hit something that can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Handle bounce
	if current_bounces < bounce_count:
		handle_bounce(body)
	else:
		destroy_projectile()

func _on_area_entered(area: Area3D) -> void:
	# Check if we hit something that can take damage
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	# Handle bounce
	if current_bounces < bounce_count:
		handle_bounce(area)
	else:
		destroy_projectile()

func handle_bounce(collider: Node) -> void:
	# Simple bounce calculation
	var collision_point = global_position
	var normal = (global_position - collider.global_position).normalized()
	
	# Reflect direction
	direction = direction.bounce(normal)
	
	current_bounces += 1
	
	# Play bounce effect
	play_bounce_effect()

func destroy_projectile() -> void:
	# Play impact effect
	play_impact_effect()
	
	# Remove from scene
	queue_free()

func play_impact_effect() -> void:
	if impact_effect:
		var effect = impact_effect.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position

func play_bounce_effect() -> void:
	# Add bounce sound/visual effect here
	pass

func set_direction(new_direction: Vector3) -> void:
	direction = new_direction.normalized()

func set_properties(new_damage: float, new_speed: float, new_range: float) -> void:
	damage = new_damage
	speed = new_speed
	range_limit = new_range 
