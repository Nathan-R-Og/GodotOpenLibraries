extends Node2D


var entered = 0


var tempo = 0.0
var beatDelays = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var fakeTimer = 0.0
var saveBeat = 0
var normalBeat = 0
var slamToggle = true


var playing = false


var slamCamera = false
var cameraActives = []
var cameraActivesIterate = 0
var cameraRange = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	tempo = 120.0
	#quarter
	beatDelays[0] = 60.0/tempo
	#half
	beatDelays[1] = 120.0/tempo
	#whole
	beatDelays[2] = 240.0/tempo
	#eigth
	beatDelays[3] = 30.0/tempo
	#sixteenth
	beatDelays[4] = 15.0/tempo

	cameraActives = [[0,288,false,null,null]]
func _process(delta):
	if playing == true:
		_normalProcess(delta)
	else:
		pass

func _normalProcess(delta):
	$thing.position.x -= 0.001 * 200
	fakeTimer += delta
	var quarterBeat = floor(fakeTimer / beatDelays[0])
	normalBeat = quarterBeat
	var halfBeat = floor(fakeTimer / beatDelays[1])
	var wholeBeat = floor(fakeTimer / beatDelays[2])
	var eigthBeat = floor(fakeTimer / beatDelays[3])
	var sixteenthBeat = floor(fakeTimer / beatDelays[4])
	cameraRange = quarterBeat
	if cameraActivesIterate < cameraActives.size() - 1:
		if cameraRange >= cameraActives[cameraActivesIterate][1]:
			cameraActivesIterate += 1
	if cameraRange < cameraActives[cameraActivesIterate][1]:
		if cameraRange >= 290:
			
			
			
			
			pass
		slamCamera = cameraActives[cameraActivesIterate][2]

	var toggleBeat = 1
	if int(quarterBeat) % toggleBeat == 0 and slamToggle == true:
		_cameraLols()
		$CanvasLayer/Label.text = String(fakeTimer)
		$thing.position.x = 1 * 200
		slamToggle = false
		$AudioStreamPlayer.play()
		saveBeat = quarterBeat
	elif quarterBeat == saveBeat + toggleBeat:
		slamToggle = true
		$Camera/AnimationPlayer.stop()
	if Input.is_action_just_pressed("accept"):
		var delay = (fakeTimer - float($CanvasLayer/Label.text))
		if delay > 0.10:
			print("bad")
		if delay <= 0.10:
			print("good")

	if $Camera/AnimationPlayer.is_playing() == false:
		$Camera.zoom = Vector2(1,1)

func _cameraLols():
	
	if slamCamera == true:
		var newAnim = $Camera/AnimationPlayer.get_animation("New Anim")
		newAnim.loop = false
		newAnim.length = 2.0
		newAnim.track_set_key_value(0,0,cameraActives[cameraActivesIterate][4])
		newAnim.track_set_key_time(0,1,cameraActives[cameraActivesIterate][3])
		$Camera/AnimationPlayer.play("New Anim")





func _on_Button_pressed():
	playing = true
	$Button.hide()
	$AudioStreamPlayer2.play()
