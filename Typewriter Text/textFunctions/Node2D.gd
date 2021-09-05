extends Node2D
var fakeTimer = 0.0
var typing = false
var totalChars = 0


signal itemMove(location, item)
signal choices(textArray)
signal customCommand(syntax)
signal doClose()


var arraysOfArrays = []

var chars = 0
var charSpeed = 1
var timerSpeed = 1
var timerReady = false

var dialogueArray = []
var fileName = ""
var fileSource = ""
var file = ""
var index = 0
var branch = ""


var waitPos = 0
var waitLast = 0
var waitCharSize = 0
var waitLength = 0.0
var waitTotal = ""
var dramaticWait = false
var posInTriggerArray = 0
var endStartMeta = 0

var animationPos = 0
var animationLast = 0
var animationCharSize = 0
var animationType =""
var animationTotal = ""
var animationCharacterArray = [999999]
var posInAnimation = 0
var endStartMetaAnimation = 0
var animationArrayIndex = 0




var globalTriggerTypeArray = [999999]
var globalTriggerArray = [999999]
var globalTraitArray = [9999999]

var VoiceActing = false
var booping = false
var boopSFXName = ""



var globalNonMetaArray = [999999]
var globalNonMetaTriggerArray = [999]
var globalNonMetaDetailArray = [9999]
var posInNonMeta = 0




# Called when the node enters the scene tree for the first time.
func _ready():
	var i = $characters.get_child_count()
	while i > 0:
		$characters.get_child(i - 1).animation = "blank"
		i -= 1
	#user choice
	VoiceActing = false
	booping = true
	boopSFXName = ""
	#timer change ready
	timerReady = true
	#init speeds
	timerSpeed = 0.07
	charSpeed = 0.5
	#directory file
	fileName = ""
	#os checker
	if OS.get_name() != "HTML5":
		$RichTextLabel.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")



func _process(delta):



	if typing == true:
		fakeTimer += (1.0/60.0)
	#always set the amount of visible characters to the char variable
	$RichTextLabel.visible_characters = chars

#if next, move index up one and run text load again
	if Input.is_action_just_pressed("accept") and dramaticWait == false:
		if index < dialogueArray.size() -1:
			index += 1
			_textRun()
		elif index == dialogueArray.size() - 1 and chars != $RichTextLabel.get_total_character_count():
			chars = $RichTextLabel.get_total_character_count()
		elif index == dialogueArray.size() - 1 and chars == $RichTextLabel.get_total_character_count():
			textClose()


#if none of the conditions are met, typewrite a character(s)
	if chars < $RichTextLabel.get_total_character_count():
		if dramaticWait == false:
			if not Input.is_action_just_pressed("accept"):
				chars += 1.0 * (charSpeed)



#if a flag exists in the array, check if the amount of characters is at that point and do it
	if globalTriggerArray.empty() == false:
		if $RichTextLabel.visible_characters >= globalTriggerArray[posInTriggerArray]:
			match globalTriggerTypeArray[posInTriggerArray]:
				"wait":
					if dramaticWait == false:
						dramaticWait = true
						$TextWaitTimer.start(globalTraitArray[posInTriggerArray])
				"animation":
					get_node("characters/char" + String(int(animationCharacterArray[posInTriggerArray]))).play(globalTraitArray[posInTriggerArray])
					posInTriggerArray += 1
				"animFX":
					var destCharacter = get_node("characters/char" + String(int(animationCharacterArray[posInTriggerArray])))
					match globalTraitArray[posInTriggerArray]:
						"stop":
							destCharacter.frame = destCharacter.frames.get_frame_count(destCharacter.animation)
							destCharacter.stop()
						"play":
							destCharacter.play()
					posInTriggerArray += 1
				"sfx":
					boopSFXName = globalTraitArray[posInTriggerArray]
					var boopSFXpath = "res://sfx/" + boopSFXName + ".wav"
					var sfx = load(boopSFXpath)
					$AudioStreamPlayer.stream = sfx
					posInTriggerArray += 1
				"charName":
					$name.text = globalTraitArray[posInTriggerArray]
					posInTriggerArray += 1
	if globalNonMetaTriggerArray.empty() == false:
		if index == globalNonMetaTriggerArray[posInNonMeta]:
			match globalNonMetaArray[posInNonMeta]:
				"Item":
					emit_signal("itemMove", "in", globalNonMetaDetailArray[posInNonMeta])
				"Item_Remove":
					emit_signal("itemMove", "out", globalNonMetaDetailArray[posInNonMeta])
				"Branch":
					emit_signal("choices", globalNonMetaDetailArray[posInNonMeta])
				"custom_command":
					emit_signal("customCommand", globalNonMetaDetailArray[posInNonMeta])
			posInNonMeta += 1






#text blip
	if not chars >= $RichTextLabel.get_total_character_count():
		if timerReady == true:
			if dramaticWait == false:
				if VoiceActing == false and booping == true:
					timerReady = false
					$AudioStreamPlayer.play()
					$SoundTimer.start(timerSpeed)





func _dumpCommands():
	if (dialogueArray.count(">command=")) > 0:
		var i = (dialogueArray.count(">command="))
		while i > 0:
			while (dialogueArray.find("Item")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = dialogueArray[area + 2]
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("Item_Remove")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = dialogueArray[area + 2]
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("Branch")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var decisions = int(dialogueArray[area + 2])
				var commandTrait = []
				var decisionIterate = 1
				while decisionIterate < decisions+1:
					commandTrait.append(dialogueArray[area + 2 + decisionIterate])
					decisionIterate += 1
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				decisionIterate = decisions
				while decisionIterate > 0:
					dialogueArray.remove(area + 2 + decisionIterate)
					decisionIterate -= 1
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("custom_command")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = []
				var howManyTraits = int(dialogueArray[area + 2])
				var iterate = 1
				while iterate < howManyTraits + 1:
					commandTrait.append(dialogueArray[area + 2 + iterate])
					iterate += 1
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area - 1)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				while iterate > 0:
					dialogueArray.remove(area + 2 + iterate)
					iterate -= 1
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1





func _textRun():
	chars = 0
	$RichTextLabel.visible_characters = chars
	$RichTextLabel.clear()
	#reset the autotimer
	fakeTimer = 0
	#ready the timer
	timerReady = true
	dramaticWait = false
	#index 0 in the array
	posInTriggerArray = 0
	animationArrayIndex = 0
	_dumpCommands()
	#index the metas into its proper arrays
	_metaDataDraw()
	#parse the parsable code
	$RichTextLabel.parse_bbcode(dialogueArray[index])
	$RichTextLabel.push_align(1)
	#check if the voiceacting flag is on, and if so apply soundfile per index
	if VoiceActing == true:
		$AudioStreamPlayer.stop()
		var audio_file = "res://text/" + fileName + "/" + branch + String(index) + ".wav"
		var sfx = load(audio_file)
		$AudioStreamPlayer.stream = sfx
		$AudioStreamPlayer.play()
	


#first time
func _textInit():
	_loadfile()
	index = 0
	_textRun()

#if click link open
func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)

#send all the dialogue to a single array (using a txt file)
#make sure to set .txt as one of the things exported when finishing a project, or else these will not render
func _loadfile():
	if fileSource == "":
		fileSource = "res://text/"
	file = fileSource + fileName + "/" + fileName + branch + ".txt"
	dialogueArray.clear()
	var fileObject = File.new()
	fileObject.open(file, File.READ)
	while not fileObject.eof_reached():
		var line = fileObject.get_line()
		dialogueArray.append(line)


func _metaDataDraw():
	#we need a placeholder so it doesnt error when there is nothing else to iterate over
	var placeholderNumber = 999999999
	globalTriggerArray.clear()
	globalTriggerArray.append(placeholderNumber)
	globalTraitArray.clear()
	globalTraitArray.append(placeholderNumber)
	globalTriggerTypeArray.clear()
	globalTriggerTypeArray.append(placeholderNumber)
	animationCharacterArray.clear()
	animationCharacterArray.append(placeholderNumber)
	#if there even is any continue
	var i = dialogueArray[index].count("{", 0, dialogueArray[index].length())
	while i > 0:
		var metaDataArrayLog = []
		var j = dialogueArray[index].count("{/wait", 0, dialogueArray[index].length())
		var jInstance = dialogueArray[index].find("{/wait")
		var k = dialogueArray[index].count("{/animation", 0, dialogueArray[index].length())
		var kInstance = dialogueArray[index].find("{/animation")
		var l = dialogueArray[index].count("{/sfx", 0, dialogueArray[index].length())
		var lInstance = dialogueArray[index].find("{/sfx")
		var m = dialogueArray[index].count("{/charName", 0, dialogueArray[index].length())
		var mInstance = dialogueArray[index].find("{/charName")
		var n = dialogueArray[index].count("{/animFX", 0, dialogueArray[index].length())
		var nInstance = dialogueArray[index].find("{/animFX")
		metaDataArrayLog.append([jInstance,0])
		metaDataArrayLog.append([kInstance,1])
		metaDataArrayLog.append([lInstance,2])
		metaDataArrayLog.append([mInstance,3])
		metaDataArrayLog.append([nInstance,4])
		var foundOne = false
		var baseIterate = 0
		var iterateInside = 0
		var current = ""
		while baseIterate < dialogueArray[index].length() and foundOne == false:
			while iterateInside < metaDataArrayLog.size() and foundOne == false:
				if baseIterate == metaDataArrayLog[iterateInside][0]:
					match metaDataArrayLog[iterateInside][1]:
						0:
							current = "wait"
						1:
							current = "animation"
						2:
							current = "sfx"
						3:
							current = "charName"
						4:
							current = "animFX"
					foundOne = true
					metaDataArrayLog.clear()
					break
				iterateInside += 1
			iterateInside = 0
			baseIterate += 1
		baseIterate = 0
		match current:
			"wait":
				_indexWait()
				j -= 1
			"animation":
				_indexAnimation()
				k -= 1
			"sfx":
				_indexSFX()
				l -= 1
			"charName":
				_indexCharName()
				m -= 1
			"animFX":
				_indexAnimationEffect()
				n -= 1
		i -= 1

#for each new metadata you would like to add, basically copy paste a new one and follow the order. then increment each variable name and associated tags.


func _indexWait():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "wait")
	#wait pos = the front
	waitPos = dialogueArray[index].findn("{/wait=", 0)
	#wait last = the back
	waitLast = dialogueArray[index].findn("}", waitPos)
	#the length of the wait command in characters
	waitCharSize = (waitLast - (waitPos+7))
	#the length of the wait command in seconds
	waitLength = float(dialogueArray[index].substr(waitPos + 7, waitCharSize))
	#the string of the wait command itself (not counting duplicates)
	waitTotal = dialogueArray[index].substr(waitPos, (waitLast - waitPos)+1)
	#insert the wait time into an array
	globalTraitArray.insert(globalTraitArray.size()-1, waitLength)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, waitPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + waitTotal.length() + (waitPos-endStartMeta))
	var replacedArea = (searchArea.replace(waitTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + waitTotal.length() + (waitPos-endStartMeta))
	#iterate :)


func _indexAnimation():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "animation")
	#wait pos = the front
	animationPos = dialogueArray[index].findn("{/animation", 0)
	#wait last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the wait command in characters
	animationCharSize = (animationLast - (animationPos+13))
	#the length of the wait command in seconds
	var animationCharacterNumber = (dialogueArray[index].substr(animationPos + 11, 1))
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + 13), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), 14 + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)

func _indexAnimationEffect():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "animFX")
	#wait pos = the front
	animationPos = dialogueArray[index].findn("{/animFX", 0)
	#wait last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the wait command in characters
	animationCharSize = (animationLast - (animationPos+10))
	#the length of the wait command in seconds
	var animationCharacterNumber = (dialogueArray[index].substr(animationPos + 8, 1))
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + 10), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), 11 + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)

func _indexSFX():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "sfx")
	#sfx pos = the front
	var sfxPos = dialogueArray[index].findn("{/sfx=", 0)
	#sfx last = the back
	var sfxLast = dialogueArray[index].findn("}", sfxPos)
	#the length of the sfx command in characters
	var sfxCharSize = (sfxLast - (sfxPos+6))
	#the name of the sfx file without the extension
	var sfxName = dialogueArray[index].substr(sfxPos + 6, sfxCharSize)
	#the string of the sfx command itself (not counting duplicates)
	var sfxTotal = dialogueArray[index].substr(sfxPos, (sfxLast - sfxPos)+1)
	#insert the sfx trigger into an array
	globalTraitArray.insert(globalTraitArray.size()-1, sfxName)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the sfx change
	globalTriggerArray.insert(globalTriggerArray.size()-1, sfxPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + sfxTotal.length() + (sfxPos-endStartMeta))
	var replacedArea = (searchArea.replace(sfxTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + sfxTotal.length() + (sfxPos-endStartMeta))
	#iterate :)



func _indexCharName():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "charName")
	#charName pos = the front
	var charNamePos = dialogueArray[index].findn("{/charName=", 0)
	#charName last = the back
	var charNameLast = dialogueArray[index].findn("}", charNamePos)
	#the length of the charName command in characters
	var charNameCharSize = (charNameLast - (charNamePos+11))
	#the name of the charName file without the extension
	var charNameName = dialogueArray[index].substr(charNamePos + 11, charNameCharSize)
	#the string of the charName command itself (not counting duplicates)
	var charNameTotal = dialogueArray[index].substr(charNamePos, (charNameLast - charNamePos)+1)
	#insert the charName trigger into an array
	globalTraitArray.insert(globalTraitArray.size()-1, charNameName)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the charName change
	globalTriggerArray.insert(globalTriggerArray.size()-1, charNamePos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + charNameTotal.length() + (charNamePos-endStartMeta))
	var replacedArea = (searchArea.replace(charNameTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + charNameTotal.length() + (charNamePos-endStartMeta))
	#iterate :)





func _metaEndFind():
	#use this to find out where any starting legal bbcode starts
	if dialogueArray[index].findn("[",endStartMeta) > -1:
		endStartMeta = dialogueArray[index].findn("]", 0) +1
		if dialogueArray[index].substr(endStartMeta, 1) == "[":
			_metaEndFind()
		else:
			return endStartMeta
	else:
		return endStartMeta



func _on_Timer_timeout():
	timerReady = true


func _on_TextWaitTimer_timeout():
	dramaticWait = false
	posInTriggerArray += 1




func _doTextStuff(nameThing, sourceFrom = ""):
	fileName = nameThing
	fileSource = sourceFrom
	_textInit()
	typing = true
	show()
	

func textClose():
	emit_signal("doClose")


func _defaultClose():
	fileName = ""
	file = ""
	index = 0
	dialogueArray.clear()
	hide()
	var i = $characters.get_child_count()
	while i > 0:
		$characters.get_child(i - 1).animation = "blank"
		i -= 1
