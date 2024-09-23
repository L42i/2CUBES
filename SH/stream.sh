#!/bin/bash

sudo modprobe v4l2loopback devices=2 video_nr=10,11 card_label='QuestA','QuestB' 

scrcpy -s 2G0YC1ZG2P08CV --v4l2-sink=/dev/video10 -N &
scrcpy -s 2G0YC1ZF870S25 --v4l2-sink=/dev/video11 -N &
