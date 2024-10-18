SynthDef(\quad_input_grainer,
	{
		|
		inbus,
		outbus,
		densitybus,
		durbus,
		feedbackbus,
		cutoffbus,
		rqbus,
		gainbus
		|

		var triggers, c, grainer;

		var	outgain  = Clip.kr(pow(1*(In.kr(gainbus)+1),1),0,2);
		var	fbgain   = Clip.kr(pow(0.5*(In.kr(feedbackbus)+1),2),0,1);
		var density  = Clip.kr(1-abs(In.kr(densitybus)),0,1);
		var dur      = Clip.kr(In.kr(durbus)+1*0.1,0.0001,1);

		var freq     = Clip.kr(In.kr(cutoffbus)+1*20000,10,20000);
		var rq       = Clip.kr(In.kr(rqbus)+1*3,0.1,3);

		var feedback = LocalIn.ar(4);

		triggers     = Trig1.kr(WhiteNoise.kr([1,-1,1,-1])+[density,density,density,density],dur);

		grainer      = RLPF.ar(GrainIn.ar(1, triggers, dur, SoundIn.ar(inbus)),freq,rq);

		grainer      = DelayC.ar(grainer+feedback,2,[0.015 , 0.0173 , 0.03612 , 0.02752]);

		LocalOut.ar(fbgain*grainer);

		Out.ar(outbus, grainer * outgain);

}).add;

SynthDef(\quad_grainer,
	{
		|
		outbus,
		buffer,
		centerbus    = 0,
		crushbus     = 1,
		densitybus   = 1,
		durbus       = 1,
		pitch    = 1,
		gainbus
		|

		var triggers, c;

		var	outgain  = Clip.kr(pow(1*(In.kr(gainbus)+1),1),0,2);
		var center   = Clip.kr((In.kr(centerbus)+1)*0.5,0,1);
		var density  = Clip.kr(100*(In.kr(densitybus)+1),0,100);
		var dur      = Clip.kr(0.2*abs(In.kr(durbus)),0.001,10);
		var crush    = Clip.kr(round((24*pow(-1*In.kr(crushbus)+1,1))),1,24);

		var crushgain = ((crush*crush)/24);

		triggers    = Trig.kr(WhiteNoise.kr([1,1,1,1]));

		c =   center + TRand.kr(0,0.1,triggers) * BufDur.kr(buffer);

		Out.ar(outbus,   outgain * crushgain* Decimator.ar(TGrains.ar(1, triggers, buffer, pitch, c, dur), s.sampleRate, crush););

}).add;




SynthDef(\quad_filter, {
	|
	inbus,
	outbus,
	gainbus
	|

	// input signal
	var input     = SoundIn.ar(inbus);
	var	outgain   = Clip.kr(1*(In.kr(gainbus)+1),0,2);

	// filter all the signals
	var filter1   = LPF.ar(input, 200.0,outgain);
	var filter3   = BPF.ar(input, 650.0,  1.38,outgain);
	var filter4   = BPF.ar(input, 1550.0, 0.5,outgain);
	var filter2   = HPF.ar(input, 2000.0,outgain);

	// do some wavefolding
	var folder1   = Fold.ar(filter1, lo: -5.0, hi: 0.5);
	var folder2   = Fold.ar(filter2, lo: -5.0, hi: 0.5);
	var folder3   = Fold.ar(filter3, lo: -5.0, hi: 0.5);
	var folder4   = Fold.ar(filter4, lo: -5.0, hi: 0.5);

	Out.ar(outbus,0.5*[folder1, folder2, folder3, folder4]);

}).add;

SynthDef(\quad_freezer, {
	|
	inbus,
	outbus,
	gainbus,
	threshbus,
	crushbus,
	lpbus
	|

	var thresholds = [0.44,0.48,0.52,0.56];

	// input signal
	var input     = SoundIn.ar(inbus);
	var	outgain   = Clip.kr(1*(In.kr(gainbus)+1),0,1);

	// do an FFT to all the signals
	var fft = FFT(LocalBuf(2048.dup(4), 1), input);
	var chain = PV_Freeze(fft,In.kr(threshbus)>thresholds);

	var td    = IFFT(chain);

	var crush = round(24-(23*pow(abs(In.kr(crushbus)),0.33)));
	var crushgain = (crush/24);

	var bad = Decimator.ar(td,s.sampleRate,crush);

	var cutoff = Lag.kr(Clip.kr(20000 - (15000 * abs(In.kr(lpbus))) ,10,20000),0.05);

	var out = LPF.ar(bad, cutoff);

	Out.ar(outbus,out*crushgain*outgain);

}).add;


SynthDef(\quad_pdf, {
	|
	inbus,
	outbus,
	gainbus,
	pitchbus,
	delaybus,
	feedbackbus
	|

	var	outgain  = Clip.kr(0.5*(In.kr(gainbus)+1),0,2);

	// input and feedback signals
	var input    = SoundIn.ar(inbus);
	var feedback = LocalIn.ar(4);

	var proc = PitchShift.ar(feedback,0.2, In.kr(pitchbus)+1);
	// feedback-delay parameters:
	var times = max(0.001,   Lag.kr(0.0+(0.5*[1,1.25,1.5,1.85] * abs(In.kr(delaybus))),0.1));
	var gain = max(0, min(1.01, abs(In.kr(feedbackbus))));
	var out  = DelayC.ar(input + proc, 1, times);

	LocalOut.ar(out*gain);
	Out.ar(outbus,outgain*out);
}).add;




SynthDef(\quad_shift, {
	|
	inbus,
	outbus,
	gainbus,
	pitchbus,
	devbus
	|

	var	outgain  = Clip.kr(0.5*(In.kr(gainbus)+1),0,2);

	// input and feedback signals
	var input     = SoundIn.ar(inbus);

	var pitch     = 500*(In.kr(pitchbus)+1);
	var deviate   = [-0.5,-0.25,0.25,0.5]*abs(In.kr(devbus));
	var proc      = input * SinOsc.ar(pitch+(pitch*deviate));
	Out.ar(outbus,outgain*proc);

}).add;


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

		var sound = gain * In.ar(in_bus);

		var saturate = 2.0;
		var level =  (saturate/(dist+saturate));
		var bform = HOASphericalHarmonics.coefN3D(~hoa_order, azim, elev) * sound * level;

		Out.ar(out_bus, bform);

}).add;




SynthDef(\aed_splitter,
	{
		|
		inbus,
		outbus_1,
		outbus_2,
		outbus_3,
		outbus_4
		|

		var azim = In.kr(inbus);
		var elev = In.kr(inbus+1);
		var dist = In.kr(inbus+2);

		// split into 4 angles

		Out.kr(outbus_1, azim);
		Out.kr(outbus_1, elev);
		Out.kr(outbus_1, dist);

		Out.kr(outbus_2, azim+(pi/2));
		Out.kr(outbus_2, elev);
		Out.kr(outbus_2, dist);

		Out.kr(outbus_3, azim+pi);
		Out.kr(outbus_3, elev);
		Out.kr(outbus_3, dist);

		Out.kr(outbus_4, azim-(pi/2));
		Out.kr(outbus_4, elev);
		Out.kr(outbus_4, dist);

}).add;

