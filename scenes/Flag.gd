extends Node2D

signal player_won

var flag_reached = false

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(_area2d):
	if(!flag_reached):
		flag_reached = true
		emit_signal("player_won")
		$Particles2D.emitting = true
		$AudioStreamPlayer.play()
		$RandomAudioStreamPlayer.play()
