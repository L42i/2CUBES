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
~hoa_order      = 4;
~n_hoa_channels = (pow(~hoa_order + 1.0 ,2.0)).asInteger;

////////////////////////////////////////////////////////////////////////////////////////
// Server options
////////////////////////////////////////////////////////////////////////////////////////

s.options.device               = "2CUBES";
s.options.numInputBusChannels  = ~n_inputs;
s.options.numOutputBusChannels = 32;//~n_hoa_channels;
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




	//~bird_buffer  = Buffer.read(s,"/home/anwaldt/SOUND/2CUBES/WAV/rainbirds.wav");
	//~truck_buffer = Buffer.read(s,"/home/anwaldt/SOUND/2CUBES/WAV/harmony_tractor.wav");
	//~bigfoot_buffer = Buffer.read(s,"/home/anwaldt/SOUND/2CUBES/WAV/bigfoot.wav");



	 ~bigfoot_buffer  = Buffer.read(s,"/home/anwaldt/Desktop/birds2trains.wav");
	~duck_buffer= Buffer.read(s,"/home/anwaldt/Desktop/noise2people.wav");

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
	~multi_BUS = Bus.audio(s, ~n_sources);

	// these are used for the input signals AFTER strips
	~input_BUS = Bus.audio(s, ~n_objects);





	////////////////////////////////////////////////////////////////////////////////////////
	// Control buses
	////////////////////////////////////////////////////////////////////////////////////////

	// the control rate buses for the input from the Meta Quest
	for (0, ~n_objects -1, {arg i;
		~quest_aed_BUS = ~quest_aed_BUS.add(Bus.control(s,3).setAll(0));
		~quest_xyz_BUS = ~quest_xyz_BUS.add(Bus.control(s,3).setAll(-1));
		~quest_pry_BUS = ~quest_pry_BUS.add(Bus.control(s,3).setAll(0));
	});

	// the aed_BUSes are mapped to the positions of the Ambi sources
	for (0, ~n_sources -1, {arg i;
		~aed_BUS = ~aed_BUS.add(Bus.control(s,3));
	});

	s.sync;


	// this one is to be controlled manually:
	~strip_gain_BUS        = Bus.control(s,~n_objects).setAll(1);
	// this one is to be controlled by modulators:
	~strip_autogain_BUS    = Bus.control(s,~n_objects).setAll(1);

	// this one is to be controlled by modulators
	~strip_lp_autocutoff_BUS  = Bus.control(s,~n_objects).setAll(1);
	// this one is to be controlled manually:
	~strip_lp_cutoff_BUS  = Bus.control(s,~n_objects).setAll(20000);
	~strip_lp_reso_BUS    = Bus.control(s,~n_objects).setAll(1);

	// this one is to be controlled by modulators
	~strip_hp_autocutoff_BUS  = Bus.control(s,~n_objects).setAll(1);
	// this one is to be controlled manually:
	~strip_hp_cutoff_BUS      = Bus.control(s,~n_objects).setAll(1);
	~strip_hp_reso_BUS        = Bus.control(s,~n_objects).setAll(1);


	s.sync;


	////////////////////////////////////////////////////////////////////////////////////////
	// create input modules
	////////////////////////////////////////////////////////////////////////////////////////

	for (0, ~n_objects -1, {arg i;

		post('Adding Channel Strip Module: ');
		i.postln;

		~channelstrips = ~channelstrips.add(
			Synth(\channel_strip,
				[
					\in_chan,  i ,
					\out_chan, ~input_BUS.index + i,
				],
				target: ~input_GROUP
		);)
	});

	s.sync;

	for (0, ~n_objects-1, {arg i;

		post('Connecting and configuring channel strips: ');
		i.postln;

		~channelstrips[i].set(\in_chan,   i);
		~channelstrips[i].map(\gain,	         ~strip_gain_BUS.index + i);
		~channelstrips[i].map(\autogain,	     ~strip_autogain_BUS.index + i);
		~channelstrips[i].map(\freq,             ~strip_lp_autocutoff_BUS.index + i);
		~channelstrips[i].map(\lp_fixed_ratio,   ~strip_lp_cutoff_BUS.index+i);
		~channelstrips[i].map(\rq,               ~strip_lp_reso_BUS.index +i);
		~channelstrips[i].map(\hp_cutoff,        ~strip_hp_autocutoff_BUS.index + i);
		~channelstrips[i].map(\hp_fixed,         ~strip_hp_cutoff_BUS.index + i);
		~channelstrips[i].map(\hp_reso,          ~strip_hp_reso_BUS.index + i);

	});


	s.sync;

	~strip_hp_cutoff_BUS.setAt(4,80);
	~strip_hp_cutoff_BUS.setAt(5,80);


	// Nebula comes to hvc
	//~channelstrips[6].set(\out_chan, ~input_BUS.index + 1);
	//~channelstrips[7].set(\out_chan, ~input_BUS.index + 2);


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
					\in_bus,  ~multi_BUS.index+i,
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

	load(thisProcess.nowExecutingPath.dirname++"/hvc.scd");
	load(thisProcess.nowExecutingPath.dirname++"/luhee.scd");

	////////////////////////////////////////////////////////////////////////////////////////
	// The output node
	////////////////////////////////////////////////////////////////////////////////////////hoa_output

	~hoa_output = {|gain=1| Out.ar(0 ,gain * In.ar(~ambi_BUS.index,~n_hoa_channels))}.play;
	s.sync;

	// goes into the output group
	~hoa_output.moveToTail(~output_GROUP);
	~hoa_output.set(\gain,0.5);

	~dark_energy.set(\outgain,2);


	////////////////////////////////////////////////////////////////////////////////////////
	// OSC
	////////////////////////////////////////////////////////////////////////////////////////

	load(thisProcess.nowExecutingPath.dirname++"/oscdefs.scd");



	////////////////////////////////////////////////////////////////////////////////////////
	// MIDI Send Routines
	////////////////////////////////////////////////////////////////////////////////////////

	load(thisProcess.nowExecutingPath.dirname++"/midi.scd");




/*


	~strip_controller_A = StripController(0,
		~strip_gain_BUS,
		~strip_lp_cutoff_BUS,
		~strip_lp_reso_BUS,
		~strip_hp_cutoff_BUS,
		~strip_hp_reso_BUS)*/


});