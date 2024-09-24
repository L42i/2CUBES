////////////////////////////////////////////////////////////////////////////////////////
// Basic settings for this script
////////////////////////////////////////////////////////////////////////////////////////

// port for listening to incoming OSC data
~osc_IN         = 6666;

// this determines how many sources (and inputs) we have
~n_inputs       = 32;

// related to Quest objects
~n_objects      = 4;

// the HOA order determines the size of the HOA bus and the nr of outputs
~hoa_order      = 5;
~n_hoa_channels = (pow(~hoa_order + 1.0 ,2.0)).asInteger;

////////////////////////////////////////////////////////////////////////////////////////
// Server options
////////////////////////////////////////////////////////////////////////////////////////

s.options.device               = "litespat";
s.options.numInputBusChannels  = ~n_inputs;
s.options.numOutputBusChannels = ~n_hoa_channels;
s.options.memSize              = 65536;
s.options.numBuffers           = 4096;

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



	OSCdef('/src/aed',
		{

			arg msg, time, addr, recvPort;
			var idx = msg[1]-1;

			~aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
			~aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
			~aed_BUS[idx].setAt(2, abs(msg[4]));

			// pass message on
			~litespat_OSC.sendMsg(msg[0],msg[1],msg[2],msg[3],msg[4]);

			//msg.postln;

	},'/src/aed');





	////////////////////////////////////////////////////////////////////////////////////////
	// One OSC listener for data from the Quest 3
	////////////////////////////////////////////////////////////////////////////////////////

	OSCdef('/quest/1/xyz',
		{

			arg msg, time, addr, recvPort;
			var a,e,d;
			var x,y,z;

			//a = msg[4] / 180 * 3.1415;
			//e = msg[5] / 180 * 3.1415;
			//d = msg[6];

			var c;


				x = msg[4];
				y = msg[5];
				z = msg[6];

				c	= Cartesian(x,y,z);

/*				~hoa_panners[0].set(\azim, c.theta());
				~hoa_panners[0].set(\elev, c.phi());
				~hoa_panners[0].set(\dist, c.rho());*/

				// msg.postln;


	},'/quest/1/xyz');



	////////////////////////////////////////////////////////////////////////////////////
	// This is the SynthDef for the encoders

	SynthDef(\hoa_mono_encoder,
		{
			|
			in_bus  = nil,
			out_bus = 0,
			azim    = 0,
			elev    = 0,
			dist    = 0.1,
			gain    = 1
			|


			var sound = gain * SoundIn.ar(in_bus);
			var level =  (1.0/(dist+1.0))*(1.0 / ( max(0.01,dist)+1.0));
			var bform = HOASphericalHarmonics.coefN3D(~hoa_order, azim, elev) * sound * level;

			Out.ar(out_bus, bform);

	}).add;

	////////////////////////////////////////////////////////////////////////////////////////
	// use server sync after asynchronous commands
	s.sync;


	////////////////////////////////////////////////////////////////////////////////////////
	// The group for the spatial encoders
	~spatial_GROUP = Group.after(~input_GROUP);
	s.sync;

	////////////////////////////////////////////////////////////////////////////////////////
	// a multichannel audio bus for the encoded Ambisonics signal
	~ambi_BUS = Bus.audio(s, ~n_hoa_channels);


	////////////////////////////////////////////////////////////////////////////////////////
	// create all encoders in a loop
	for (0, ~n_inputs
		-1, {arg i;

			post('Adding HOA encoder module: ');
			i.postln;

			// this is the array of encoders
			~hoa_panners = ~hoa_panners.add(
				Synth(\hoa_mono_encoder,
					[
						\in_bus,  i,
						\out_bus, ~ambi_BUS.index
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

});