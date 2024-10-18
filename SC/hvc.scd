////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////


~hvc_1_synth = Synth(\quad_shift,[
	// pdf buses
	\inbus, 0,
	\outbus, ~input_BUS.index+0,
	\gainbus, ~quest_xyz_BUS[0].index+1,
	\pitchbus, ~quest_xyz_BUS[0].index+1,
	\delaybus, ~quest_xyz_BUS[0].index,
	\feedbackbus, ~quest_xyz_BUS[0].index+2],
~effects_GROUP);

~hvc_1_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[0],
	\outbus_1, ~aed_BUS[0],
	\outbus_2, ~aed_BUS[1],
	\outbus_3, ~aed_BUS[2],
	\outbus_4, ~aed_BUS[3]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~hvc_2_synth = Synth(\quad_pdf,[
	// pdf buses
	\inbus, 1,
	\outbus, ~input_BUS.index+4,
	\gainbus, ~quest_xyz_BUS[1].index+1,
	\pitchbus, ~quest_xyz_BUS[1].index+1,
	\delaybus, ~quest_xyz_BUS[1].index,
	\feedbackbus, ~quest_xyz_BUS[1].index+2],
~effects_GROUP);

~hvc_2_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[1],
	\outbus_1, ~aed_BUS[4],
	\outbus_2, ~aed_BUS[5],
	\outbus_3, ~aed_BUS[6],
	\outbus_4, ~aed_BUS[7]],~effects_GROUP);

////////////////////////////////////////////////////////////////////////////////////////

~hvc_3_synth = Synth(\quad_freezer,
	[
		\inbus, 2,
		\outbus, ~input_BUS.index+8,
		\gainbus, ~quest_xyz_BUS[2].index+1,
		\threshbus, ~quest_xyz_BUS[2].index+1,
		\crushbus,~quest_xyz_BUS[2].index+0,
		\lpbus,~quest_xyz_BUS[2].index+2
	],
	~effects_GROUP);

~hvc_3_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[2],
	\outbus_1, ~aed_BUS[8],
	\outbus_2, ~aed_BUS[9],
	\outbus_3, ~aed_BUS[10],
	\outbus_4, ~aed_BUS[11]],~effects_GROUP);


////////////////////////////////////////////////////////////////////////////////////////


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



////////////////////////////////////////////////////////////////////////////////////////
// dark energy simply goes to all Ambi buses

~dark_energy = {

	var in      = SoundIn.ar([3]);
	var	outgain = max(0, pow(0.5*(In.kr(~quest_xyz_BUS[3])+1),1));
	Out.ar(~input_BUS.index+12, [in,in,in,in]*outgain);

}.play(~effects_GROUP);

~dark_energy_splitter = Synth(\aed_splitter,[
	\inbus,    ~quest_aed_BUS[3],
	\outbus_1, ~aed_BUS[12],
	\outbus_2, ~aed_BUS[13],
	\outbus_3, ~aed_BUS[14],
	\outbus_4, ~aed_BUS[15]],~effects_GROUP);

