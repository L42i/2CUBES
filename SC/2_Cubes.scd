////////////////////////////////////////////////////////////////////////////////////////
// Basic settings for this script
////////////////////////////////////////////////////////////////////////////////////////

// port for listening to incoming OSC data
~osc_IN         = 7777;

// this determines how many sources (and inputs) we have
~n_inputs       = 8;

// related to Quest objects
~n_objects      = 8;

// related to Quest objects
~n_sources      = 16;

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

	////////////////////////////////////////////////////////////////////////////////////////
	// the control rate buses for the input from the Meta Quest
	////////////////////////////////////////////////////////////////////////////////////////

	~aed_BUS = [];
	~xyz_BUS = [];

	for (0, ~n_objects -1, {arg i;
		~aed_BUS = ~aed_BUS.add(Bus.control(s,3));
		~xyz_BUS = ~xyz_BUS.add(Bus.control(s,3));
	});

	s.sync;



	////////////////////////////////////////////////////////////////////////////////////////


	~input_GROUP = Group.head(s);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////

	~effects_GROUP = Group.after(~input_GROUP);
	s.sync;

	~bass_high_BUS = Bus.audio(s,4);
	s.sync;

	~bass_high = {
		|
		in        = 0,
		outbus       = 0
		|

		var	quest_idx  = 0;
		// input and feedback signals
		var input    = SoundIn.ar(in);
		var feedback = LocalIn.ar(4);

		var proc = PitchShift.ar(feedback,0.2, In.kr(~xyz_BUS[quest_idx].index+1)+1);
		// feedback-delay parameters:
		var times = max(0.001,     [1,1.25,1.5,1.85] * abs(In.kr(~xyz_BUS[quest_idx].index)));
		var gain = max(0, min(1.01, abs(In.kr(~xyz_BUS[quest_idx].index+2))));
		var out  = DelayC.ar(input + proc, 1, times);

		LocalOut.ar(out*gain);

		Out.ar(outbus,out);
	}.play;


		~bass_low = {
		|
		in        = 1,
		outbus    = 0
		|

		var	quest_idx = 1;
		// input and feedback signals
		var input     = SoundIn.ar(in);

		var pitch     = 500*(In.kr(~xyz_BUS[quest_idx].index+1)+1);
		var deviate   = [-0.5,-0.25,0.25,0.5]*abs(In.kr(~xyz_BUS[quest_idx].index+0));


		var proc = input * SinOsc.ar(pitch+(pitch*deviate));
		// feedback-delay parameters:
		//var times = max(0.001,     [1,1.25,1.5,1.85] * abs(In.kr(~xyz_BUS[quest_idx].index)));
		//var gain = max(0, min(1.01, abs(In.kr(~xyz_BUS[quest_idx].index+2))));

		var out  = DelayC.ar(proc, 1);

		// LocalOut.ar(out*gain);

		Out.ar(outbus,out);
	}.play;


	////////////////////////////////////////////////////////////////////////////////////////
	// The group for the spatial encoders
	~spatial_GROUP = Group.after(~effects_GROUP);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// a multichannel audio bus for the encoded Ambisonics signal
	~ambi_BUS = Bus.audio(s, ~n_hoa_channels);




	////////////////////////////////////////////////////////////////////////////////////
	// This is the SynthDef for the encoders

	SynthDef(\hoa_mono_encoder,
		{
			|
			in_bus  = nil,
			out_bus = 0,
			azimBus = 0,
			elevBus = 0,
			distBus = 0.1,
			gain    = 1
			|

			var azim = In.kr(azimBus);
			var elev = In.kr(elevBus);
			var dist = In.kr(distBus);

			var sound = gain * SoundIn.ar(in_bus);

			var saturate = 2.0;
			var level =  (saturate/(dist+saturate));
			var bform = HOASphericalHarmonics.coefN3D(~hoa_order, azim, elev) * sound * level;

			Out.ar(out_bus, bform);

	}).add;
	s.sync;


	////////////////////////////////////////////////////////////////////////////////////////
	// create encoders

	for (0, 7, {arg i;

		post('Adding HOA encoder module: ');
		i.postln;

		// this is the array of encoders
		~hoa_panners = ~hoa_panners.add(
			Synth(\hoa_mono_encoder,
				[
					\in_bus,  i,
					\out_bus, ~ambi_BUS.index,
					\azimBus, ~aed_BUS[i].index+0,
					\elevBus, ~aed_BUS[i].index+1,
					\distBus, ~aed_BUS[i].index+2,
				],
				target: ~spatial_GROUP
		);)
	});
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// Another group for the outputs
	////////////////////////////////////////////////////////////////////////////////////////

	~output_GROUP	 = Group.after(~spatial_GROUP);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// The output node
	////////////////////////////////////////////////////////////////////////////////////////

	~hoa_output = {|gain=1| Out.ar(0 ,gain * In.ar(~ambi_BUS.index,~n_hoa_channels))}.play;
	s.sync;
	// goes into the output group
	~hoa_output.moveToTail(~output_GROUP);
	~hoa_output.set(\gain,0.0);



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