extends Node


var audio_input = ""
var audio_output = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply():
	AudioServer.set_input_device(audio_input)
	AudioServer.set_output_device(audio_output)
