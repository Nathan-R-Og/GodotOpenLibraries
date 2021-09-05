extends MeshInstance


var interact = false
onready var player = $"/root/Stage/Player"
onready var init = $"/root/Stage/TextShow"

var branch = ""

# you can edit the branch by running a customCommand and linking it either directly or through a parent node of the NPC, thereby changing the branch

func _process(_delta):
	#do the interact
	if interact == true and Input.is_action_just_pressed("accept") and player.state != "normal":
		player.state = "talking"
		init._doTextStuff(name)

#check if able to be interacted
func _on_NPCInteractArea_area_entered(area):
	if area.name == "PlayerInteractArea":
		interact = true
func _on_NPCInteractArea_area_exited(area):
	if area.name == "PlayerInteractArea":
		interact = false
