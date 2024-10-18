// open our extra ports for OSC and give feedback
thisProcess.openUDPPort(~osc_IN);
postln("Listening for OSC on ports: "++thisProcess.openPorts);



OSCdef('/quest/1/aed',
	{
		arg msg, time, addr, recvPort;
		var idx = msg[1]-1;

		~quest_aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~quest_aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~quest_aed_BUS[idx].setAt(2, abs(msg[4]));

		//msg.postln;

},'/quest/1/aed');

OSCdef('/quest/1/xyz',
	{
		arg msg, time, addr, recvPort;
		var x,y,z;
		var idx = msg[1]-1;

		~quest_xyz_BUS[idx].setAt(0, msg[2]);
		~quest_xyz_BUS[idx].setAt(1, msg[3]);
		~quest_xyz_BUS[idx].setAt(2, msg[4]);

		// msg.postln;

},'/quest/1/xyz');


OSCdef('/quest/1/pry',
	{
		arg msg, time, addr, recvPort;
		var idx = msg[1]-1;

		~quest_pry_BUS[idx].setAt(0, 1-pow(2*msg[2],2));
		~quest_pry_BUS[idx].setAt(1, 1-pow(2*msg[3],2));
		~quest_pry_BUS[idx].setAt(2, 1-pow(2*msg[4],2));

		//msg.postln;

},'/quest/1/pry');

OSCdef('/quest/2/aed',
	{
		arg msg, time, addr, recvPort;
		var idx = msg[1]-1+4;

		~quest_aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~quest_aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~quest_aed_BUS[idx].setAt(2, abs(msg[4]));

		//msg.postln;

},'/quest/2/aed');

OSCdef('/quest/2/xyz',
	{
		arg msg, time, addr, recvPort;
		var x,y,z;

		var idx = msg[1]-1+4;

		~quest_xyz_BUS[idx].setAt(0, msg[2]);
		~quest_xyz_BUS[idx].setAt(1, msg[3]);
		~quest_xyz_BUS[idx].setAt(2, msg[4]);

		// msg.postln;
},'/quest/2/xyz');



OSCdef('/quest/2/pry',
	{
		arg msg, time, addr, recvPort;
		var idx = msg[1]-1+4;

		~quest_pry_BUS[idx].setAt(0, 1-pow(2*msg[2],2));
		~quest_pry_BUS[idx].setAt(1, 1-pow(2*msg[3],2));
		~quest_pry_BUS[idx].setAt(2, 1-pow(2*msg[4],2));

		//msg.postln;

},'/quest/2/pry');
