// spectralDelay (test with the buffer input)

(
SynthDef(\spectralDelayWithBuffer, { |bufnum, out=0, amp=1, maxDelay=1.0, delayAmount=0.5, delayTime=0.1, bypass=0|
    var signal, chain, delayed, original;

    signal = PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(1024), signal);

    delayed = DelayN.ar(IFFT(chain), maxDelay, delayTime);

    delayed = XFade2.ar(signal, delayed, delayAmount * 2 - 1);

    delayed = Select.ar(bypass, [delayed, signal]);

    Out.ar(out, delayed);
}).add;
)

// test!
(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\spectralDelayWithBuffer, [
    \bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \maxDelay, 10.0,          // sec
    \delayAmount, 0.5,       // 0~1
    \delayTime, 0.9,         // sec
    \bypass, 0               // 0,1
]);
)

