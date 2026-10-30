extends Area2D

@export var speed = 700
var direction = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	var circle = CircleShape2D.new()
	circle.radius = 6
	$CollisionShape2D.shape = circle
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().has_point(position):
		queue_free()
		
func _draw() -> void:
	draw_circle(Vector2.ZERO, 6, Color.RED)
	
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
	queue_free()
