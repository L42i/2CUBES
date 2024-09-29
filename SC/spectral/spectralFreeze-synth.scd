// spectralFreeze

(
SynthDef(\spectralFreeze, { |bufnum, out=0, amp=1, freezeRate=0.2, modRate=0.1, modAmount=0.5, fftSize=1024, freezeAmount=0.5, bypass=0|

	var signal, chain, frozen, modulated, finalSignal, xPos, yPos;

	xPos = MouseX.kr(0.5, 2.0, 1);
    yPos = MouseY.kr(0.1, 1.0, 1);

	signal = SoundIn.ar(0);
	//PlayBuf.ar(2, bufnum, loop: 1) * amp;

    chain = FFT(LocalBuf(fftSize), signal);

    frozen = PV_Freeze(chain, MouseY.kr > 0.5);

    modulated = PV_MagMul(frozen, SinOsc.kr(modRate, 0, modAmount, 1));

    finalSignal = IFFT(modulated);

    //finalSignal = XFade2.ar(signal, finalSignal, freezeAmount * 2 - 1);
	//finalSignal = Select.ar(bypass, [finalSignal, signal]);

    Out.ar(out, finalSignal);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/shinhyunkyung/music_speech_data/music_wav/winds.wav");
)

(
x = Synth(\spectralFreeze, [
    //\bufnum, ~buffer.bufnum,
    \out, 0,
    \amp, 1.0,
    \freezeRate, 0.1,
    \modRate, 0.1,
    \modAmount, 0.5,
    \fftSize, 2048,
    \freezeAmount, 0.8,
    \bypass, 0
]);
)
