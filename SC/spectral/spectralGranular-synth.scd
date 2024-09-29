// spectralGranular

(
SynthDef(\spectralGranular, { |bufnum, out=0, amp=1, grainDensity=10, grainDur=0.1, maxDelay=1.0, pitchShift=1, pitchLfoRate=0.1, fftSize=1024, hopSize=0.5, effectAmount=0.5, bypass=0|
    var signal, chain, lowFreq, highFreq, delayed, granulated, grainPos, pitchMod, finalSignal;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(fftSize), signal);

    lowFreq = PV_MagBelow(chain, 1000);
    highFreq = PV_MagAbove(chain, 1000);

    delayed = IFFT(lowFreq) + IFFT(highFreq);

    // gradual pitch-shift
    pitchMod = SinOsc.kr(pitchLfoRate).range(0.8, 1.2);

    grainPos = LFNoise2.kr(2).range(0, BufDur.kr(bufnum));
    granulated = TGrains.ar(2, Impulse.kr(grainDensity), bufnum, pitchMod * pitchShift, grainPos, grainDur, 0.1, 0.1);

    finalSignal = XFade2.ar(delayed, granulated, effectAmount * 2 - 1);

    finalSignal = Select.ar(bypass, [finalSignal, signal]);

    Out.ar(out, finalSignal);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\spectralGranular, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \grainDensity, 10,      // grain/sec
    \grainDur, 0.8,         // sec
    \maxDelay, 1.0,
    \pitchShift, 1,         // 0.8~1.2
    \pitchLfoRate, 0.05,    // pitch change speed
    \fftSize, 2048,
    \hopSize, 0.5,
    \effectAmount, 0.2,
    \bypass, 0              // 0,1
]);
)

