extends CanvasLayer
signal start_game


func _ready() -> void:
	$MessageTimer.one_shot = true
	var font = preload("res://fonts/Xolonium-Regular.ttf")
	for label in [$HealthLabel, $BestLabel]:
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 24)
	$HealthLabel.position = Vector2(12, 12)
	$BestLabel.position = Vector2(12, 44)
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$Message.text = "Last Man Standing"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_health(new_health):
	$HealthLabel.text = "HP: " + str(new_health)
	
func update_best(value):
	$BestLabel.text = "Best: " + str(value)
	

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()
	

func _on_message_timer_timeout() -> void:
	$Message.hide()
