SynthDef(\filter_effects, {
	|
	inbus,
	outbus,
	gainbus,
	pitchbus,
	devbus
	|

	// input signal
	var input     = SoundIn.ar(inbus);
	var	outgain   = Clip.kr(0.5*(In.kr(gainbus)+1),0,2);

	// filter all the signals
	var filter1   = LPF.ar(inbus, 200.0);
	var filter3   = BPF.ar(inbus, 650.0,  1.38);
	var filter4   = BPF.ar(inbus, 1550.0, 0.5);
	var filter2   = HPF.ar(inbus, 2000.0);

	// do some wavefolding
	var folder1   = Fold.ar(outgain* filter1, lo: -1.0, hi: 1.0);
	var folder2   = Fold.ar(outgain* filter2, lo: -1.0, hi: 1.0);
	var folder3   = Fold.ar(outgain* filter3, lo: -1.0, hi: 1.0);
	var folder4   = Fold.ar(outgain* filter4, lo: -1.0, hi: 1.0);

	Out.ar(outbus,[folder1, folder2, folder3, folder4]);

}).add;
