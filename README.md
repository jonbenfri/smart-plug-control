# Smart Plug  Control
Control Multiple TP Link Smart Plugs (optionally using a Raspberry Pi hub) without using Kasa app

Using softsCheck guide, [Reverse Engineering the TP-Link HS110](https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/)

Instructions are for Ubuntu. Adapt appropriately.

# Table of Contents
1. [Basic Setup (Standalone)](#basic-setup-standalone)
2. [Basic Setup (Secured WiFi Network)](#basic-setup-secured-wifi-network)
3. [Advanced Setup (Raspberry Pi Hub)](#advanced-setup-raspberry-pi-hub)


# Basic Setup (Standalone)

## 1. Connect to Device's WiFi Network
Smart plugs emit their own WiFi network out of the box or after a full reset. To connect to this network using your master device (computer), scan for networks and find the correct network, e.g. "TP-LINK_Smart Plug_XXXX" where XXXX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

## 2. Issue Basic Control Commands
Now that your master device (computer) is connected to the smart plug's WiFi network, you can issue commands. For example:
```console
python2 tplink_smartplug.py -t 192.168.0.1 -c info
python2 tplink_smartplug.py -t 192.168.0.1 -c on
python2 tplink_smartplug.py -t 192.168.0.1 -c off
```

# Basic Setup (Secured WiFi Network)

## 1. Connect to Device's WiFi Network
Smart plugs emit their own WiFi network out of the box or after a full reset. To connect to this network using your master device (computer), scan for networks and find the correct network, e.g. "TP-LINK_Smart Plug_XXXX" where XXXX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

## 2. Configure Device to Connect to Secured WiFi Network

Now that your master device (computer) is connected to the smart plug's WiFi network, you can issue commands. Issue the following command to configure the smart plug to connect to your secured WiFi network:
```console
python2 tplink_smartplug.py -t 192.168.0.1 -j '{"netif":{"set_stainfo":{"ssid":"SSID","password":"PASSWORD","key_type":3}}}'
```
Replace SSID and PASSWORD appropriately.
NOTE: If your password contains any special characters such as ", ' or \ they must be escaped appropriately.

Your smart plug will immediately stop emitting its own WiFi network and connect to the specified secured WiFi network.

## 3. Find Device IP Address

In order to issue commands, you need to find the IP address of your device on the secured WiFi network. Connect your master device (e.g. computer) to the secured network and issue the following commands:
```bash
sudo nmap -sP 192.168.0.1/24 | grep -B 2 "XX:XX"
```
where XX:XX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

Record the IP address of your device.

## 4. Issue Basic Control Commands

Now that you have the IP address (DEVICE_IP), you can control multiple devices all on the same secured network.
Connect to the secured network with your master device and issue any commands. For example:
```console
python2 tplink_smartplug.py -t DEVICE_IP -c info
python2 tplink_smartplug.py -t DEVICE_IP -c on
python2 tplink_smartplug.py -t DEVICE_IP -c off
```
# Advanced Setup (Raspberry Pi Hub)

## 1. Set Up Raspberry Pi (Headless)

1. Using a computer, copy Raspbian iso to micro SD card and mount it. See: 
1. Enable SSH by adding an ssh file in boot partition using the following command:
```console
touch /path/to/boot/ssh
```
1. Configure Raspberry Pi to connect to secured WiFi network. Create a file named `wpa_supplicant.conf` in the boot partition and add the following contents:
```console
country=us
update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
 ssid="<Name of your WiFi>"
 psk="<Password for your WiFi>"
}
```
Replace ssid and psk values appropriately.

1. Safety unmount micro SD card, insert into the Raspberry Pi and boot it up.

See: [Setting up a Raspberry Pi headless](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)
