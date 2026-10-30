extends Area2D
signal died

@export var speed = 130
var health = 3
var target: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	$AnimatedSprite2D.play("walk")
	
	var circle = CircleShape2D.new()
	circle.radius = 22
	$CollisionShape2D.shape = circle
	
	area_entered.connect(_on_area_entered)
	target = get_tree().get_first_node_in_group("player")
	add_to_group("mobs")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target == null:
		return
		
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	
func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	if health <= 0:
		died.emit()
		queue_free()
		
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()
