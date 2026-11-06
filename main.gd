extends Node
@export var mob_scene: PackedScene
var score = 0
var best_score = 0
var time_alive = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mob_scene = preload("res://arena_enemy.tscn")
	$MobPath.position = Vector2.ZERO
	$MobPath.scale = Vector2.ONE
	var edge = Curve2D.new()
	for point in [Vector2(0, 0), Vector2(480, 0), Vector2(480, 720), Vector2(0, 720), Vector2(0, 0)]:
		edge.add_point(point)
	$MobPath.curve = edge
	$HUD.start_game.connect(new_game)
	$Player.died.connect(game_over)
	$Player.health_changed.connect($HUD.update_health)
	$HUD.update_health($Player.max_health)
	$HUD.update_best(best_score)


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	if score > best_score:
		best_score = score
		$HUD.update_best(best_score)
	$HUD.show_game_over()
	
func new_game():
	score = 0
	time_alive = 0
	$MobTimer.wait_time = 1.2
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	$MobPath/MobSpawnLocation.progress_ratio = randf()
	mob.position = $MobPath/MobSpawnLocation.global_position
	mob.died.connect(_on_enemy_died)
	add_child(mob)
	
func _on_enemy_died() -> void:
	score += 5
	$HUD.update_score(score)


func _on_score_timer_timeout() -> void:
	time_alive += 1
	if time_alive % 20 == 0:
		$MobTimer.wait_time = max(0.35, $MobTimer.wait_time - 0.08)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
