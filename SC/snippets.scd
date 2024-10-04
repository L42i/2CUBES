
~bird_buffer = Buffer.read(s,"/home/anwaldt/SOUND/2CUBES/WAV/rainbirds.wav");

(

~bird_grainer  = Synth(\quad_grainer,[
	\buffer, ~bird_buffer,
	\outbus, ~input_BUS.index+12,
	\centerbus, ~quest_xyz_BUS[3].index,
	\densitybus, ~quest_xyz_BUS[3].index+2,
	\durbus, ~quest_xyz_BUS[3].index+2,
	\crushbus,~quest_xyz_BUS[3].index+1,
	\gainbus,~quest_xyz_BUS[3].index+1
],~effects_GROUP);

~bird_grainer_splitter = Synth(\aed_splitter,
	[\inbus,    ~quest_aed_BUS[2],
		\outbus_1, ~aed_BUS[12],
		\outbus_2, ~aed_BUS[13],
		\outbus_3, ~aed_BUS[14],
		\outbus_4, ~aed_BUS[15]
],~effects_GROUP);

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
