extends Node2D



var amount = 0
var choices = []
var wait = false
var fuckYouFlag = 0
var windowWidth = 0
var windowHieght = 0
var middle = Vector2()
var option = 0
var branch = -1


func _ready():
	windowWidth = ProjectSettings.get_setting("display/window/size/width")
	windowHieght = ProjectSettings.get_setting("display/window/size/height")
	#set middle for each window size
	middle = Vector2(windowWidth/2, windowHieght/2)



func _process(delta):
	if wait == true:
		fuckYouFlag = 0
		if ($"../RichTextLabel".get_total_character_count() == $"../RichTextLabel".visible_characters) and $"../RichTextLabel".get_total_character_count() > 0 and fuckYouFlag == 0 and get_parent().visible == true:
			fuckYouFlag += 1
			wait = false

	if fuckYouFlag == 1:
		fuckYouFlag += 1
		_option()
		option = 1


	if $Options.get_child_count() > 0:
		if fuckYouFlag == 2:
			var i = 0
			while i < $Options.get_child_count():
				$Options.get_child(i).connect("tellChoices",self,"click")
				i += 1
			fuckYouFlag += 1


func _option():
	var i = 0
	while i < amount:
		var option = preload("res://Typewriter Text/textFunctions/option.tscn").instance()
		$Options.add_child(option)
		if amount < 4:
			var clearance = (windowWidth/amount)
			var goodOrNot = clearance % amount
			var offsetOdd = 0
			var offset = 0
			if goodOrNot != 0:
				offsetOdd = clearance / goodOrNot
			else:
				offset = clearance / amount
			option.position.x = (clearance*i) + offset + offsetOdd
			option.position.y = middle.y
		if amount == 4:
			var clearance = (windowWidth/amount)
			var goodOrNot = clearance % amount
			var offsetOdd = 0
			var offset = 0
			if goodOrNot != 0:
				offsetOdd = clearance / goodOrNot
			else:
				offset = clearance / amount
			option.position.x = ((clearance*i) + offset + offsetOdd) + option.get_node("AnimatedSprite").frames.get_frame(option.get_node("AnimatedSprite").animation, option.get_node("AnimatedSprite").frame).get_size().x
			option.position.y = middle.y
		option.get_node("Label").text = choices[i]
		i += 1
		print("add" + String(i))

func _on_Stage_choices(textArray):
	amount = textArray.size()
	choices = textArray
	wait = true


func _skip(syntax):
	if syntax != "":
		var Stage = get_parent()
		Stage.branch = String(branch) + "/" + Stage.fileName + String(branch) + syntax + "/"  + Stage.fileName + String(branch) + syntax
		Stage._textInit()

func click(node):
	branch = node.get_index()
	var i = $Options.get_child_count()
	while i > -1 :
		print("removed " + String(i))
		$Options.remove_child($Options.get_child(i))
		i -= 1
	var Stage = get_parent()
	Stage.branch = String(branch) + "/" + Stage.fileName + String(branch)
	Stage._textInit()
