#!/bin/bash

# Update DEVICE_IP appropriately
DEVICE_IP=192.168.0.2

./home/pi/tplink_smartplug.py -t $DEVICE_IP -c off
./home/pi/tplink_smartplug.py -t $DEVICE_IP -c off
