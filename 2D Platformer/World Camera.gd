extends Camera2D

var followingPlayer = true
var followMode = 0
var windowWidth = ProjectSettings.get_setting("display/window/size/width")
var windowHeight = ProjectSettings.get_setting("display/window/size/height")




func _process(delta):


	var player1 = "../Player"
	if get_node_or_null(player1) != null:
		if followingPlayer == true:
			match followMode:
				0:
					var cameraEnd = $"../TileMap".get_node("cameraEnd").position
					var cameraStart = $"../TileMap".get_node("cameraStart").position
					var offsetCamera = Vector2(windowWidth,windowHeight)/2
					# i swear this worked before
					position.x = clamp(get_node(player1).position.x, cameraStart.x + offsetCamera.x, cameraEnd.x - offsetCamera.x)
					position.y = clamp(get_node(player1).position.y, cameraStart.y + offsetCamera.y, cameraEnd.y - offsetCamera.y)
