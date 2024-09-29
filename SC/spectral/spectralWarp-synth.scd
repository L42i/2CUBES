// spectralWarp-synth

(
SynthDef(\spectralWarp, { |bufnum, out=0, amp=1, warpAmount=1.0, lfoRate=0.1, fftSize=1024, effectAmount=0.5, bypass=0|
    var signal, chain, warpedChain, warpedFreq, modulated, finalSignal;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(fftSize), signal);

    // non-linear
    warpedFreq = PV_BinScramble(chain, LFNoise1.kr(lfoRate).range(0, fftSize div: 2), warpAmount);

    modulated = PV_MagMul(warpedFreq, SinOsc.kr(lfoRate, 0, 0.5, 1));

    finalSignal = IFFT(modulated);
    finalSignal = XFade2.ar(signal, finalSignal, effectAmount * 2 - 1);
    finalSignal = Select.ar(bypass, [finalSignal, signal]);

    Out.ar(out, finalSignal);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)


(
x = Synth(\spectralWarp, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \warpAmount, 1.0,
    \lfoRate, 0.8,
    \fftSize, 2048,
    \effectAmount, 0.9,
    \bypass, 0
]);
)
