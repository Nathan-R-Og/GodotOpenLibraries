extends KinematicBody2D



#player variables
var money = 0
var powerUp = 0
var direction = "right"
var bullets = 0











####pre loads


const bulletInstance = preload("res://2D Platformer/Player/powerup/Gun/bullet.tscn")
const gunInstance = preload("res://2D Platformer/Player/powerup/Gun/Gun.tscn")






####physics


var WALK_FORCE = 1000
var WALK_MAX_SPEED = 400
var STOP_FORCE = 2000
var baseGravity = 1500
var gravity = 1500
var JUMP_SPEED = gravity * .3
var snap_vector = Vector2.DOWN




var movementType = 1
var deadMoved = false
var spinBro = false
var spinSpeed = 0
var moving = false
var winFlag = false
var tweened = false
var movespeed = 10
var distance = Vector2()


var animationTimerRaw = 0.0
var animationTimer = 0

var velocity = Vector2()
#jumpstuff
var jumps = 0
var jumping = false
var baseJumps = 1
var jumpHold = 0.0
var jumpHoldInc = 510.597
var framesPerSecond = Performance.get_monitor(Performance.TIME_FPS)

var walkFlag = false

var swimming = false

var selfLight = false

var swingSpeed = 7.0
var thrown = false

func _ready():
	pass



func _physics_process(delta):
#Basic Movement
	if movementType == 1:
		#basic left right strength amplified by walk force
		var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		#slow down if not wanting to move
		if abs(walk) < STOP_FORCE * 0.2:
			velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
		#clamp to limits
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

		#gravity * delta = velocity (basic physics)
		velocity.y += gravity * delta

		#move
		if is_on_floor():
			#control just the up and down so slopes work
			velocity.y = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true, 4, deg2rad(45.0001)).y
		else:
			#control both so wall collisions delete force
			velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true, 4, deg2rad(45.0001))


		#set jumps to base and jumphold to 0
		if is_on_floor():
			#do basic reset
			jumping = false
			snap_vector = Vector2.DOWN * 16.0
			thrown = false
			jumps = baseJumps
			jumpHold = 0
		#for the first jump check if its on the floor and not already jumping
		if Input.is_action_just_pressed("accept") and jumps == baseJumps and is_on_floor() and jumping == false:
			jumping = true
			snap_vector = Vector2(0,0)
			#sound
			$JumpSound.play()
			#apply upwards impulse
			velocity.y = -JUMP_SPEED
			#take off a jump
			jumps -= 1
		#if it is no longer on the floor and pressed jump, if we have more jumps left then you are allowed to use them
		elif Input.is_action_just_pressed("accept") and jumps > 0 and jumps < baseJumps and jumping == true: 
			$JumpSound.play()
			velocity.y = -JUMP_SPEED
			jumps -= 1
		#jumphold (might need work)
		if Input.is_action_pressed("accept") and velocity.y < 0:
			#increment based on clamp, so you dont go flying
			jumpHold = clamp(jumpHold + ((delta/4.5)* jumpHoldInc), 0 , 15)
			#apply impulse
			velocity.y -= jumpHold



#powerups
		match powerUp:
			1:
				#bullet
				if Input.is_action_just_pressed("decline"):
					if bullets < 3:
						var bullet = bulletInstance.instance()
						get_parent().add_child(bullet)
						bullets += 1
				var gun = gunInstance.instance()
				if get_node_or_null("Gun") == null:
					add_child(gun)
				var newGun = get_node("Gun")
				#visual offsets
				#you can preface this with an if to change it depending on animation and stuff
				var newGunSprite = newGun.get_node("gunSprite")
				match direction:
					"right":
						newGun.position.x = 30
						newGun.position.y = 0
						newGun.rotation_degrees = 0
						newGunSprite.flip_h = false
					"left":
						newGun.position.x = -31
						newGun.position.y = 0
						newGun.rotation_degrees = 0
						newGunSprite.flip_h = true
					"up":
						newGun.position.x = 0
						newGun.position.y = -32
						newGun.rotation_degrees = -90
						newGunSprite.flip_h = false
					"down":
						newGun.position.x = 0
						newGun.position.y = 32
						newGun.rotation_degrees = 90
						newGunSprite.flip_h = false

#get rid of powerup if not current
		if powerUp != 1:
			if get_node_or_null("Gun") != null:
					get_node("Gun").queue_free()









#  animations


		#set directions
		if Input.is_action_pressed("move_right"):
			direction = "right"
		if Input.is_action_pressed("move_left"):
			direction = "left"


#flip based on direction
		if direction == "right":
			$PlayerSprite.flip_h = false
		if direction == "left":
			$PlayerSprite.flip_h = true



		#just to check for prioritizing
		if $PlayerSprite.animation != "Skid":
			#walking
			if velocity.x != 0 and abs(velocity.x) < 390 and is_on_floor() == true:
				$PlayerSprite.play("Walking")
			#running
			if velocity.x != 0 and abs(velocity.x) >= 390 and is_on_floor() == true:
				$PlayerSprite.play("Running")
			#walk sound (like a footstep or something)
			if ($PlayerSprite.animation == "Walking" or $PlayerSprite.animation == "Running") and $PlayerSprite.frame == 0 and walkFlag == false:
				#put a flag so it doesnt repeat 50000 times
				walkFlag = true
				$WalkSound.play()
			if ($PlayerSprite.animation == "Walking" or $PlayerSprite.animation == "Running") and $PlayerSprite.frame == 1 and walkFlag == true:
				walkFlag = false
			#skid
			if (velocity.x > 0 and walk < 0) or (velocity.x < 0 and walk > 0) and is_on_floor() == true:
				#need another check for some god forsaken reason
				if is_on_floor() == true:
					$PlayerSprite.frame = 0
					$PlayerSprite.animation = "Skid"
			#idle
			if velocity.x == 0 and is_on_floor():
				walkFlag = false
				$PlayerSprite.play("Idle")
				match $PlayerSprite.flip_h:
					true:
						direction = "left"
					false:
						direction = "right"
		#revert back to no priority after finishing
		elif $PlayerSprite.frame == $PlayerSprite.frames.get_frame_count("Skid") - 1:
			walkFlag = false
			$PlayerSprite.animation = "Idle"
		#jump
		if floor(velocity.y) < 0 and jumping == true and is_on_floor() == false:
			$PlayerSprite.play("Jumping")
		# falling
		if floor(velocity.y) > 0 and is_on_floor() == false:
			$PlayerSprite.play("Falling")
		#up and downs
		if is_on_floor() and velocity.x == 0 and velocity.y == 0:
			if Input.is_action_pressed("move_down"):
				$PlayerSprite.play("Looking Down")
				direction = "down"
			if Input.is_action_pressed("move_up"):
				$PlayerSprite.play("Looking Up")
				direction = "up"
		else:
			if Input.is_action_pressed("move_down"):
				direction = "down"
			if Input.is_action_pressed("move_up"):
				direction = "up"




#Dead Movement - BYE BYE!
	if movementType == 2:
		$CollisionShape2D.disabled = true
		$EnemyBounceArea/EnemyCollision.disabled = true
		$PlayerSprite.animation = "Die"
		#copy paste to a new version with correct coords
		var newAnim = Animation.new()
		$AnimationPlayer.add_animation("newDie", newAnim)
		$AnimationPlayer.get_animation("Die").copy_track(0, newAnim)
		newAnim.track_set_key_value(0,0,Vector2(position.x, position.y))
		newAnim.track_set_key_value(0,1,Vector2(position.x, position.y - 100))
		newAnim.track_set_key_value(0,2,Vector2(position.x, position.y + 300))
		$AnimationPlayer.play("newDie")
		

#Win movement
	if movementType == 3:
		if winFlag == false:
			var walk = WALK_FORCE * 0
			if abs(walk) < WALK_FORCE * 0.2:
				velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
			else:
				velocity.x += walk * delta
			velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
			velocity.y += gravity * delta



# animation so it can actually come to rest
			if Input.is_action_pressed("move_left"):
				$PlayerSprite.flip_h = true

			if Input.is_action_pressed("move_right"):
				$PlayerSprite.flip_h = false

			if velocity.x != 0 and abs(velocity.x) < 390 and velocity.y == 0:
				$PlayerSprite.play("Walking")

			if velocity.x != 0 and abs(velocity.x) >= 390  and velocity.y == 0:
				$PlayerSprite.play("Walking")

			if $PlayerSprite.animation == "Walking" and $PlayerSprite.frame == 0 and walkFlag == false:
				walkFlag = true
				$WalkSound.play()

			if $PlayerSprite.animation == "Walking" and $PlayerSprite.frame == 1 and walkFlag == true:
				walkFlag = false

			if velocity.x == 0 and is_on_floor():
				$PlayerSprite.animation = "Idle"
				$PlayerSprite.stop()

			if floor(velocity.y) < 0:
				$PlayerSprite.play("Jumping")

			if floor(velocity.y) > 0:
				$PlayerSprite.play("Falling")


			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)




		if velocity.x == 0 and velocity.y == 0:
			winFlag = true
			$PlayerSprite.play("Win")
			get_parent()._wingle()
			if $PlayerSprite.animation == "Win" and $PlayerSprite.frame == 44:
				movementType = 5
				$PlayerSprite.stop()


#Static Movement with gravity and reet
	if movementType == 4:
		velocity.y += gravity * delta
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

# literally static movement
	if movementType == 5:
		pass

#die
func _die():
	$DeathSound.play()
	movementType = 2

#finish level exec
func _on_Area2D_body_entered(_body):
	movementType = 3




#jump off of enemy (execute this after jumping on an enemy)
func _bounceEnemy(impusle):
	velocity.y = -impusle
	jumpHold = 0



#powerUpS
