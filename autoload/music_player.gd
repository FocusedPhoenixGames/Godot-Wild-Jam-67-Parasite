extends AudioStreamPlayer

@export var songs: Array[AudioStream]


func play_music(song: int):
	if songs == null || songs.size() == 0:
		return
	
	stream = songs[song]
	play()
