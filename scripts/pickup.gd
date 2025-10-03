# This next line allows the color of the coin to update without running the game
# It can mostly be ignored, but it must be the first line of the script
@tool

extends Area2D
class_name pickup

@export var color: Color
@export var amount : int = 1
@export var type : String = ""
@export var label : String = ""
@export var auto_pickup : bool = true
var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Set the color of the pickup
	if $AnimatedSprite2D.material != null:
		$AnimatedSprite2D.material.set_shader_parameter("color", color)
	configure_pickup(type, label)

func _process(_delta: float) -> void:
	
	pass

func _on_body_entered(body):
	if collected == false:
		if body is Player:
			collected = true
			body.collect_pickup(type, amount)
			# Remove the potion after use
			if auto_pickup:
				if $AnimationPlayer.has_animation("disappear"):
					$AnimationPlayer.play("disappear")
				else: queue_free()
			else:
				pass

func configure_pickup(_type : String, _label : String) -> bool:
	if _type == "coin":
		if _label == "copper":
			amount = 1
			return true
		elif _label == "silver":
			amount = 5
			return true
		elif _label == "gold":
			amount = 10
			return true
		else: return false
	elif _type == "health_potion":
		if _label == "small":
			amount = 5
			return true
		elif _label == "large":
			amount = 100
			return true
		else: return false
	else: return false
		
			
			
