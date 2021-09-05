extends Area2D





var despawnRange = 1000.0

var xSpeed = 0.0
var direction = ""
var directionMod = 0

var windowWidth = ProjectSettings.get_setting("display/window/size/width")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move
	position.x = position.x + (xSpeed * directionMod)
	
	
	#destroy!!!
	if $bulletSprite.frame == 3:
		$"../Player".bullets -= 1
		queue_free()
	
	
	#delete it anyways if it gets too far without hitting something, kinda annoying but funny in retrospect
	var offsetUhhh = 0
	if get_node_or_null("../World Camera") != null:
		offsetUhhh = $"../Player".position.x - $"../World Camera".position.x
	else:
		offsetUhhh = $"../Player".position.x  - int(windowWidth)
	despawnRange = int(windowWidth)/2 - offsetUhhh
	if position.x - despawnRange > $"../Player".position.x:
		$"../Player".bullets -= 1
		queue_free()
	elif position.x + despawnRange < $"../Player".position.x:
		$"../Player".bullets -= 1
		queue_free()

	
func _enter_tree():
	#set direction coorelated to playter
	direction = $"../Player".get_node("PlayerSprite").flip_h
	#init speed
	xSpeed = 10
	#set init position to player
	#set mod to direction accordingly
	$bulletSprite.flip_h = direction
	match direction:
		false:
			position = $"../Player".position + Vector2(8,0)
			directionMod = 1
		true:
			position = $"../Player".position + Vector2(-8,0)
			directionMod = -1




func _splode():
	directionMod = 0
	$bulletSprite.play("Explode")





func _on_bullet_body_entered(body):
	if body.name != "Player":
		_splode()


func _on_bullet_area_entered(area):
	if area.name == "DeathDetector":
		_splode()
