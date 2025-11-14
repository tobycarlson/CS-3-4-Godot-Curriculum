extends CanvasLayer
class_name HUD

## ============================================================================
## HUD - Heads-Up Display showing player stats
## ============================================================================
##
## WHAT THIS SCRIPT DOES:
## This script manages the player's HUD (health bar, XP bar, level display).
## It:
## - Connects to player signals (health_changed, xp_changed, level_up)
## - Updates progress bars when stats change
## - Displays current level and stats
##
## This script works with:
## - scripts/player.gd (receives signals from player)
## - scenes/ui/hud.tscn (the HUD UI scene)
##
## ============================================================================
## COMMON MODIFICATIONS:
## ============================================================================
##
## Add new stat displays:
##   - Add Label node in hud.tscn
##   - Get reference with @onready
##   - Connect to player signal or update in update_all_displays()
##
## Change bar colors:
##   - Edit hud.tscn
##   - Select ProgressBar node
##   - Modify Theme Overrides -> Styles
##
## Add health number display:
##   - Add Label for "100/100"
##   - Update in _on_health_changed()
##
## Add animations:
##   - Flash red when taking damage
##   - Pulse when leveling up
##   - Use Tween for smooth color changes
##
## ============================================================================

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/StatsContainer/LevelLabel
@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsContainer/StatsLabel

@onready var player: Player = %Player



func _ready() -> void:
	# Get player reference
	
	connect_player_signals()
	update_all_displays()


## Connect to player signals for automatic updates
func connect_player_signals() -> void:
	if not player:
		return

	player.health_changed.connect(_on_player_health_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.level_up.connect(_on_player_level_up)


## Update all HUD displays
func update_all_displays() -> void:
	if not player:
		return

	_on_player_health_changed(player.current_health, player.max_health)
	_on_player_xp_changed(player.current_xp, player.xp_to_next_level)
	_update_level_display()
	_update_stats_display()


func _on_player_health_changed(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

		# Update label
		var health_text = "Health: " + str(int(current)) + "/" + str(int(maximum))
		health_bar.get_node_or_null("Label").text = health_text if health_bar.get_node_or_null("Label") else ""


func _on_player_xp_changed(current: float, needed: float) -> void:
	if xp_bar:
		xp_bar.max_value = needed
		xp_bar.value = current

		# Update label
		var xp_text = "XP: " + str(int(current)) + "/" + str(int(needed))
		var label = xp_bar.get_node_or_null("Label")
		if label:
			label.text = xp_text


func _on_player_level_up(_new_level: int) -> void:
	_update_level_display()
	_update_stats_display()


func _update_level_display() -> void:
	if level_label and player:
		level_label.text = "Level: " + str(player.level)


func _update_stats_display() -> void:
	if stats_label and player:
		var stats_text = ""
		stats_text += "Speed: " + str(int(player.move_speed))
		stats_label.text = stats_text
