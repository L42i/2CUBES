OSCdef('/quest/1/aed',
	{

		arg msg, time, addr, recvPort;
		var idx = msg[1]-1;

		~quest_aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~quest_aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~quest_aed_BUS[idx].setAt(2, abs(msg[4]));

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

		~quest_xyz_BUS[idx].setAt(0, msg[2]);
		~quest_xyz_BUS[idx].setAt(1, msg[3]);
		~quest_xyz_BUS[idx].setAt(2, msg[4]);

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

		~quest_aed_BUS[idx].setAt(0, abs(msg[2])/ (pi/2));
		~quest_aed_BUS[idx].setAt(1, abs(msg[3])/ (pi/2));
		~quest_aed_BUS[idx].setAt(2, abs(msg[4]));

		// pass message on
		//~litespat_OSC.sendMsg(msg[0],msg[1],msg[2],msg[3],msg[4]);

		//msg.postln;

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

		~quest_xyz_BUS[idx].setAt(0, msg[2]);
		~quest_xyz_BUS[idx].setAt(1, msg[3]);
		~quest_xyz_BUS[idx].setAt(2, msg[4]);

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


