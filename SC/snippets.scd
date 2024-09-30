s.options.numOutputBusChannels = 4;
s.boot;


c = {Out.kr(0,MouseX.kr(-1.1))}.play;
d = {Out.kr(1,MouseY.kr(-1.1))}.play;

s.scope(1,0,rate:'control')
x = Synth(\quad_freezer,[\threshbus, 0, \crushbus,1, \lpbus, 1])




~midi_sender_N1.stop;
~midi_sender_N2.stop;
~midi_sender_DARK.stop;