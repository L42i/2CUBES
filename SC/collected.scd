////////////////////////////////////////////////////////////////////////////////////////
// Basic options
////////////////////////////////////////////////////////////////////////////////////////

// number of inputs and outputs
~n_objects      = 4;

// open individual port for listening to incoming OSC data
~osc_IN         = 7777;
thisProcess.openUDPPort(~osc_IN);
postln("Listening for OSC on ports: "++thisProcess.openPorts);

// outgoing connection for OSC data to litespat
~litespat_OSC = NetAddr.new("127.0.0.1", 6666);

////////////////////////////////////////////////////////////////////////////////////////
// Server options
////////////////////////////////////////////////////////////////////////////////////////

// set a different port to let this server run next to
s = Server(\quest_test, NetAddr("127.0.0.1", 57111));

// server settings
s.options.device               = "quest_effects";
s.options.numInputBusChannels  = ~n_objects;
s.options.numOutputBusChannels = ~n_objects;

// replace local server to make it accessible in sclang
Server.local = s;

////////////////////////////////////////////////////////////////////////////////////////
// Boot the server with the 'waitForBoot' method
////////////////////////////////////////////////////////////////////////////////////////

s.waitForBoot({

	////////////////////////////////////////////////////////////////////////////////////////
	// the control rate buses for the input from the Meta Quest
	////////////////////////////////////////////////////////////////////////////////////////

	~aed_BUS = [];

	for (0, ~n_objects -1, {arg i;
		~aed_BUS = ~aed_BUS.add(Bus.control(s,3));
	});

	s.sync;


	////////////////////////////////////////////////////////////////////////////////////////
	// a processing node with feedback-delay
	////////////////////////////////////////////////////////////////////////////////////////

	SynthDef(\feedback_delay, {
		|
		idx  = 0,
		bus1 = 0,
		bus2 = 0
		|

		// input and feedback signals
		var input    = SoundIn.ar(idx);
		var feedback = LocalIn.ar(1);

		// feedback-delay parameters:
		var time = max(0.001,       In.kr(bus1));
		var gain = max(0, min(1.01, In.kr(bus2)));

		var out  = DelayC.ar(input+feedback,1,time);

		LocalOut.ar(out*gain);

		Out.ar(idx,out);

	}).send(s);

	s.sync;

	~effects =[];

	for (0, ~n_objects -1, { arg i;

		var bus1 = ~aed_BUS[i].index+0;
		var bus2 = ~aed_BUS[i].index+1;

		bus1.postln;
		bus2.postln;

		~effects = ~effects.add(
			Synth.new(\feedback_delay,
				[
					\idx,  i,
					\bus1, bus1,
					\bus2, bus2,
				],s
		);)
	});

	////////////////////////////////////////////////////////////////////////////////////////
	// OSC receivers
	////////////////////////////////////////////////////////////////////////////////////////

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

	s.meter;
	~aed_BUS[0].scope();

});