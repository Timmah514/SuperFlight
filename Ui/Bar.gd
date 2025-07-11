extends ProgressBar

@export var type = ""

func _process(delta):
	if type == "energy":
		value = globals.player.energy
		max_value = globals.player.maxEnergy
