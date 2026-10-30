extends Node
@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mob_scene = preload("res://arena_enemy.tscn")
	$HUD.start_game.connect(new_game)
	$Player.died.connect(game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	
func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")


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
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
