# goes onto an audio_controller with an AudioStreamPlayer (mic input) child
extends Node
@onready var input : AudioStreamPlayer = $input
var idx : int
var effect 
var playback : AudioStreamGeneratorPlayback

@onready var output = $output

func _enter_tree() -> void:
	set_multiplayer_authority(str(get_parent().name).to_int())
	
func _ready() -> void:

	if (is_multiplayer_authority()):
		input.stream = AudioStreamMicrophone.new()
		input.play()
		#THIS SHOULD BE GET_BUS_INDEX WHICH TAKES IN A STRING, BUT IT SEEMS BUSTED
		idx = 2
		effect = AudioServer.get_bus_effect(idx, 0)
		
		# replace 0 with whatever index the capture effect is
			
	# playback variable will be needed for playback on other peers	
	playback = output.get_stream_playback()
#
func _process(delta: float) -> void:
	if (not is_multiplayer_authority()): return
	var buffer_size = effect.get_frames_available()
	if (effect.can_get_buffer(buffer_size) && playback.can_push_buffer(buffer_size) && buffer_size != 0):
		send_data.rpc(effect.get_buffer(buffer_size), buffer_size)

	effect.clear_buffer()
#
# if not "call_remote," then the player will hear their own voice
# also don't try and do "unreliable_ordered." didn't work from my experience
@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array, buffer_size):
	for i in range(0,buffer_size):
		playback.push_frame(data[i])
