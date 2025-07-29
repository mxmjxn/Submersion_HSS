extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Weapon System Integration
@export var weapon_manager: WeaponManager
@export var health: float = 100.0
@export var max_health: float = 100.0

# Player state
var is_alive: bool = true

func _ready() -> void:
	# Initialize player
	health = max_health
	
	# Connect weapon manager if available
	if weapon_manager:
		weapon_manager.weapon_switched.connect(_on_weapon_switched)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	# Handle weapon input
	if event.is_action_pressed("reload") and weapon_manager:
		weapon_manager.reload_current_weapon()

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	
	health -= amount
	health = max(health, 0.0)
	
	# Play damage effect
	play_damage_effect()
	
	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)

func die() -> void:
	is_alive = false
	# Play death animation/effect
	print("Player died!")

func play_damage_effect() -> void:
	# Add screen shake, red flash, or other damage effects
	pass

func _on_weapon_switched(weapon: WeaponBase) -> void:
	# Handle weapon switching effects
	print("Switched to: ", weapon.weapon_name)

func get_health_percentage() -> float:
	return (health / max_health) * 100.0

func is_player_alive() -> bool:
	return is_alive
