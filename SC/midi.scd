
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