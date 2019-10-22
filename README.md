# smart-plug-control
Control Multiple TP Link Smart Plugs without using Kasa app

# Setup
Instructions are for Ubuntu. Adapt appropriately.

1. Connect to device's WiFi network:
e.g. TP-LINK_Smart Plug_XXXX where XXXX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device):
1. Issue the following command to connect the device to your secured WiFi network:
```python
python2 tplink_smartplug.py -t 192.168.0.1 -j '{"netif":{"set_stainfo":{"ssid":"SSID","password":"PASSWORD","key_type":3}}}'
```
Replace SSID and PASSWORD appropriately.
NOTE: If your password contains any special characters such as ", ' or \ they must be escaped appropriately.

Now your device will connect to the secured network.

1. In order to issue commands, you need to find the IP address of your device. Connect your master device (e.g. computer) to the secured network and issue the following commands:
```bash
sudo nmap -sP 192.168.0.1/24 | grep -B 2 "XX:XX"
```
where XX:XX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

Record the IP address of your device.

1. Now that you have the IP address (DEVICE_IP), you can control multiple devices all on the same secured network.
Connect to the secured network with your master device and issue any commands. For example:
```python
python2 tplink_smartplug.py -t DEVICE_IP -c info
python2 tplink_smartplug.py -t DEVICE_IP -c on
python2 tplink_smartplug.py -t DEVICE_IP -c off
```
