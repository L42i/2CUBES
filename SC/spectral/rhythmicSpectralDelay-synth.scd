// rhythmicSpectralDelay

(
SynthDef(\rhythmicSpectralDelay, { |bufnum, out=0, amp=1, maxDelay=1.0, delayAmount=0.5, lowDelay=0.1, midDelay=0.2, highDelay=0.3, fftSize=1024, hopSize=0.1, bypass=0|
    var signal, chainL, chainR, lowFreqL, midFreqL, highFreqL, lowFreqR, midFreqR, highFreqR;
    var delayedL1, delayedL2, delayedL3, delayedR1, delayedR2, delayedR3, finalL, finalR;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chainL = FFT(LocalBuf(fftSize), signal[0], hop: hopSize);
    chainR = FFT(LocalBuf(fftSize), signal[1], hop: hopSize);

    lowFreqL = PV_MagBelow(chainL, 300);  // ~300Hz
    highFreqL = PV_MagAbove(chainL, 3000);  // 3000Hz~
    midFreqL = PV_Mul(PV_MagBelow(chainL, 3000), PV_MagAbove(chainL, 300));  // 300~3000Hz

    lowFreqR = PV_MagBelow(chainR, 300);
    highFreqR = PV_MagAbove(chainR, 3000);
    midFreqR = PV_Mul(PV_MagBelow(chainR, 3000), PV_MagAbove(chainR, 300));

// Random Rhythm
    // LF
    delayedL1 = DelayN.ar(IFFT(lowFreqL), maxDelay, LFNoise1.kr(1).range(0.05, lowDelay));
    delayedR1 = DelayN.ar(IFFT(lowFreqR), maxDelay, LFNoise1.kr(1.2).range(0.05, lowDelay));

    // MF
    delayedL2 = DelayN.ar(IFFT(midFreqL), maxDelay, midDelay);
    delayedR2 = DelayN.ar(IFFT(midFreqR), maxDelay, midDelay);

    // HF
    delayedL3 = DelayN.ar(IFFT(highFreqL), maxDelay, highDelay);
    delayedR3 = DelayN.ar(IFFT(highFreqR), maxDelay, highDelay);

    finalL = XFade2.ar(signal[0], delayedL3, delayAmount * 2 - 1);
    finalR = XFade2.ar(signal[1], delayedR3, delayAmount * 2 - 1);

    finalL = Select.ar(bypass, [finalL, signal[0]]);
    finalR = Select.ar(bypass, [finalR, signal[1]]);

    Out.ar(out, [finalL, finalR]);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\rhythmicSpectralDelay, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \maxDelay, 1.0,       // sec
    \delayAmount, 0.5,
    \lowDelay, 0.5,
    \midDelay, 0.9,
    \highDelay, 0.1,
    \fftSize, 2048,
    \hopSize, 0.5,
    \bypass, 0            // 0,1
]);
)


