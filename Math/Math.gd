extends Node2D






var answer = ""
var constant1 = 9999999999999
var constant2 = 9999999999999
var dividingMultiplier = 9999999999999
var equation = ""
var iterate = 0
var op1 = ""
var opRand1 = 0
var points = 0

var rng = RandomNumberGenerator.new()

var fakeConstant1 = 0 
var fakeConstant2 = 0


var enable = false



var playerEntry = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 0
	_make_equation()
func _process(delta):
	$points.text = String(points)
	$entry.editable = enable

func _make_equation():
	$question.text = ""
	$entry.text = ""
	enable = false
	rng.randomize()
	opRand1 = rng.randi_range(1,5)
	match opRand1:
#addition
		1:
			op1 = "+"
			constant1 = rng.randi_range(1,10)
			dividingMultiplier = 0
			constant2 = rng.randi_range(1,10)
			answer = constant1 + constant2
#subtraction
		2:
			op1 = "-"
			constant1 = rng.randi_range(1,10)
			dividingMultiplier = 0
			constant2 = rng.randi_range(1,10)
			answer = constant1 - constant2
#multiplication
		3:
			op1 = "*"
			constant1 = rng.randi_range(1,10)
			dividingMultiplier = 0
			constant2 = rng.randi_range(1,10)
			answer = constant1 * constant2
#division, simple simplifying
		4:
			op1 = "/"
			constant1 = rng.randi_range(1,10)
			dividingMultiplier = rng.randi_range(1,10)
			constant2 = rng.randi_range(1,10)
			answer = constant1 / constant2
#division, heavy simplifying
		5:
			op1 = "/"
			constant1 = rng.randi_range(1,100)
			constant2 = rng.randi_range(1,100)
			answer = constant1 / constant2
	equation = String(constant1) + op1 + String(constant2)
	$question.text = equation
	enable = true



func _on_entry_text_entered(new_text):
	playerEntry = new_text
	if opRand1 == 4 or opRand1 == 5:
		_simplify_fraction()
		_give_points()
	else:
		_give_points()

func _simplify_fraction():
	if (String(constant1)).length() > (String(constant2)).length():
		iterate = (3*(10*((String(constant1)).length())))
	else:
		iterate = (3*(10*((String(constant2)).length())))
	while iterate > 1:
		if (constant1 % iterate) == 0 and (constant2 % iterate) == 0:
			constant1 = (constant1 / iterate)
			constant2 = (constant2 / iterate)
			_simplify_fraction()
		else:
			iterate -= 1





func _give_points():
	
	if (playerEntry == String(answer)) or (playerEntry == (String(constant1) + "/" + String(constant2))):
		points = points + 1
	else:
		points = points - 1
	enable = false
	_make_equation()
	
