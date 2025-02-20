extends Node

func play(soundname:String) -> AudioStreamPlayer:
	var snd : AudioStreamPlayer = get_node(soundname)
	snd.pitch_scale = 1.0
	snd.play()
	return snd


func play_nodoubling(soundname:String) -> AudioStreamPlayer:
	var snd : AudioStreamPlayer = get_node(soundname)
	snd.pitch_scale = 1.0
	if snd.playing and snd.get_playback_position() < 0.1:
		pass
	else:
		snd.play()
	return snd
