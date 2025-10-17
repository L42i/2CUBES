# 2CUBES



## Streaming


### Install PD Stuff

    gem



### Create Virtual Video Device


    $ sudo apt-get -y install v4l2loopback-dkms

The user might need to be added to the group to grant previliges.


Create 2 virtual devices - this solution is non-permanent.

    $ sudo modprobe v4l2loopback devices=2 video_nr=10,11 card_label='Quest1','Quest2'


To make it permanent, create '''/etc/modules-load.d/v4l2loopback.conf''' with these contents:

    v4l2loopback

Or: add the line to /etc/modules.

### Stream ADB to Virtual Video Device

    $ scrcpy -s 2G0YC1ZG2P08CV --v4l2-sink=/dev/video10 -N


### Authorize Devices

Run:

    adb devices


A newly connected device will show:



    list of devices attached
    2G0YC1ZG2P08CV  unauthorized



### Receive and Process in GEM (PD)

https://github.com/umlaeute/Gem




# SCRCPY over WiFi

    $ adb shell ip route

    $ adb tcpip 5555

    $ adb connect 10.10.10.102:5555

    $ scrcpy -e --video-source=camera --camera-id=50 --video-bit-rate 10M --max-fps=20 --v4l2-sink=/dev/video10 -N --no-window --no-audio
