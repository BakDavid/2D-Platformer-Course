extends HBoxContainer

signal percentage_changed

var currentPercentage = 1.0

func _ready():
	$SubtractButton.connect("pressed", self, "on_button_pressed", [-.1])
	$AddButton.connect("pressed", self, "on_button_pressed", [.1])
	$MuteButton.connect("pressed", self, "on_mute_button_pressed")
	
func set_current_percentage(percent):
	currentPercentage = clamp(percent, 0, 1)
	var labelNumber = currentPercentage * 10
	labelNumber = round(labelNumber)
	$Label.text = str(labelNumber)
	emit_signal("percentage_changed", currentPercentage)
	
func on_button_pressed(change):
	set_current_percentage(currentPercentage + change)

func on_mute_button_pressed():
	currentPercentage = 0.0
	$Label.text = str(currentPercentage)
	emit_signal("percentage_changed", currentPercentage)
