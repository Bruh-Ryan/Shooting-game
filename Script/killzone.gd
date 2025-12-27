extends Area2D

@onready var timer: Timer = $Timer

var victim: Node = null
var kill_type := ""


func kill(body: Node, type: String) -> void:
	if victim != null:
		return   # prevent double kills

	victim = body
	kill_type = type

	if body.has_method("on_killed"):
		body.on_killed(type)

	timer.start()


func _on_body_entered(body: Node) -> void:
	kill(body, "environment")


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
