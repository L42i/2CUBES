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

		var	outgain  = Clip.kr(pow(2*(In.kr(gainbus)+1),2),0,2);

		var	fbgain   = Clip.kr(pow(0.5*(In.kr(feedbackbus)+1),2),0,0.95);
		var density  = Clip.kr(1-abs(In.kr(densitybus)),0,1);
		var dur      = Clip.kr(In.kr(durbus)+1*0.1,0.0001,1);

		var freq     = Clip.kr(Lag.kr(20000 * (In.kr(cutoffbus)),0.1),10,12000);
		var rq       = Clip.kr(Lag.kr(In.kr(rqbus)*2,0.1),1,2);

		var feedback = LocalIn.ar(4);

		triggers     = Trig1.kr(WhiteNoise.kr([1,-1,1,-1])+[density,density,density,density],dur);

		grainer      = RHPF.ar(GrainIn.ar(1, triggers, dur, In.ar(inbus)),freq,rq);

		grainer      = DelayC.ar(grainer+feedback,2,[0.15 , 0.173 , 0.1612 , 0.1752]);

		LocalOut.ar(fbgain*grainer);

		Out.ar(outbus, grainer * outgain);

}).add;

SynthDef(\quad_grainer,
	{
		|
		outbus,
		buffer1,
		buffer2,
		centerbus    = 0,
		crushbus     = 1,
		densitybus   = 1,
		durbus       = 1,
		pitch    = 1,
		gainbus
		|

		var triggers1, triggers2, c1, c2, g1, g2;

		var	outgain  = Clip.kr(pow((In.kr(gainbus)+1),2),0,2);
		var center   = Clip.kr((In.kr(centerbus)+1)*0.5,0,1);

		var density1  = 10*pow(Clip.kr((In.kr(densitybus)+1),0,1),4);
		var density2  = 10-density1;

		var dur      = Clip.kr(0.3 * pow(In.kr(durbus),2), 0.0001, 1);
		var crush    = Clip.kr(round((24*pow(-1*In.kr(crushbus)+1,1))),1,24);

		var crushgain = 2*(pow(crush,1.2)/24);

		triggers1  = Dust.kr([density1,density1,density1,density1]);
		c1         = center + TRand.kr(0,0.1,triggers1) * BufDur.kr(buffer1);
		g1  = Dust.kr([1,1,1,1],0.5,0.5);

		triggers2  =  Dust.kr([density2,density2,density2, density2]);
		c2         = center + TRand.kr(0,0.1,triggers2) * BufDur.kr(buffer2);
		g2  = Dust.kr([1,1,1,1],0.5,0.5);

		Out.ar(outbus,   g1*outgain * crushgain* Decimator.ar(TGrains.ar(1, triggers1, buffer1, pitch, c1, dur), s.sampleRate, crush););
		Out.ar(outbus,   g2*outgain * crushgain* Decimator.ar(TGrains.ar(1, triggers2, buffer2, pitch, c2, dur), s.sampleRate, crush););

}).add;




SynthDef(\quad_filter, {
	|
	inbus,
	outbus,
	gainbus
	|

	// input signal
	var input     = In.ar(inbus);
	var	outgain   = Lag.kr(Clip.kr(1*(In.kr(gainbus)+1),0,2),0.1);

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
	lpbus,
	rqbus
	|

	var thresholds = [0.01,0.02,0.03,0.04];

	// input signal
	var input     = In.ar(inbus);
	var	outgain   = Lag.kr(Clip.kr(pow(In.kr(gainbus)+1,1)*2,0,2.5),0.1);

	// do an FFT to all the signals
	var fft = FFT(LocalBuf(2048.dup(4), 1), input);
	var chain = PV_Freeze(fft,In.kr(threshbus)>thresholds);

	var td    = IFFT(chain);

	var crush = round(24-(23*pow(abs(In.kr(crushbus)),0.33)));
	var crushgain = 2*(sqrt(crush)/24);

	var bad = Decimator.ar(td,s.sampleRate,crush);

	var cutoff = Clip.kr(Lag.kr(20000 - (20000 * pow(abs(In.kr(lpbus)),0.2)), 0.05) ,10,20000);
	var rq     = Clip.kr(Lag.kr(3 - (2*abs(In.kr(rqbus))) ,0.1), 1.0, 3.0);

	var out = RLPF.ar(bad, cutoff, 1);

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

	var	outgain  = Lag.kr(Clip.kr(0.5*(In.kr(gainbus)+1),0,2),0.1);

	// input and feedback signals
	var input    = In.ar(inbus);
	var feedback = LocalIn.ar(4);

	var proc = PitchShift.ar(feedback,0.2, Clip.kr(In.kr(pitchbus)+1,0.01,2));

	var maindelay = Clip.kr(abs(In.kr(delaybus)),0.0001,10);

	// feedback-delay parameters:
	var times = max(0.001,   Lag.kr(0.0+(0.5*[1,1.25,1.5,1.85] * maindelay),0.1));

	var gain  = max(0.0, min(0.99, abs(In.kr(feedbackbus))));

	var out   = DelayC.ar(input + proc, 1, times);

	LocalOut.ar(out*gain);

	Out.ar(outbus,outgain*out);
}).add;




SynthDef(\quad_shift, {
	|
	inbus,
	outbus,
	gainbus,
	pitchbus,
	devbus,
	foldbus
	|

	var	outgain  = Lag.kr(Clip.kr(0.5*(In.kr(gainbus)+1),0,1.5), 0.1);
	var	fold     = Clip.kr(10*(In.kr(foldbus))+1,0.01,10);

	// input and feedback signals
	var input     = In.ar(inbus);

	var pitch     = 500*(In.kr(pitchbus)+1);
	var deviate   = [-0.5,-0.25,0.25,0.5]*abs(2*In.kr(devbus));
	var proc      = input * Fold.ar(fold*SinOsc.ar(pitch+(pitch*deviate)), -1, 1);
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





SynthDef(\channel_strip, {

	|
	in_chan   = nil,
	out_chan  = nil,
	//
	gain             = 1,
	autogain        = 0,
	//
	freq             = 1,
	lp_fixed_ratio   = 1,
	rq               = 1.0,
	//
	hp_cutoff        = 1,
	hp_fixed         = 1,
	hp_reso          = 1
	|

	var out;

	var f = Lag.kr(freq,0.01);

	var input_sig  = SoundIn.ar(in_chan);

	var g   = autogain * gain;

	var fc_lp = min(20000,max(2, Lag.kr(lp_fixed_ratio, 0.01) * f));
	var fc_hp = min(20000,max(2, Lag.kr(hp_cutoff, 0.01)      * hp_fixed));


	rq      = max(min(rq,1), 0.1);
	hp_reso = max(min(hp_reso,10), 0.1);

	out = g * RHPF.ar(RLPF.ar(input_sig, fc_lp, rq), fc_hp, hp_reso);

	Out.ar(out_chan, out);

}).add;