////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////


~luhee_1_synth = Synth(\quad_shift,[
	// pdf buses
	\inbus, 4,
	\outbus, ~multi_BUS.index+16,
	\gainbus,  ~quest_xyz_BUS[4].index+1,
	\pitchbus, ~quest_xyz_BUS[4].index+0,
	\devbus,   ~quest_xyz_BUS[4].index+2,
	\foldbus,   ~quest_pry_BUS[4].index+2],
~effects_GROUP);

~luhee_1_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[4],
	\outbus_1, ~aed_BUS[16],
	\outbus_2, ~aed_BUS[17],
	\outbus_3, ~aed_BUS[18],
	\outbus_4, ~aed_BUS[19]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~luhee_2_synth = Synth(\quad_pdf,[
	// pdf buses
	\inbus, 4,
	\outbus,      ~multi_BUS.index+20,
	\gainbus,     ~quest_xyz_BUS[5].index+1,
	\pitchbus,    ~quest_xyz_BUS[5].index+0,
	\delaybus,    ~quest_pry_BUS[5].index+2,
	\feedbackbus, ~quest_xyz_BUS[5].index+2
],
~effects_GROUP);

~luhee_2_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[5],
	\outbus_1, ~aed_BUS[20],
	\outbus_2, ~aed_BUS[21],
	\outbus_3, ~aed_BUS[22],
	\outbus_4, ~aed_BUS[23]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~luhee_3_synth = Synth(\quad_freezer,
	[
		\inbus, 4,
		\outbus, ~multi_BUS.index+24,
		\gainbus,   ~quest_xyz_BUS[6].index+1,
		\threshbus, ~quest_xyz_BUS[6].index+1,
		\crushbus,  ~quest_xyz_BUS[6].index+0,
		\lpbus,     ~quest_xyz_BUS[6].index+2
	],
	~effects_GROUP);

~luhee_3_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[6],
	\outbus_1, ~aed_BUS[24],
	\outbus_2, ~aed_BUS[25],
	\outbus_3, ~aed_BUS[26],
	\outbus_4, ~aed_BUS[27]],~effects_GROUP);


////////////////////////////////////////////////////////////////////////////////////////
//

~bass_grainer  = Synth(\quad_input_grainer,[
	\inbus, 5,
	\outbus,      ~multi_BUS.index+28,
	\densitybus,  ~quest_xyz_BUS[7].index+2,
	\durbus,      ~quest_xyz_BUS[7].index+0,
	\feedbackbus, ~quest_xyz_BUS[7].index+1,
	\gainbus,     ~quest_xyz_BUS[7].index+1,
	//
	\cutoffbus,   ~quest_pry_BUS[7].index+0,
	\rqbus,       ~quest_pry_BUS[7].index+2
],~effects_GROUP);

~bass_grainer_splitter = Synth(\aed_splitter,
	[   \inbus,    ~quest_aed_BUS[7],
		\outbus_1, ~aed_BUS[28],
		\outbus_2, ~aed_BUS[29],
		\outbus_3, ~aed_BUS[30],
		\outbus_4, ~aed_BUS[31]
],~effects_GROUP);

