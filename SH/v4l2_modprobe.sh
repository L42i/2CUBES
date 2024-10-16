#!/bin/bash

sudo modprobe v4l2loopback devices=2 video_nr=10,11 card_label='QuestA','QuestB' 
