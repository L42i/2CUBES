SynthDef(\filter_effects, {
	|
	inbus,
	outbus,
	pitchbus,
	devbus
	|

	// input signal
	var input     = SoundIn.ar(inbus);

	// filter all the signals
	var filter1   = LPF.ar(inbus, 440.0, 1.0, 0.0);
	var filter2   = HPF.ar(inbus, 440.0, 1.0, 0.0);
	var filter3   = BPF.ar(inbus, 440.0, 1.0, 1.0, 0.0);
	var filter4   = BPF.ar(inbus, 440.0, 1.0, 1.0, 0.0);

	// do some wavefolding
	var folder1   = Fold.ar(in: filter1, lo: 0.0, hi: 1.0);
	var folder2   = Fold.ar(in: filter2, lo: 0.0, hi: 1.0);
	var folder3   = Fold.ar(in: filter3, lo: 0.0, hi: 1.0);
	var folder4   = Fold.ar(in: filter4, lo: 0.0, hi: 1.0);

	Out.ar(outbus,[folder1, folder2, folder3, folder4]);
}).add;
