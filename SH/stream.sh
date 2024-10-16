#!/bin/bash

tmux new-session -d -s QUEST

tmux send-keys -t QUEST 'scrcpy -s 2G0YC1ZG2P08CV --v4l2-sink=/dev/video10 --bit-rate 20M --max-fps=30 -N' C-m

tmux split-window -h -t QUEST

tmux send-keys -t QUEST 'scrcpy -s 2G0YC1ZF870S25 --v4l2-sink=/dev/video11 --bit-rate 20M --max-fps=30 -N' C-m

tmux attach-session -t QUEST
