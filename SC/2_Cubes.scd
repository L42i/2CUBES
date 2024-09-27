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

~dark_MIDI_OUT   = MIDIOut(0);
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
	// Two OSC listener for data from the Quest 3
	////////////////////////////////////////////////////////////////////////////////////////


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


	~input_GROUP = Group.head(s);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////

	~effects_GROUP = Group.after(~input_GROUP);

	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// The group for the spatial encoders
	~spatial_GROUP = Group.after(~effects_GROUP);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// a multichannel audio bus for the encoded Ambisonics signal
	~ambi_BUS = Bus.audio(s, ~n_hoa_channels);

	////////////////////////////////////////////////////////////////////////////////////////
	// create direct encoders

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
	~hoa_output.set(\gain,0.75);





	// open our extra ports for OSC and give feedback
	thisProcess.openUDPPort(~osc_IN);
	postln("Listening for OSC on ports: "++thisProcess.openPorts);


OSCdef('/quest/1/aed',
	{

		arg msg, time, addr, recvPort;
		var idx = msg[1]-1;

		~aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~aed_BUS[idx].setAt(2, abs(msg[4]));

		// pass message on
		//~litespat_OSC.sendMsg(msg[0],msg[1],msg[2],msg[3],msg[4]);

		//msg.postln;

},'/quest/1/aed');



OSCdef('/quest/1/xyz',
	{

		arg msg, time, addr, recvPort;
		var a,e,d;
		var x,y,z;

		//a = msg[4] / 180 * 3.1415;
		//e = msg[5] / 180 * 3.1415;
		//d = msg[6];

		var idx = msg[1]-1;

		~xyz_BUS[idx].setAt(0, msg[2]);
		~xyz_BUS[idx].setAt(1, msg[3]);
		~xyz_BUS[idx].setAt(2, msg[4]);

		/*var c;


		x = msg[4];
		y = msg[5];
		z = msg[6];

		c	= Cartesian(x,y,z);
		*/
		/*				~hoa_panners[0].set(\azim, c.theta());
		~hoa_panners[0].set(\elev, c.phi());
		~hoa_panners[0].set(\dist, c.rho());*/

		// msg.postln;


},'/quest/1/xyz');









OSCdef('/quest/2/aed',
	{

		arg msg, time, addr, recvPort;
		var idx = msg[1]-1+4;

		~aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~aed_BUS[idx].setAt(2, abs(msg[4]));

		// pass message on
		//~litespat_OSC.sendMsg(msg[0],msg[1],msg[2],msg[3],msg[4]);

		msg.postln;

},'/quest/2/aed');



OSCdef('/quest/2/xyz',
	{

		arg msg, time, addr, recvPort;
		var a,e,d;
		var x,y,z;

		//a = msg[4] / 180 * 3.1415;
		//e = msg[5] / 180 * 3.1415;
		//d = msg[6];

		var idx = msg[1]-1+4;

		~xyz_BUS[idx].setAt(0, msg[2]);
		~xyz_BUS[idx].setAt(1, msg[3]);
		~xyz_BUS[idx].setAt(2, msg[4]);

		/*var c;


		x = msg[4];
		y = msg[5];
		z = msg[6];

		c	= Cartesian(x,y,z);
		*/
		/*				~hoa_panners[0].set(\azim, c.theta());
		~hoa_panners[0].set(\elev, c.phi());
		~hoa_panners[0].set(\dist, c.rho());*/

		// msg.postln;


},'/quest/2/xyz');



	////////////////////////////////////////////////////////////////////////////////////////
	// MIDI Send Routines
	////////////////////////////////////////////////////////////////////////////////////////


	~midi_sender_N1 = Routine {
		loop {
			var cart = ~xyz_BUS[0].getnSynchronous(3);
			var x = abs(cart[0])*127;
			var y = (cart[1]+1)*127;
			var z = abs(cart[2])*127;

			~nifty_1_MIDI_OUT.control(0, ctlNum: 1, val: y);
			// cart.postln;
			0.005.wait;
		}
	}.play;

	~midi_sender_N2 = Routine {
		loop {
			var cart = ~xyz_BUS[0].getnSynchronous(3);
			var x = abs(cart[0])*127;
			var y = (cart[1]+1)*127;
			var z = abs(cart[2])*127;

			~nifty_2_MIDI_OUT.control(0, ctlNum: 1, val: x);
			// cart.postln;
			0.005.wait;
		}
	}.play;

	~midi_sender_DARK = Routine {
		loop {
			var cart = ~xyz_BUS[2].getnSynchronous(3);
			var x = abs(cart[0])*127;
			var y = (cart[1]+1)*127;
			var z = abs(cart[2])*127;

			~dark_MIDI_OUT.control(0, ctlNum: 1, val: y);
			// cart.postln;
			0.005.wait;
		}
	}.play;
});