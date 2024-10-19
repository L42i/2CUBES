
~luhee_1_splitter


~bird_buffer = Buffer.read(s,"/home/anwaldt/SOUND/2CUBES/WAV/rainbirds.wav");

(



)

(
~bird_grainer.free;
~bird_grainer_splitter.free;
)



~midi_sender_N1.stop;
~midi_sender_N2.stop;
~midi_sender_DARK.stop;






~bass_filter_synth = Synth(\quad_filter,[
	// pdf buses
	\inbus, 2,
	\outbus,      ~input_BUS.index+8,
	\gainbus,     ~quest_xyz_BUS[2].index+1],
~effects_GROUP);
