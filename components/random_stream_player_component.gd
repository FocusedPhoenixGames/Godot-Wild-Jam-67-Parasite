extends AudioStreamPlayer

@export var streams: Array[AudioStream]
@export var randomizePitch = true
@export var minPitch = 0.9
@export var maxPitch = 1.1


func play_random():
	if streams == null || streams.size() == 0:
		return
	
	if randomizePitch:
		pitch_scale = randf_range(minPitch, maxPitch)
	else:
		pitch_scale = 1
	
	stream = streams.pick_random()
	play()
