INTERFACE=EVO16


# sudo ~/Desktop/cpu-set-all.sh -g performance


tmux new-session -d -s 2CUBES

tmux send-keys -t 2CUBES 'jackd -P 95 -a a -d dummy -C 8 -P 28' C-m

sleep 3

tmux split-window -h -t 2CUBES
tmux send-keys -t 2CUBES 'scide ../SC/2_Cubes.scd' C-m

tmux split-window -h -t 2CUBES
tmux send-keys -t 2CUBES 'iem-plugin-allradecoder -loadSettings ../setup/Rich-133B_28-Speakers.json' C-m

sleep 5

tmux split-window -h -t 2CUBES
tmux send-keys -t 2CUBES 'aj-snapshot -x -d ../setup/Rich133B_jacktrip.snap' C-m


tmux split-window -h -t 2CUBES
tmux send-keys -t 2CUBES 'qjackctl' C-m


tmux select-layout -t 2CUBES tiled

tmux attach-session -t 2CUBES

