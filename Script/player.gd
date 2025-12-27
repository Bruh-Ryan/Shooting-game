extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var IS_DYING : bool =false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum States { IDLE, RUNNING, JUMPING, FALLING, SHOOTING }
var state: States = States.IDLE


func _physics_process(delta: float) -> void:
	if IS_DYING:
		animated_sprite.play("dead_animation")
		return
	_apply_gravity(delta)
	_handle_input()
	_update_state()
	_apply_movement()
	_update_animation()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_input() -> void:
	# horizontal movement input
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	if Input.is_action_just_pressed("shoot") and is_on_floor_only():
		state = States.SHOOTING
		


func _update_state() -> void:
	# Vertical states first
	#if we are shooting, stay in this state until the animation finishes
	if state == States.SHOOTING :
		return
		
	if not is_on_floor():
		if velocity.y < 0:
			state = States.JUMPING
		else:
			state = States.FALLING
		return

	# On floor -> idle or running (unless shooting, attacking, etc.)
	if abs(velocity.x) > 0.1:
		state = States.RUNNING
	else:
		state = States.IDLE
	
func _apply_movement() -> void:
	move_and_slide()


func _update_animation() -> void:
	match state:
		States.IDLE:
			animated_sprite.play("idle_animation") #works
		States.RUNNING:
			animated_sprite.play("walk_animation") #works
		States.JUMPING:
			animated_sprite.play("jump_animation") #works  
		States.SHOOTING:
			animated_sprite.play("shoot_animation") #works
		States.SHOOTING:
			animated_sprite.play("fall_animation")    

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation=="shoot_animation":
		if abs(velocity.x) > 0.1:
			state = States.RUNNING
		else:
			state = States.IDLE
		
func on_killed(type: String) -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	if IS_DYING:
		return # Prevent double death
	
	IS_DYING = true

	match type:
		"enemy_bullet":
			animated_sprite.play("dead_animation")
		"environment":
			animated_sprite.play("dead_animation")
		_:
			animated_sprite.play("dead_animation")
