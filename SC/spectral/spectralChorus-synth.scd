//spectralChorus

(
SynthDef(\spectralChorus, { |bufnum, out=0, amp=1, lowChorusRate=0.1, midChorusRate=0.2, highChorusRate=0.3, lowChorusDepth=0.01, midChorusDepth=0.01, highChorusDepth=0.01, fftSize=1024, effectAmount=0.5, bypass=0|

    var signal, chain, lowFreq, midFreq, highFreq, lowChorus, midChorus, highChorus, finalSignal, crossoverLow, crossoverMid;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(fftSize), signal);

    crossoverLow = 400;
    crossoverMid = 2000;

    lowFreq = PV_MagBelow(chain, crossoverLow);
    midFreq = PV_MagClip(chain, crossoverLow, crossoverMid);
    highFreq = PV_MagAbove(chain, crossoverMid);

    lowChorus = IFFT(lowFreq) * (1 + SinOsc.ar(lowChorusRate, 0, lowChorusDepth));
    midChorus = IFFT(midFreq) * (1 + SinOsc.ar(midChorusRate, 0, midChorusDepth));
    highChorus = IFFT(highFreq) * (1 + SinOsc.ar(highChorusRate, 0, highChorusDepth));

    finalSignal = lowChorus + midChorus + highChorus;

    finalSignal = XFade2.ar(signal, finalSignal, effectAmount * 2 - 1);

    finalSignal = Select.ar(bypass, [finalSignal, signal]);

    Out.ar(out, finalSignal);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\spectralChorus, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \lowChorusRate, 0.8,  // LFO rate
    \midChorusRate, 0.1,
    \highChorusRate, 0.8,
    \lowChorusDepth, 0.02,
    \midChorusDepth, 0.02,
    \highChorusDepth, 0.08,
    \fftSize, 2048,
    \effectAmount, 0.8,
    \bypass, 0             // 0,1
]);
)
