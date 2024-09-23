# 2CUBES

    $ adb devices







### Create Virtual Video Device


    $ sudo apt-get -y install v4l2loopback-dkms

The user might need to be added to the group to grant previliges.


Create 2 virtual devices - this solution is non-permanent.

    $ sudo modprobe v4l2loopback devices=2 video_nr=10,11 card_label='Quest1','Quest2'


To make it permanent, create '''/etc/modules-load.d/v4l2loopback.conf''' with

    $ sudo echo "options v4l2loopback devices=2 video_nr=10,11 card_label='Quest1','Quest2'" > /etc/modprobe.d/v4l2loopback.conf


### Stream ADB to Virtual Video Device

    $ scrcpy -s 2G0YC1ZG2P08CV --v4l2-sink=/dev/video10 -N




### Receive and Process in GEM (PD)

https://github.com/umlaeute/Gem


