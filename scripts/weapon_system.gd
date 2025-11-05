extends Node2D
class_name WeaponSystem

## ============================================================================
## WEAPON SYSTEM - Automatic weapon firing and targeting
## ============================================================================
##
## WHAT THIS SCRIPT DOES:
## This script handles automatic weapon firing for the player. It:
## - Finds the nearest enemy
## - Rotates to face that enemy
## - Automatically fires projectiles based on weapon stats
## - Handles weapon cooldowns and spread
##
## This script works with:
## - resources/weapons/*.tres (ProjectileWeaponResource data)
## - scenes/projectile.tscn (spawns these when firing)
## - scripts/player.gd (attached to player as child node)
##
## ============================================================================
## HOW TO CHANGE WEAPONS:
## ============================================================================
##
## Change which weapon the player starts with:
##   1. Open scenes/player.tscn
##   2. Select the WeaponSystem child node
##   3. In Inspector, change "Equipped Weapon" to a different weapon resource
##
## Create new weapon types:
##   - See projectile_weapon_resource.gd for instructions
##   - Just duplicate .tres files, no code changes needed!
##
## ============================================================================
## ADVANCED: Modifying Weapon System Behavior
## ============================================================================
##
## Change targeting logic:
##   - Find: func _find_nearest_enemy()
##   - Modify to target lowest health, highest damage, etc.
##
## Add manual aiming:
##   - Currently auto-aims at nearest enemy
##   - Modify _process() to use mouse position or input direction
##
## Add weapon switching:
##   - Add input detection
##   - Call equip_weapon() with different weapon resources
##   - Store multiple weapons in an array
##
## Change fire pattern:
##   - Find: func _fire_weapon()
##   - Modify spread calculations, projectile positioning
##
## ============================================================================

@export var equipped_weapon: ProjectileWeaponResource
@export var projectile_scene: PackedScene

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var fire_point: Marker2D = $FirePoint

var fire_cooldown: float = 0.0
var nearest_enemy: Node2D = null


func _ready() -> void:
	# Load default weapon if equipped
	if equipped_weapon:
		_update_weapon_visuals()


func _process(delta: float) -> void:
	# Update fire cooldown timer
	if fire_cooldown > 0:
		fire_cooldown -= delta

	# Find nearest enemy
	nearest_enemy = _find_nearest_enemy()

	# Rotate to face nearest enemy
	if nearest_enemy:
		var direction_to_enemy = (nearest_enemy.global_position - global_position).normalized()
		rotation = direction_to_enemy.angle()

		# Flip sprite if aiming left
		if direction_to_enemy.x < 0:
			weapon_sprite.flip_v = true
		else:
			weapon_sprite.flip_v = false

		# Auto-fire if cooldown is ready
		if fire_cooldown <= 0 and equipped_weapon:
			_fire_weapon(direction_to_enemy)


## Find the closest enemy to the player
func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return null

	var closest_enemy: Node2D = null
	var closest_distance: float = INF

	for enemy in enemies:
		if enemy is Node2D:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy

	return closest_enemy


## Fire the equipped weapon
## Returns true if weapon was fired successfully
func _fire_weapon(direction: Vector2) -> bool:
	if not equipped_weapon or not projectile_scene:
		return false

	# Calculate spread based on accuracy
	var spread_rad = deg_to_rad(equipped_weapon.accuracy_spread)

	# Fire multiple projectiles if weapon has projectile_count > 1
	for i in range(equipped_weapon.projectile_count):
		var projectile_instance = projectile_scene.instantiate()

		# Calculate direction with spread
		var angle_offset = 0.0
		if equipped_weapon.projectile_count > 1:
			# Spread projectiles evenly
			var total_spread = deg_to_rad(equipped_weapon.spread_angle)
			angle_offset = -total_spread / 2.0 + (total_spread / (equipped_weapon.projectile_count - 1)) * i
		else:
			# Single projectile gets random spread
			angle_offset = randf_range(-spread_rad, spread_rad)

		var final_direction = direction.rotated(angle_offset)

		# Setup projectile
		projectile_instance.direction = final_direction
		projectile_instance.global_position = fire_point.global_position

		# Pass projectile resource to projectile
		if equipped_weapon.projectile_config:
			projectile_instance.setup(equipped_weapon.projectile_config)
		else:
			push_error("Weapon has no projectile_config set!")
			projectile_instance.queue_free()
			continue

		# Add to scene
		get_tree().root.add_child(projectile_instance)

	# Reset cooldown
	fire_cooldown = equipped_weapon.get_fire_cooldown() # COMMENT THIS LINE AND SHOOT REALLY FAST
	return true


## Equip a new weapon by loading a ProjectileWeaponResource
## Returns true if weapon was equipped successfully
func equip_weapon(weapon: ProjectileWeaponResource) -> bool:
	if not weapon:
		return false

	equipped_weapon = weapon
	_update_weapon_visuals()
	fire_cooldown = 0.0  # Reset cooldown when switching weapons
	return true


## Update the visual representation of the weapon
## Returns true if visuals were updated successfully
func _update_weapon_visuals() -> bool:
	if not equipped_weapon or not weapon_sprite:
		return false

	weapon_sprite.texture = equipped_weapon.weapon_sprite
	weapon_sprite.offset = equipped_weapon.hold_offset
	return true
