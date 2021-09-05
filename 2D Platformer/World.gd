extends Node2D





func _process(delta):
	#debug
	if Input.is_key_pressed(KEY_0):
		$Player.powerUp = 0
	if Input.is_key_pressed(KEY_1):
		$Player.powerUp = 1
