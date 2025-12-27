extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var shoot_ray: RayCast2D = $Line_of_Sight
@onready var player: CharacterBody2D = $"../Player"
@onready var muzzle: Marker2D = $Marker2D

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

const SPEED := 70
const FIRING_SPEED := 1.0
const SHOOT_ANGLE:=35

var direction := 1
var is_shooting := false
var can_shoot := true # Cooldown gate

func _ready() -> void:
	shoot_ray.enabled = true

func _physics_process(delta: float) -> void:
	_on_sight()         
	_patrol(delta)      
	_update_animation() 

func _patrol(delta: float) -> void:
	if is_shooting:
		velocity.x = 0
		
		# 2. TRIGGER SHOOTING HERE
		if can_shoot:
			shoot()
			
		move_and_slide()
		return

	# Check wall collisions
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1

	# Update Visuals
	animated_sprite.flip_h = (direction == -1)
	shoot_ray.scale.x = direction
	
	# Flip muzzle so bullets come out the correct side
	if muzzle:
		muzzle.position.x = abs(muzzle.position.x) * direction

	# Movement
	velocity.x = SPEED * direction
	move_and_slide()

func _on_sight() -> void:
	
	if shoot_ray.is_colliding() and shoot_ray.get_collider() == player:
		#to play kill animation and if kill animation is playing then stop shooting
		if "IS_DYING" in player and player.IS_DYING:
			is_shooting = false
			return
		is_shooting = true
	else:
		is_shooting = false

func _update_animation() -> void:
	if is_shooting:
		animated_sprite.play("shoot_animation")
	else:
		animated_sprite.play("walk_animation")

# 3. THE NEW SHOOT FUNCTION
func shoot() -> void:
	can_shoot = false
	var new_bullet = BULLET_SCENE.instantiate()
	
	# Determine the bullet's movement vector
	var move_vector = Vector2.ZERO
	
	if muzzle:
		new_bullet.global_position = muzzle.global_position
		
		# 1. Create the diagonal vector (135 degrees)
		move_vector = Vector2.RIGHT.rotated(deg_to_rad(SHOOT_ANGLE))
		
		# 2. FLIP logic: If enemy faces Left (-1), flip the vector so it shoots forward
		if direction == -1:
			move_vector.x *= -1 # Mirrors the shot to the left
			
	else:
		new_bullet.global_position = global_position
		# Default horizontal shot if no muzzle
		move_vector = Vector2.RIGHT if direction == 1 else Vector2.LEFT

	# Apply the calculated vector to the bullet
	new_bullet.direction = move_vector
	new_bullet.rotation = move_vector.angle()
	
	get_parent().add_child(new_bullet)
	await get_tree().create_timer(FIRING_SPEED).timeout
	can_shoot = true
