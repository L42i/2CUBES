(
SynthDef(\spectralStretch, { |bufnum, out=0, amp=1, stretchAmount=1.5, pitchModRate=0.1, fftSizeSelector=1, effectAmount=0.5, bypass=0|
    var signal, chain, stretched, pitchMod, finalSignal, fftSize;

    // fft size selection (1 -> 512, 2 -> 1024, 3 -> 2048, 4 -> 4096, 5 -> 8192)
    fftSize = Select.kr(fftSizeSelector - 1, [512, 1024, 2048, 4096, 8192]);

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(fftSize), signal);

    stretched = PV_BinShift(chain, stretchAmount, 0);

    pitchMod = PV_PhaseShift(stretched, SinOsc.kr(pitchModRate).range(-1, 1));

    finalSignal = IFFT(pitchMod);
    finalSignal = XFade2.ar(signal, finalSignal, effectAmount * 2 - 1);
    finalSignal = Select.ar(bypass, [finalSignal, signal]);

    Out.ar(out, finalSignal);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\spectralEffectWithFFTSelection, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \stretchAmount, 3.5,
    \pitchModRate, 1.5,        // speed
    \fftSizeSelector, 5,
    \effectAmount, 0.5,
    \bypass, 0                 // 0,1
]);
)
