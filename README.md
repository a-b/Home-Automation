# HomeAssistant

My installation of HomeAssistant on a virtual server running on VMware ESXi 6.0.0

Components
- RFXtrx: https://home-assistant.io/components/rfxtrx/
- Z-wave:  https://home-assistant.io/components/zwave/
- MQTT:  https://home-assistant.io/components/mqtt/
- Pushbullet:  https://home-assistant.io/components/notify.pushbullet/
- Telldus Live:  https://home-assistant.io/components/tellduslive/
- HDMI CEC:  https://home-assistant.io/components/hdmi_cec/
- ASUSWRT:  https://home-assistant.io/components/device_tracker.asuswrt/
- CPU Speed:  https://home-assistant.io/components/sensor.cpuspeed/
- Generic IP camera:  https://home-assistant.io/components/camera.generic/
- Google cast:  https://home-assistant.io/components/media_player.cast/
- Lirc:  https://home-assistant.io/components/lirc/
- nmap:  https://home-assistant.io/components/device_tracker.nmap_tracker/
- Owntracks:  https://home-assistant.io/components/device_tracker.owntracks/
- Plex:  https://home-assistant.io/components/media_player.plex/
- Plex Activity:  https://home-assistant.io/components/media_player.plex/
- glances:  https://home-assistant.io/components/sensor.glances/
- yr.no:  https://home-assistant.io/components/sensor.yr/
- System Monitor: https://home-assistant.io/components/sensor.systemmonitor/
- Onky:  https://home-assistant.io/components/media_player.onkyo/
- Ping (ICMP): https://home-assistant.io/components/device_tracker.ping/
- speedtest:  https://home-assistant.io/components/sensor.speedtest/

# Deploying and installing ubuntu server 16.10
- Deploy a new virtual machine with 2cpu4cores(8vcpu) and 4GB of ram, 20GB of disk, ubuntu 64bit operating system (overkill resources but if you have the power...)
- Mount an iso for ubuntu server 16.10 and start the server
- configure it to run as user "pi" as default
- Swedish timezone and locale
- no automatic updates
- Add SMB and OpenSSH as softwares to install
Finish the installation and reboot the server, remove installation media

# Updating the Ubuntu installation

Connect to the server with Kitty (other version of PuttY)
Log in with pi/password:

to get newest repository
```
sudo apt-get update
```
to install regular and security updates
```
sudo apt-get install
```
to install any other updates
```
sudo apt-get dist-upgrade
```

# installing VMware Tools
 https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1022525

Go to Virtual Machine > Install VMware Tools (or VM > Install VMware Tools).
Run this command to create a directory to mount the CD-ROM:
```
sudo mkdir /mnt/cdrom
```
Run this command to mount the CD-ROM:
```
sudo mount /dev/cdrom /mnt/cdrom** or **sudo mount /dev/sr0 /mnt/cdrom
```
The file name of the VMware Tools bundle varies depending on your version of the VMware product. Run this command to find the exact name:
```
ls /mnt/cdrom
```
Run this command to extract the contents of the VMware Tools bundle:
```
tar xzvf /mnt/cdrom/VMwareTools-x.x.x-xxxx.tar.gz -C /tmp/
```
(Note: x.x.x-xxxx is the version discovered in the previous step)
Run this command to change directories into the VMware Tools distribution:
```
cd /tmp/vmware-tools-distrib/
```

Run this command to install VMware Tools:
```
sudo ./vmware-install.pl -d
```
Run this command to reboot the virtual machine after the installation completes:
```
sudo reboot
```
 Now is a good time to create a snapshot to have a fallback in case something goes wrong 

# installting Virtual Environment ##
 https://home-assistant.io/docs/installation/virtualenv/

reconnect to your VM via Kitty and logon
```
sudo apt-get update
sudo apt-get install python-pip python3-dev
``` 
Press Y + enter on the question to install

install the virtual environment
```
sudo pip install --upgrade virtualenv
```
Add a user for home assistant 
```
sudo adduser --system homeassistant
sudo addgroup homeassistant
```
If you plan to use a Z-Wave controller, you will need to add this user to the dialout group
```
sudo usermod -G dialout -a homeassistant
```
Create a directory for home assistant 
```
sudo mkdir /srv/homeassistant
sudo chown homeassistant:homeassistant /srv/homeassistant
```
Become the new user
```
sudo su -s /bin/bash homeassistant
```
When acting as the user "homeassistant" sudo is not needed. 

setup the new virtual environment 

```
virtualenv -p python3 /srv/homeassistant
```
Activate the virtual environment
```
source /srv/homeassistant/bin/activate
```
After that, your prompt should include (homeassistant).
Install home assistant! 
```
pip3 install --upgrade homeassistant
```
run home assistant
```
exit
```
(to logout from the user)
```
sudo -u homeassistant -H /srv/homeassistant/bin/hass
```

check that your configuration works by browsing to http://your.ip:8123 
You will probably see some componenets popping up if you are running Plex media server or other services which HA can discover automatically. 

## Create another snapshot and name it something like HABaseInstallation ##

# configure autostart  #
 https://home-assistant.io/docs/autostart/systemd/

go to /etc/systemd/system and create a new file for the systemd service
```
cd /etc/systemd/system
sudo nano home-assistant@homeassistant.service
```
copy the code below 
```
[Unit]
Description=Home Assistant
After=network.target

[Service]
Type=simple
User=homeassistant
# Make sure the virtualenv Python binary is used
Environment=VIRTUAL_ENV="/srv/homeassistant"
Environment=PATH="$VIRTUAL_ENV/bin:$PATH"
ExecStart=/srv/homeassistant/bin/hass -c "/home/homeassistant/.homeassistant"

[Install]
WantedBy=multi-user.target
```
Press ctrl+O and then enter then ctrl+x

enable the new service
```
sudo systemctl --system daemon-reload
sudo systemctl enable home-assistant@homeassistant
sudo systemctl start home-assistant@homeassistant
```
To check status of Home Assistans
```
sudo systemctl status home-assistant@homeassistant
```
Reboot your system to see that autostart works
```
sudo reboot
```

Make another snapshot! Just to be safe (mine called autostart working)

# setting up samba shares for easy configuration of HA #
 https://www.youtube.com/watch?v=iQwWEsuRWUw

If you forgot to install samba at the installation. 
```
sudo apt-get update
sudo apt-get install samba
```
edit the smb config
```
sudo nano /etc/samba/smb.conf
```
when you are in edit mode, hold down **ctrl+k** until all rows are removed (it removes one row at the time) 
then add the following information, you could edit the "netbios name" to whatever you want to call your server when accessing it from another PC

```
[global]
netbios name = HomeAssistant
server string = The HA File Center
workgroup = WORKGROUP
hosts allow =
socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536
remote announce =
remote browse sync =

[HOMEPI]
path = /home/pi
comment = No comment
browsable = yes
read only = no
valid users =
writable = yes
guest ok = yes
public = yes
create mask = 0777
directory mask = 0777
force user = root
force create mode = 0777
force directory mode = 0777
hosts allow =

[HOME ASSISTANT]
path = /home/homeassistant/.homeassistant/
comment = No comment
browsable = yes
read only = no
valid users =
writable = yes
guest ok = yes
public = yes
create mask = 0777
directory mask = 0777
force user = root
force create mode = 0777
force directory mode = 0777
hosts allow =
```

Add a user that can access the share
```
sudo smbpasswd -a pi
```
enter the password, twice

Restart Samba Service:
```
sudo service smbd restart
```
Now you should be able to access your shares via network \\yourip  and logon with the user pi+yourpassword

# installing mosquitto (MQTT broker)
 https://www.youtube.com/watch?v=AsDHEDbyLfg&t

```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install mosquitto
sudo apt-get install mosquitto-clients
sudo nano /etc/mosquitto/mosquitto.conf
```

remove the line "include_dir /etc/mosquitto/conf.d" and add the following information 
```
allow_anonymous false
password_file /etc/mosquitto/pwfile
listener 1883
```
press ctrl+o, enter, ctrl+x
```
sudo mosquitto_passwd -c /etc/mosquitto/pwfile mqtt
```
type in a password, twice 
reboot! 

if you want to access the mqtt broker from outside you network, remember to open your firewall port 1883 to the servers IP.
To test that your broker is working, open two instances of kitty and enter the first command in one of them, and the second in the other, dont forget to change the credentials info username/password to match your configuration 

first instance: 
```
mosquitto_sub -d -u username -P password -t dev/test
```

Second instance: 
```
mosquitto_pub -d -u username -P password -t dev/test -m "Hello world"
```
press enter and you'll se a published message "Hello World" in the first instance.

## adding the MQTT broker info to your HA configuration## 
Browse the share "home assistant" you created earlier and add the following to your configuration.yaml file

```
mqtt:
  broker: 192.168.1.128
  port: 1883
  client_id: home-assistant-1
  username: mqtt
  password: password
```
Save the file and reboot the server
logon to your HA site and verify that your configuration is working! 

## Removing snapshots ## 

Now that everything is up and working you can remove the previous snapshots to save up some space and keep it nice and tidy.

## creating new baseline snapshot## 
Calling it "CleanInstall" 

# Installing CEC support #
Enabeling you to control your HDMI devices through your HDMI port, if you have the possibility to connect your server to your home theatre for example.

Im going to reuse the scripts compiled for Hassbian (installation on raspberry pi) 
 https://github.com/home-assistant/hassbian-scripts#the-included-scripts

Create a new file in your home directory
```
sudo nano /home/pi/installcec.sh
```
Copy the code from the script  https://github.com/home-assistant/hassbian-scripts/blob/master/install_libcec.sh

Press ctrl+o, enter, ctrl+x

start the script
```
sudo sh installcec.sh
```
Right now I have no way of verifying that it works because there needs to be a HDMI device present (either a graphics card with HDMI that you send with pass-through to your VM, or an HDMI CEC USB adapter, search ebay for "Pulse Eight USB" and find an adapter that could work, something like "Pulse-Eight USB - CEC Adapter, for Kodi, Plex, MediaPortal, emby etc"

## creating another snapshot ##
calling it "BeforeZwaveinstallation" 

# installing openzwave control panel 

I'm going to reuse the hassbian scripts again  https://github.com/home-assistant/hassbian-scripts/blob/master/install_openzwave.sh
But we need to remove some code for the openzwave we already installed.
```
cd /home/pi
sudo nano openzwave.sh
```
copy the script from the link 

press ctrl+o, enter, ctrl+x

start the script
```
sudo openzwave.sh
```
reboot your server 
check that everything is working 

## creating new snapshot## 

Calling it "BeforeMigration# 
At this point I'm moving my RFXTtrx, Zwave and USB-IRT to my VMware server, and starting to move my old configuration files to the new server since my raspbery Pi is suffering from crashed, possibly due to the memory card not handeling all the writes being performed by Home assistans and all devices reporting statuses. 

- Adding a USB xHCI controller to my VM
- Adding my USB decices: 
- Future Devices RFXtrx433 (RFXtrx device  http://www.rfxcom.com/RFXtrx433E-USB-43392MHz-Transceiver/en)
- Future Devices USB-UIRT (My USB-UIRT http://www.usbuirt.com/ used to control IR devices)
- Sigma Designs Modem ( my Z-wave controller  http://aeotec.com/z-wave-usb-stick

Applying the new devices and rebooting the VM

##Testing the devices ##

- Z-wave
 https://home-assistant.io/docs/z-wave/

First we need to find what USB port our z-wave device is in

In kitty, enter this command: 
```
ls /dev/ttyUSB*
```
You will probably get two replies, /dev/ttyUSB0 and /dev/ttyUSB1, but in my last setup, my z-wave devices was at the port /dev/ttyACM0.
So entering this command
```
ls /dev/tty*
```
I'll find the /dev/ttyACM0 entry as well and will start to test this one. 
Add the following to your configuration.yaml file

``` 
zwave:
    usb_path: /dev/ttyACM0
``` 

Reboot the vm and you should see your devices popping up as sensors/switches depending on your already connected z-wave devices in the http://yourIP:8123/dev-state page. 


- RFXtrx 
 https://home-assistant.io/components/rfxtrx/

Check the USB Port for your RFXtrx,
In Kitty:
```
ls /dev/ttyUSB*
```
Mine was at **/dev/ttyUSB0**

Add the following to your configuration.yaml file 

```
rfxtrx:
  device: /dev/ttyUSB0
```
and
```
sensor: !include_dir_list sensors/
switch: !include_dir_list switches/
``` 
then remove the line around row 50 that says "sensor: platform yr"

Save configuration.yaml

In your home assistant share, create a new folder called **sensors** (no capitals!)
create a new file called **rfxtrx_sensors.yaml**
In that file, add the following:
```
platform: rfxtrx
automatic_add: true
```

In your home assistant share, create a new folder called **switches** (no capitals!)
create a new file called **rfxtrx_switches.yaml**
In that file, add the following:
```
platform: rfxtrx
automatic_add: true
```
Reboot! 

Triggering a motion sensor, magnetswitch or pushing a remote for a 433mhz unit will automatically add it to home assistant and you can find it in the dev page, and also at the home view (all devices will pop-up there untill it's been configured) 

## Creating persistant names for usb serial devices ## 

To make sure that our units gets locked at these "ttypoints" we can follow this guide  http://hintshop.ludvig.co.nz/show/persistent-names-usb-serial-devices/

enter command
```
lsusb
```

you will then see something like this 
```
pi@homeAssistant:~$ lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 005: ID 0e0f:0002 VMware, Inc. Virtual USB Hub
Bus 001 Device 007: ID 0403:f850 Future Technology Devices International, Ltd USB-UIRT (Universal Infrared Receiver+Transmitter)
Bus 001 Device 006: ID 0658:0200 Sigma Designs, Inc.
Bus 001 Device 004: ID 0e0f:0002 VMware, Inc. Virtual USB Hub
Bus 001 Device 003: ID 0403:6001 Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC
Bus 001 Device 002: ID 0e0f:0003 VMware, Inc. Virtual Mouse
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

```
and using the command to get the serial number for our devices
```
udevadm info -a -n /dev/ttyUSB1 | grep '{serial}' | head -n1
```
Now we have theese: 

**USB UIRT**
Bus 001 Device 007: ID 0403:f850 Future Technology Devices International, Ltd USB-UIRT (Universal Infrared Receiver+Transmitter)
pi@homeAssistant:~$ udevadm info -a -n /dev/ttyUSB1 | grep '{serial}' | head -n1
    ATTRS{serial}=="0000:0b:00.0"


**Z-Wave**
Bus 001 Device 006: ID 0658:0200 Sigma Designs, Inc.
udevadm info -a -n /dev/ttyACM0 | grep '{serial}' | head -n1
    ATTRS{serial}=="0000:0b:00.0"

**RFXtrx**
Bus 001 Device 003: ID 0403:6001 Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC
udevadm info -a -n /dev/ttyUSB0 | grep '{serial}' | head -n1
    ATTRS{serial}=="A13UPZS"

Since we cant find any serial numbers for the USB-UIRT and the RFXtrx, and we have different product ID's, we will skipp the serialnumber identification and create our UDEV rules with these three lines: 

```
SUBSYSTEM=="tty", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", SYMLINK+="zwave"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="rfxtrx"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="f850", SYMLINK+="usbuirt"

```

Create a new file for your persistant usb paths
```
sudo nano /etc/udev/rules.d/99-usb-serial.rules

```
Press ctrl+o, enter, ctrl+x

reboot the VM

Now if we check ls /dev/zwave, usbuirt and rfxtrx we can find the "mountpoints" and we can use them in our configuration, and they will always stay the same 
```
pi@homeAssistant:~$ ls /dev/zw*
/dev/zwave
pi@homeAssistant:~$ ls /dev/usb*
/dev/usbuirt
pi@homeAssistant:~$ ls /dev/rfx*
/dev/rfxtrx
```
update configuration.yaml and replace the /dev/ttyUSB0 or /dev/ttyACM0 with the mountpoint above 

```
#Zwave
zwave:
    usb_path: /dev/zwave
 
# RFXtrx
rfxtrx:
  device: /dev/rfxtrx
```

Reboot the VM and see if it works, and try removing them and changing USB ports, or insert them in different orders, they should continue to work. 

## Time for another snapshot ##

calling it "devices installed" 

# setting upp SSL encryption with Lets Encrypt #
 https://youtu.be/BIvQ8x_iTNE?t=404

Set up port forwarding of port 443 and port 80 (external and internal source/target port) to your VM
```
git clone https://github.com/letsencrypt/letsencrypt
cd letsencrypt
./letsencrypt-auto certonly --email youremail@address.com -d example.duckdns.org
```
On the "how would you like to authenticate with the Let's Encrypt CA?" page select "2  Automatically use a temporary webserver (standalone)"
Remove the port forwards setup eariler, and set port 443 to forward to port 8123 on in your router settings.
```
sudo chmod -R 777 /etc/letsencrypt
```
## configuring SSL access and password protection ## 

add the following to your configuration.yaml file

```
http:
  api_password: !secret api_password
  ssl_certificate: !secret ssl_certificate
  ssl_key: !secret ssl_key
```

In the share for home assistans, create a new filed called **secrets.yaml**
enter the following information, set a password and enter the links to the SSL cert/key you create in the previous task

```
#HTTP webpage
api_password: chooseapassword
ssl_certificate: '/etc/letsencrypt/live/domain.com/fullchain.pem'
ssl_key: '/etc/letsencrypt/live/domain.com/privkey.pem'
```
save the file and reboot the VM
Now you should be able to browse to https://yourdomain.com and receive a login prompt. 

## Copying my old configuration ## 

At this point i copied all the configuration files from my old HA instance to the new one, which caused a lot of issues with missing dependencies to different software.

1. Systemmonitor component 
incorrect argument for the ethernet connection to monitor it
```
ifconfig
```
and you will see ouput similar to this:
```
pi@homeAssistant:~$ ifconfig
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.128  netmask 255.255.255.0  broadcast 192.168.1.255
```
Changing \sensors\system_info_sensor.yaml to have arg: ens160, did not help, #return to solve#

2. NMAP / ICMP
- https://home-assistant.io/components/device_tracker.nmap_tracker/

- missing dependencies for nmap and arp
```
sudo apt-get install net-tools nmap
```
results: 
```
pi@homeAssistant:~$ nmap 192.168.1.3

Starting Nmap 7.12 ( https://nmap.org ) at 2017-03-11 11:43 CET
Nmap scan report for 192.168.1.3
Host is up (0.00012s latency).
``` 
HA could still not uses found this  https://github.com/home-assistant/home-assistant/issues/1632#issuecomment-245340774

to find where your script is for nmap use this command
```
find / -name device_tracker.py
```

open the file to edit it. 
```
sudo nano /srv/homeassistant/lib/python3.5/site-packages/homeassistant/components/device_tracker/nmap_tracker.py
```

ctrl+w and search for **cmd =**

replace 
```
cmd = *['arp', '-n', ip_address]* 
```
with
```
cmd = ['/usr/sbin/arp', '-n', ip_address]*
```

reboot the VM and it should work

3. CPU temperature 
Since I'm running on a VM, the thermal sensors for the hardware wont work. 


# Setting up backup to github #  

 https://home-assistant.io/cookbook/githubbackup/

Before doing this, make sure that all your information that is sensitive (passwords, GPS cordinates, IP's etc) are stored in the secret.yaml file, this file will not be backed up! 

```
sudo apt-get update
sudo apt-get install git
```

Create the .gitignore file and place it in your configuration folder

browse to your config directory 

```
cd /home/homeassistant/.homeassistant/
sudo git init
sudo git config user.email martikainen@live.se
sudo git config user.name Mattias
sudo git add .
sudo git commit
```

uncomment the line "initial commit", this will be a comment to all files that you upload.

login to your github account and create a new repository, I'm calling mine Homeassistant2.0
```
sudo git remote add origin https://github.com/martikainen87/Homeassistant2.0
sudo git push -u origin master
```

enter your github credentials, wait for the script to finish then check your repository 

# Setting upp LIRC to use with USB-UIRT # 
https://home-assistant.io/components/lirc/

```
sudo apt-get install lirc liblircclient-dev**
```
Im selecting USB-UIRT and USB-UIRT Direct TV reicever in the two lists you receive, not sure if this is correct.  

to be continued with how to set up your UIRT to receive/send IR commands. 




