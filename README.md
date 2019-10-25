# Smart Plug  Control
Control Multiple TP Link Smart Plugs (optionally using a Raspberry Pi hub) without using Kasa app

Using softsCheck guide, [Reverse Engineering the TP-Link HS110](https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/)

Instructions are for Ubuntu. Adapt appropriately.

# Table of Contents
1. [Basic Setup (Standalone)](#basic-setup-standalone)
1. [Basic Setup (Secured WiFi Network)](#basic-setup-secured-wifi-network)
1. [Advanced Setup (Raspberry Pi Hub)](#advanced-setup-raspberry-pi-hub)


# Basic Setup (Standalone)

Basic familiarity with the command line is required.

## 1. Clone Repository
Open up terminal and issue the following commands:
```console
git clone https://github.com/jonbenfri/smart-plug-control
cd smart-plug-control
```

## 2. Connect to Device's WiFi Network
Smart plugs emit their own WiFi network out of the box or after a full reset. To connect to this network using your master device (computer), scan for networks and find the correct network, e.g. "TP-LINK_Smart Plug_XXXX" where XXXX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

## 3. Issue Basic Control Commands
Now that your master device (computer) is connected to the smart plug's WiFi network, you can issue commands. For example:
```console
python2 tplink_smartplug.py -t 192.168.0.1 -c info
python2 tplink_smartplug.py -t 192.168.0.1 -c on
python2 tplink_smartplug.py -t 192.168.0.1 -c off
```

# Basic Setup (Secured WiFi Network)

Basic familiarity with the command line is required.

## 1. Clone Repository
Open up terminal and issue the following commands:
```console
git clone https://github.com/jonbenfri/smart-plug-control
cd smart-plug-control
```

## 2. Connect to Device's WiFi Network
Smart plugs emit their own WiFi network out of the box or after a full reset. To connect to this network using your master device (computer), scan for networks and find the correct network, e.g. "TP-LINK_Smart Plug_XXXX" where XXXX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

## 3. Configure Device to Connect to Secured WiFi Network

Now that your master device (computer) is connected to the smart plug's WiFi network, you can issue commands. Issue the following command to configure the smart plug to connect to your secured WiFi network:
```console
python2 tplink_smartplug.py -t 192.168.0.1 -j '{"netif":{"set_stainfo":{"ssid":"SSID","password":"PASSWORD","key_type":3}}}'
```
Replace SSID and PASSWORD appropriately.
NOTE: If your password contains any special characters such as ", ' or \ they must be escaped appropriately.

Your smart plug will immediately stop emitting its own WiFi network and connect to the specified secured WiFi network.

## 4. Find Device IP Address

In order to issue commands, you need to find the IP address of your device on the secured WiFi network. Connect your master device (e.g. computer) to the secured network and issue the following commands:
```console
sudo nmap -sP 192.168.0.1/24 | grep -B 2 "XX:XX"
```
where XX:XX are the last four hexadecimal numbers in the mac address (see sticker on back of smart plug, unique for each device).

Record the IP address of your device.

## 5. Issue Basic Control Commands

Now that you have the IP address (DEVICE_IP), you can control multiple devices all on the same secured network.
Connect to the secured network with your master device and issue any commands. For example:
```console
python2 tplink_smartplug.py -t DEVICE_IP -c info
python2 tplink_smartplug.py -t DEVICE_IP -c on
python2 tplink_smartplug.py -t DEVICE_IP -c off
```
# Advanced Setup (Raspberry Pi Hub)

Advanced familiarity with the command line and linux are required.

## 1. Set Up Raspberry Pi

Using Raspberry Pi 3 Model B. Adapt appropriately.

1. Using a computer, copy the Raspbian iso to a micro SD card and mount the card.

    For more info, see [Download Raspbian for Raspberry Pi](https://www.raspberrypi.org/downloads/raspbian/)
    
1. Enable SSH by adding an empty file named `ssh` into the boot partition by using the following command:

    ```console
    touch /path/to/boot/ssh
    ```
    Change `/path/to/boot` appropriately.
    
1. (Optional) Configure Raspberry Pi to connect to secured WiFi network. Create a file named `wpa_supplicant.conf` in the boot partition and add the following contents:
    ```console
    country=us
    update_config=1
    ctrl_interface=/var/run/wpa_supplicant

    network={
     ssid="<Name of your WiFi>"
     psk="<Password for your WiFi>"
    }
    ```
    Replace country, ssid and psk values appropriately.

1. Safely unmount micro SD card, insert into the Raspberry Pi and boot it up.

    For more info, see [Setting up a Raspberry Pi headless](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)

## 2. Set up Raspberry Pi as WiFi Access Point

Your Raspberry Pi and master device (computer) should now be connected to your network.

1. Find the IP address of the pi:
    ```console
    sudo nmap -Sp 192.168.0.0/24  # Modify IP range and bitmask appropriately for your network settings
    ```
    
1.  SSH in as user `pi` and default password `raspberry`. Change the default password by running `passwd` (without `sudo`).

1. Enable GPIO shutdown to GPIO21 by adding the following line to `/etc/config.txt':
    ```
    dtoverlay=gpio-shutdown,gpio_pin=21
    ```
    Now you can short the last two pins (#39 and #40) to safely shutdown in the event of losing SSH access. Useful for preventing mciro SD Card corruption.


1. Reboot: `sudo reboot`

1. Update and upgrade the software:
    ```console
    sudo apt-get update 
    sudo apt-get upgrade 
    sudo rpi-update
    ```
    
1. Edit `/etc/network/interfaces` as follows:
    ```
    ## Local (loopback) interface
    auto lo
    iface lo inet loopback

    ## Wired ethernet interface
    allow-hotplug eth0
    iface eth0 inet dhcp

    ## WiFi interface
    allow-hotplug wlan0
    iface wlan0 inet static
    address 192.168.0.10
    netmask 255.255.255.0
    ```
    Note: The static ip address assigned here may conflict with other devices if using a WiFi network for initial access. Be sure to perform a network scan first and pick another ip address if a potential conflict arises.
    
1. Disable `wpa_supplicant`:
    ```console
    sudo systemctl disable wpa_supplicant
    sudo systemctl mask wpa_supplicant
    ```

1. Install dnsmasq and hostapd: 
    ```console
    sudo apt install dnsmasq hostapd
    ```
    
1. Stop `dnsmasq` and `hostapd` services:
    ```console
    sudo systemctl stop dnsmasq
    sudo systemctl stop hostapd
    ```
    
1. Back up original `dnsmaq` configuration:
    ```console
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    ```
    
1. Create `/etc/dnsmasq.conf` with the following content:
    ```console
    interface=wlan0      # Use the require wireless interface - usually wlan0
    dhcp-range=192.168.0.1,192.168.0.20,255.255.255.0,24h
    no-resolv
    ```
    
    Adjust the IP range, subnet mask and lease time as desired. Ensure static IP specified in `/etc/network/interfaces` is in the range specified in `dnsmasq.conf`.
    
1. Reload `dnsmasq` configuration:
    ```console
    sudo systemctl restart dnsmasq
    sudo systemctl reload dnsmasq
    ```

1. Edit `/etc/hostapd/hostapd.conf` so it contains the following:
    ```
    interface=wlan0
    driver=nl80211
    ssid=SSID
    hw_mode=g
    channel=7
    wmm_enabled=0
    macaddr_acl=0
    auth_algs=1
    ignore_broadcast_ssid=0
    wpa=2
    wpa_passphrase=WPA_PASSPHRASE
    wpa_key_mgmt=WPA-PSK
    wpa_pairwise=TKIP
    rsn_pairwise=CCMP
    ```
    Replace `SSI`, `hw_mode`, `channel` and `wpa_passphrase` values appropriately. `ssid` and `wpa_passphrase` should not have quotes around them and `wpa_passphrase` must be 8-64 characters long.
    
1. Edit `/etc/default/hostapd` so it reads:
    ```
    DAEMON_CONF="/etc/hostapd/hostapd.conf"
    ```

1. Disable and mask wpa_supplicant. Start `hostapd` and make sure `hostapd` and `dnsmaq` are running properly:
    ```console
    sudo systemctl unmask hostapd
    sudo systemctl enable hostapd
    sudo systemctl start hostapd
    sudo systemctl status hostapd
    sudo systemctl status dnsmasq
    ```
    
1. Reboot: `sudo reboot`

1. You should now see the ssid live. Connect to it and ssh in after connecting, using the static ip specified in `/etc/network/interfaces`: `ssh pi@192.168.0.1`

For more info, see: [Setting up a Raspberry Pi as a Wireless Access Point](https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md)
