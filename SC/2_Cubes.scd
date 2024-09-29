////////////////////////////////////////////////////////////////////////////////////////
// Basic settings for this script
////////////////////////////////////////////////////////////////////////////////////////

// port for listening to incoming OSC data
~osc_IN         = 7777;

// this determines how many sources (and inputs) we have
~n_inputs       = 8;

// related to Quest objects`
~n_objects      = 8;

// related to Quest objects
~n_sources      = 32;

// the HOA order determines the size of the HOA bus and the nr of outputs
~hoa_order      = 5;
~n_hoa_channels = (pow(~hoa_order + 1.0 ,2.0)).asInteger;

////////////////////////////////////////////////////////////////////////////////////////
// Server options
////////////////////////////////////////////////////////////////////////////////////////

s.options.device               = "2CUBES";
s.options.numInputBusChannels  = ~n_inputs;
s.options.numOutputBusChannels = ~n_hoa_channels;
s.options.memSize              = 65536;
s.options.numBuffers           = 4096;

////////////////////////////////////////////////////////////////////////////////////////
// MIDI
////////////////////////////////////////////////////////////////////////////////////////

MIDIClient.init(3,3);

~dark_MIDI_OUT     = MIDIOut(0);
~nifty_1_MIDI_OUT  = MIDIOut(1);
~nifty_2_MIDI_OUT  = MIDIOut(2);


////////////////////////////////////////////////////////////////////////////////////////
// Start of main routine for setting up the spatial renderer
////////////////////////////////////////////////////////////////////////////////////////

s.waitForBoot({


	load(thisProcess.nowExecutingPath.dirname++"/synthdefs.scd");
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// GROUPS
	////////////////////////////////////////////////////////////////////////////////////////

	~input_GROUP = Group.head(s);
	s.sync;
	~effects_GROUP = Group.after(~input_GROUP);
	s.sync;
	// The group for the spatial encoders
	~spatial_GROUP = Group.after(~effects_GROUP);
	s.sync;
	~output_GROUP	 = Group.after(~spatial_GROUP);

	////////////////////////////////////////////////////////////////////////////////////////
	// Audio buses
	////////////////////////////////////////////////////////////////////////////////////////

	// a multichannel audio bus for the encoded Ambisonics signal
	~ambi_BUS = Bus.audio(s, ~n_hoa_channels);

	// these are used for the input signals AFTER effects
	~input_BUS = Bus.audio(s, ~n_sources);

	////////////////////////////////////////////////////////////////////////////////////////
	// Control buses
	////////////////////////////////////////////////////////////////////////////////////////

	// the control rate buses for the input from the Meta Quest
	for (0, ~n_objects -1, {arg i;
		~quest_aed_BUS = ~quest_aed_BUS.add(Bus.control(s,3));
		~quest_xyz_BUS = ~quest_xyz_BUS.add(Bus.control(s,3));
	});

	// the aed_BUSes are mapped to the positions of the Ambi sources
	for (0, ~n_sources -1, {arg i;
		~aed_BUS = ~aed_BUS.add(Bus.control(s,3));
	});

	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// create encoders
	////////////////////////////////////////////////////////////////////////////////////////
	for (0, ~n_sources-1, {arg i;

		post('Adding HOA encoder module: ');
		i.postln;

		// this is the array of encoders
		~hoa_panners = ~hoa_panners.add(
			Synth(\hoa_mono_encoder,
				[
					\in_bus,  ~input_BUS.index+i,
					\out_bus, ~ambi_BUS.index,
					\azimBus, ~aed_BUS[i].index+0,
					\elevBus, ~aed_BUS[i].index+1,
					\distBus, ~aed_BUS[i].index+2,
				],
				target: ~spatial_GROUP
		);)
	});

	////////////////////////////////////////////////////////////////////////////////////////
	//
	////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////
	// dark energy simply goes to all Ambi buses

	~dark_energy = {

		var in = SoundIn.ar(2);

		Out.ar(~ambi_BUS, in);//*Array.fill(~n_hoa_channels,1));
	}.play;

		////////////////////////////////////////////////////////////////////////////////////////

	~bass_low_synth = Synth(\quad_shift,[
		// pdf buses
		\inbus, 0,
		\outbus, ~input_BUS.index+16,
		\gainbus, ~quest_xyz_BUS[4].index+1,
		\pitchbus, ~quest_xyz_BUS[4].index+1,
		\delaybus, ~quest_xyz_BUS[4].index,
		\feedbackbus, ~quest_xyz_BUS[4].index+2],
	~effects_GROUP);

	~bass_low_splitter = Synth(\aed_splitter,[
		\inbus,    ~quest_aed_BUS[4],
		\outbus_1, ~aed_BUS[16],
		\outbus_2, ~aed_BUS[17],
		\outbus_3, ~aed_BUS[18],
		\outbus_4, ~aed_BUS[19]]);

	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////

	~bass_high_synth = Synth(\quad_pdf,[
		// pdf buses
		\inbus, 1,
		\outbus, ~input_BUS.index+20,
		\gainbus, ~quest_xyz_BUS[5].index+1,
		\pitchbus, ~quest_xyz_BUS[5].index+1,
		\delaybus, ~quest_xyz_BUS[5].index,
		\feedbackbus, ~quest_xyz_BUS[5].index+2],
	~effects_GROUP);

	~bass_high_splitter = Synth(\aed_splitter,[
		\inbus,    ~quest_aed_BUS[5],
		\outbus_1, ~aed_BUS[20],
		\outbus_2, ~aed_BUS[21],
		\outbus_3, ~aed_BUS[22],
		\outbus_4, ~aed_BUS[23]]);

	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////

	~bass_filter_synth = Synth(\quad_filter,[
		// pdf buses
		\inbus, 1,
		\outbus,      ~input_BUS.index+24,
		\gainbus,     ~quest_xyz_BUS[6].index+1],
	~effects_GROUP);

	~bass_filter_splitter = Synth(\aed_splitter,[
		\inbus,    ~quest_aed_BUS[6],
		\outbus_1, ~aed_BUS[24],
		\outbus_2, ~aed_BUS[25],
		\outbus_3, ~aed_BUS[26],
		\outbus_4, ~aed_BUS[27]]);

	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// The output node
	////////////////////////////////////////////////////////////////////////////////////////hoa_output

	~hoa_output = {|gain=1| Out.ar(0 ,gain * In.ar(~ambi_BUS.index,~n_hoa_channels))}.play;
	s.sync;
	// goes into the output group
	~hoa_output.moveToTail(~output_GROUP);
	~hoa_output.set(\gain,0.75);

	////////////////////////////////////////////////////////////////////////////////////////
	// OSC
	////////////////////////////////////////////////////////////////////////////////////////

	load(thisProcess.nowExecutingPath.dirname++"/oscdefs.scd");

	// open our extra ports for OSC and give feedback
	thisProcess.openUDPPort(~osc_IN);
	postln("Listening for OSC on ports: "++thisProcess.openPorts);


	////////////////////////////////////////////////////////////////////////////////////////
	// MIDI Send Routines
	////////////////////////////////////////////////////////////////////////////////////////

	load(thisProcess.nowExecutingPath.dirname++"/midi.scd");


});