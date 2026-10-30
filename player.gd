extends Area2D
signal health_changed(new_health)
signal died

@export var speed = 400
@export var max_health = 5
var screen_size
var health = max_health
var invulnerable = false
var can_shoot = true
var projectile_scene = preload("res://projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2
	$ShootCooldown.wait_time = 0.25
	$ShootCooldown.one_shot = true
	$ShootCooldown.timeout.connect(_on_shoot_cooldown_timeout)
	$InvulnTimer.wait_time = 1.0
	$InvulnTimer.one_shot = true
	$InvulnTimer.timeout.connect(_on_invuln_timer_timeout)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
	elif velocity.x == 0 and velocity.y == 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = false
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot and visible:
		shoot()
		
func start(pos):
	position = pos
	health = max_health
	invulnerable = false
	modulate.a = 1.0
	health_changed.emit(health)
	show()
	$CollisionShape2D.disabled = false
	
func take_damage(amount: int) -> void:
	if invulnerable or not visible:
		return
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		died.emit()
		return
	invulnerable = true
	modulate.a = 0.5
	$InvulnTimer.start()
	
func shoot() -> void:
	can_shoot = false
	$ShootCooldown.start()
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	projectile.direction = global_position.direction_to(get_global_mouse_position())
	get_parent().add_child(projectile)
	
func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true
	
func _on_invuln_timer_timeout() -> void:
	invulnerable = false
	modulate.a = 1.0
