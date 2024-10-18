////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////


~luhee_1_synth = Synth(\quad_shift,[
	// pdf buses
	\inbus, 5,
	\outbus, ~input_BUS.index+0,
	\gainbus, ~quest_xyz_BUS[4].index+1,
	\pitchbus, ~quest_xyz_BUS[4].index+1,
	\delaybus, ~quest_xyz_BUS[4].index,
	\feedbackbus, ~quest_xyz_BUS[4].index+2],
~effects_GROUP);

~luhee_1_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[4],
	\outbus_1, ~aed_BUS[4],
	\outbus_2, ~aed_BUS[5],
	\outbus_3, ~aed_BUS[6],
	\outbus_4, ~aed_BUS[7]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~luhee_2_synth = Synth(\quad_pdf,[
	// pdf buses
	\inbus, 4,
	\outbus, ~input_BUS.index+4,
	\gainbus, ~quest_xyz_BUS[5].index+1,
	\pitchbus, ~quest_xyz_BUS[5].index+1,
	\delaybus, ~quest_xyz_BUS[5].index,
	\feedbackbus, ~quest_xyz_BUS[5].index+2],
~effects_GROUP);

~luhee_2_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[5],
	\outbus_1, ~aed_BUS[8],
	\outbus_2, ~aed_BUS[9],
	\outbus_3, ~aed_BUS[10],
	\outbus_4, ~aed_BUS[11]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~luhee_3_synth = Synth(\quad_freezer,
	[
		\inbus, 4,
		\outbus, ~input_BUS.index+8,
		\gainbus, ~quest_xyz_BUS[6].index+1,
		\threshbus, ~quest_xyz_BUS[6].index+1,
		\crushbus,~quest_xyz_BUS[6].index+0,
		\lpbus,~quest_xyz_BUS[6].index+2
	],
	~effects_GROUP);

~luhee_3_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[6],
	\outbus_1, ~aed_BUS[12],
	\outbus_2, ~aed_BUS[13],
	\outbus_3, ~aed_BUS[14],
	\outbus_4, ~aed_BUS[15]],~effects_GROUP);

