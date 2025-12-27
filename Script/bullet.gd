extends Area2D # Or CharacterBody2D, root node

const SPEED = 400
var direction : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	# Move along the X axis based on direction
	translate(direction*delta*SPEED)

# Delete bullet if it leaves the screen or hits something
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		queue_free()
		return
		
	# Trigger the death animation/logic on the Player
	if body.has_method("on_killed"):
		body.on_killed("Bullet") # Telling player they died by 'Bullet'
		
	set_physics_process(false)
	await get_tree().create_timer(1).timeout # 6. RELOAD the level
	get_tree().reload_current_scene()
	queue_free()
