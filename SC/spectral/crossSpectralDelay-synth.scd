// crossSpectralDelay

(
SynthDef(\crossSpectralDelay, { |bufnum, out=0, amp=1, maxDelay=1.0, delayAmount=0.5, delayTimeL=0.1, delayTimeR=0.1, bypass=0|
    var signal, chainL, chainR, delayedL, delayedR;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chainL = FFT(LocalBuf(1024), signal[0]);
    chainR = FFT(LocalBuf(1024), signal[1]);

    delayedL = DelayN.ar(IFFT(chainL), maxDelay, SinOsc.kr(1, 0, 0.5, delayTimeL));
    delayedR = DelayN.ar(IFFT(chainR), maxDelay, SinOsc.kr(1.5, 0, 0.5, delayTimeR));

    delayedL = XFade2.ar(signal[0], delayedL, delayAmount * 2 - 1);
    delayedR = XFade2.ar(signal[1], delayedR, delayAmount * 2 - 1);

    delayedL = Select.ar(bypass, [delayedL, signal[0]]);
    delayedR = Select.ar(bypass, [delayedR, signal[1]]);

    Out.ar(out, [delayedL, delayedR]);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\crossSpectralDelay, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \maxDelay, 1.0,           // sec
    \delayAmount, 0.5,        // 0~1
    \delayTimeL, 0.1,
    \delayTimeR, 0.1,
    \bypass, 0                // 0,1
]);
)

