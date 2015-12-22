<br>
![OSLOGO](https://wiki.smartos.org/download/attachments/753666/DOC?version=1&modificationDate=1333386297000)
<br>

#SmartOS, from scratch

##Base OS

### Download

https://github.com/joyent/sdc

#### Cloud On A Laptop (VMware):
```
curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz
```        
#### USB key image:
```
curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/usb-latest.tgz
```

#### Make USB key

https://docs.joyent.com/private-cloud/install/usb-key/mac-osx

### Install

https://docs.joyent.com/private-cloud/install

or

https://wiki.smartos.org/display/DOC/SmartOS+Clean+Re-install

#### boot console change required?

```
variable os_console vga
```
Note: If the system sits a flashing cursor or does not show any activity for an extended period of time (greater than 20 minutes) you may need to change the Console. Please see Changing the boot-time console for details.

https://docs.joyent.com/private-cloud/install#bootconsole

Changing the boot-time console
To change to a different console device, prior to booting the Live 64 Bit menu item, you will need to:

* Scroll down to the Live 64 Bit menu option.
* Press the c key to open a command window.
* Enter one of the following:



### Post Install

https://docs.joyent.com/private-cloud/install/post-installation#AddingExternalNICstoHeadNodeVMs

#### SSH Keys

https://docs.joyent.com/private-cloud/install#sshkeys

Populating root's authorized_keys file on boot
It is possible to have Triton Elastic Container Infrastructure automatically add SSH keys to the ~root/.ssh/authorized_keys file on boot. To do this, you need to add a file called root.authorized_keys to the /mnt/usbkey/config.inc directory on the USB key.

Note: The directory path given assumes you are mounting under /mnt/usbkey. You will need to adjust this as appropriate. For example, under /Volumes/HEADNODE if you are mounting it under OS X.

#### If just a headnode, no cluster then need to allow headnode provioning

```
sdcadm post-setup dev-headnode-prov
```

#### In order to downlaod images via SDC, the SDC zone needs an external link

```
sdcadm post-setup common-external-nics
```

##### Possible error if via SSH
```
sdcadm post-setup: error: requests must originate from CNAPI address
```

#### Patch your "s"

```
sdcadm self-update --latest

OUTPUT

Update to sdcadm 1.9.0 (master-20151221T171321Z-gabeeae7)
Download update from https://updates.joyent.com
Run sdcadm installer (log at /var/sdcadm/self-updates/20151222T062616Z/install.log)
Updated to sdcadm 1.9.0 (master-20151221T171321Z-gabeeae7, elapsed 24s)

```

#### Find your Admin UI ip address

To connect to the admin UI you need its IP.... find it with this command


```
vmadm list -o uuid,type,ram,nics.0.ip,quota,alias | grep -v KVM

```
and look for

```
........ 192.168.3.74          25     adminui0
```
so in this case we need to hit

https://192.168.3.74/

```
OUTPUT

UUID                                  TYPE  RAM      NICS.0.IP             QUOTA  ALIAS
74f4581d-eae8-4b7b-adce-262490086b11  OS    128      192.168.3.52          25     dhcpd0
80df3d39-9f7a-4f1c-8211-69e1599f0439  OS    128      192.168.3.51          25     assets0
f26024ab-4885-4704-912b-6e0141963d38  OS    256      192.168.3.53          25     napi0
06936339-9b04-4198-bfe9-5552d1010568  OS    512      192.168.3.75          25     sapi0
01c700a6-fc5a-4f20-9de5-75bd6fc8f061  OS    768      192.168.3.64          500    imgapi0
0cca8147-d54b-46c8-a799-f2d3450e2ce0  OS    1024     192.168.3.81          25     cloudapi0
2d8a57c8-0ec6-45e6-a72e-8b6d514c7f89  OS    1024     192.168.3.68          25     amon0
898dc86a-911a-4807-88c7-b3a9f68cba9f  OS    1024     192.168.3.76          25     mahi0
9d37a5ec-8d36-4610-9d00-5759183bd227  OS    1024     192.168.3.66          25     amonredis0
9ec8da42-c542-453d-aec2-17ba84d033a1  OS    1024     192.168.3.67          25     redis0
a3101294-ae7e-459e-8373-6ef8a78561df  OS    1024     192.168.3.69          25     fwapi0
af1337b0-bdb1-4875-a7ac-2e11f1fbc0b3  OS    1024     192.168.3.70          25     vmapi0
cbc626d5-7067-4529-b0b3-7fccc717ef87  OS    1024     192.168.3.65          25     cnapi0
e2153c53-7003-4551-ad66-055b8409872c  OS    1024     192.168.3.71          25     sdc0
ea94c792-be2a-4604-bed4-7fbf4407bd1c  OS    1024     192.168.3.54          25     binder0
eb4f5b6a-ee95-4283-9b0a-b981dbb00231  OS    1024     192.168.3.72          25     papi0
0b149fbf-278b-46cc-9a92-1bd8faf0c4b2  OS    2048     192.168.3.59          50     manatee0
18965243-0410-4b84-a317-e38c87fef581  OS    2048     192.168.3.63          25     rabbitmq0
7ffc990d-4082-4525-88fd-cee0acef40f9  OS    2048     192.168.3.74          25     adminui0
5d9aaf63-0105-44b7-87e2-d70f376ec2b5  OS    4096     192.168.3.73          25     ca0
18e26bcc-a062-4a86-a9ff-341075a94f80  OS    8192     192.168.3.60          25     moray0
474d8049-0884-495f-890f-dd7a51ab72ce  OS    8192     192.168.3.62          25     workflow0
fe6b8008-fdcc-44ea-859f-87589a93e25d  OS    8192     192.168.3.61          25     ufds0
```

### Create VMs

#### How to create a Virtual Machine in SmartOS

https://wiki.smartos.org/display/DOC/How+to+create+a+Virtual+Machine+in+SmartOS

#### KVMs (General)
https://wiki.smartos.org/display/DOC/How+to+create+a+KVM+VM+(+Hypervisor+virtualized+machine+)+in+SmartOS

#### Docker

https://docs.joyent.com/private-cloud/install/post-installation#setting-up-docker

#### Plex
http://lightsandshapes.com/plex-on-smartos.html

#### Pfsense

https://forum.pfsense.org/index.php?topic=69820.0

#### SmartOS VM Migration using DD & Netcat

https://www.youtube.com/watch?v=7xrb_WZZ-Cs

### Delete / manage existing VMs

https://wiki.smartos.org/display/DOC/Using+vmadm+to+manage+virtual+machines#Usingvmadmtomanagevirtualmachines-DeletingaVM



### VNC notes

https://github.com/TigerVNC/tigervnc/releases

connect to **admin IP** and zone port (not zone IP)

### Tools

http://timboudreau.com/blog/smartos/read

#### GB / MB Rounding

In oder to create a machine via SDC you need the **exact** size (e.g. 40000 mb is not accurate enough) so 40Gb is actually 40960 MB so you need to 40960, no less, no more.... (note google is not strict enough)

use this converter to help

http://www.convertunits.com/from/GB/to/MB

#### AWESOME TIPS

https://wiki.smartos.org/display/DOC/SmartOS+Command+Line+Tips



---------------------------

# PFsense Specific (in progress - don't follow!)

https://wiki.smartos.org/display/DOC/Managing+NICs

```
dladm create-vnic -l e1000g1 pfsenseguest0
dladm create-vnic -l e1000g0 pfsenselan0

ifconfig pfsenseguest0 plumb
ifconfig pfsenselan0 plumb
ifconfig pfsenseguest0 dhcp
ifconfig pfsenselan0 dhcp
```

### I generally create a permanent home for ISO images and JSON files:

```
zfs create zones/images
```
* Place the pfSense ISO there

## identify the MAC addresses of the Ethernet interfaces
```
dladm show-phys -m

[root@smartoshost ~]# dladm show-phys -m
LINK         SLOT     ADDRESS            INUSE CLIENT
bnx0         primary  a4:ba:db:3e:ad:a1  yes  bnx0
e1000g0      primary  0:15:17:ec:1:d3    yes  e1000g0
bnx1         primary  a4:ba:db:3e:ad:a3  yes  bnx1
e1000g2      primary  0:15:17:ec:1:cd    yes  e1000g2
e1000g1      primary  0:1b:21:57:c:85    yes  e1000g1
```
**e1000g0 is probably the 'admin' interface, verify this by viewing /usbkey/config.**

* Then edit /usbkey/config and add a line for the 2nd MAC address as follows:

```
external_nic=xx:xx:xx:xx:xx:xx (substitute the 2nd MAX address)
```

* re-boot SmartOS
* Create the pfsense.json file (below) in zones/images
* Modify the IP information as appropriate
* The admin NIC is shared with SmartOS so it should be on the INSIDE (LAN) subnet,
* the external NIC is the INTERNET/PUBLIC/WAN side
**Note the vnc port number is specified - this must be unique.**
**The VM is set to not autoboot - change this later using**
```
vmadm update $UUID autoboot=true
```


```
zfs create zones/images
```



```json
{
  "brand": "kvm",
  "vcpus": 1,
  "ram": 1024,
  "hostname": "pfsense",
  "alias": "pfsense",
  "resolvers": ["192.168.2.1", "8.8.8.8"],
  "vnc_port": "40000",
  "autoboot": "false",
  "disks": [
    {
      "boot": true,
      "model": "ide",
      "size": 4096
    }
  ],
  "nics": [
    {
      "nic_tag": "admin",
      "model": "e1000",
      "ip": "192.168.3.1",
      "netmask": "255.255.0.0",
      "gateway": "192.168.2.1",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true,
      "primary":"1"
    },
    {
      "nic_tag": "external",
      "model": "e1000",
      "ip": "192.168.2.30",
      "netmask": "255.255.0.0",
      "gateway": "192.168.2.1",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true
    },
    {
      "nic_tag": "GuestLAN",
      "model": "e1000",
      "ip": "192.168.4.2",
      "netmask": "255.255.0.0",
      "gateway": "192.168.2.1",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true
    }
  ]
}
```


```
vmadm create -f pfsense.json
```
substitute the created VM's UUID for $UUID in the following commands, or
```
export UUID=zoneuuid
```
```
cp /zones/images/pfSense-LiveCD-2.0.3-RELEASE-amd64.iso  /zones/$UUID/root/
vmadm boot $UUID order=cd,once=d cdrom=/pfSense-LiveCD-2.0.3-RELEASE-amd64.iso,ide
```

## This step can probably be done before booting the VM -- and should be, if possible

### examine the active JSON using:

```
vmadm get $UUID | less
```

and write down the last 4 digits of the MAC addresses for the admin and external nics, eg:

```
admin=a9:af
external=aa:ab

```

```json
[root@smartoshost /opt]# vmadm get $UUID
{
  "zonename": "6362bbce-ff4b-6db3-cdd3-bf6e508242dc",
  "autoboot": true,
  "brand": "kvm",
  "limit_priv": "default,-file_link_any,-net_access,-proc_fork,-proc_info,-proc_session",
  "v": 1,
  "create_timestamp": "2015-12-17T01:07:15.174Z",
  "cpu_shares": 100,
  "max_lwps": 2000,
  "max_msg_ids": 4096,
  "max_sem_ids": 4096,
  "max_shm_ids": 4096,
  "max_shm_memory": 2048,
  "zfs_io_priority": 100,
  "max_physical_memory": 2048,
  "max_locked_memory": 2048,
  "max_swap": 2048,
  "billing_id": "00000000-0000-0000-0000-000000000000",
  "owner_uuid": "00000000-0000-0000-0000-000000000000",
  "hostname": "pfsense",
  "resolvers": [
    "192.168.2.1",
    "8.8.8.8"
  ],
  "alias": "pfsense",
  "ram": 1024,
  "vcpus": 1,
  "vnc_port": 40000,
  "disks": [
    {
      "path": "/dev/zvol/rdsk/zones/6362bbce-ff4b-6db3-cdd3-bf6e508242dc-disk0",
      "boot": true,
      "model": "ide",
      "media": "disk",
      "zfs_filesystem": "zones/6362bbce-ff4b-6db3-cdd3-bf6e508242dc-disk0",
      "zpool": "zones",
      "size": 4096,
      "compression": "off",
      "refreservation": 4096,
      "block_size": 8192
    }
  ],
  "nics": [
    {
      "interface": "net0",
      "mac": "b2:64:a0:b2:43:c9",
      "nic_tag": "admin",
      "gateway": "192.168.2.1",
      "gateways": [
        "192.168.2.1"
      ],
      "netmask": "255.255.0.0",
      "ip": "192.168.2.1",
      "ips": [
        "192.168.2.1/16"
      ],
      "model": "e1000",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true,
      "primary": true
    },
    {
      "interface": "net1",
      "mac": "e2:26:d1:5e:10:98",
      "nic_tag": "external",
      "gateway": "192.168.3.1",
      "gateways": [
        "192.168.3.1"
      ],
      "netmask": "255.255.0.0",
      "ip": "192.168.3.2",
      "ips": [
        "192.168.3.2/16"
      ],
      "model": "e1000",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true
    },
    {
      "interface": "net2",
      "mac": "a2:66:b8:9a:ef:70",
      "nic_tag": "GuestLAN",
      "gateway": "192.168.2.1",
      "gateways": [
        "192.168.2.1"
      ],
      "netmask": "255.255.0.0",
      "ip": "192.168.4.2",
      "ips": [
        "192.168.4.2/16"
      ],
      "model": "e1000",
      "allow_dhcp_spoofing": true,
      "allow_ip_spoofing": true,
      "allow_mac_spoofing": true,
      "allow_restricted_traffic": true
    }
  ],
  "uuid": "6362bbce-ff4b-6db3-cdd3-bf6e508242dc",
  "zone_state": "running",
  "zonepath": "/zones/6362bbce-ff4b-6db3-cdd3-bf6e508242dc",
  "zoneid": 4,
  "last_modified": "2015-12-17T01:09:14.000Z",
  "firewall_enabled": false,
  "server_uuid": "44454c4c-4400-1059-804a-c6c04f353253",
  "platform_buildstamp": "20151210T194528Z",
  "state": "running",
  "boot_timestamp": "2015-12-17T01:09:13.000Z",
  "pid": 7287,
  "customer_metadata": {},
  "internal_metadata": {},
  "routes": {},
  "tags": {},
  "quota": 10,
  "zfs_root_recsize": 131072,
  "zfs_filesystem": "zones/6362bbce-ff4b-6db3-cdd3-bf6e508242dc",
  "zpool": "zones",
  "snapshots": []
}
```

##vnc to the IP address and port 40000
**if you reach the session before the boot timeout occurs, take option "i" to install**

## Respond to prompts as follows:

Accept these options

* Quick/Easy install
* Standard Kernel

### After the reboot look for some lines that say:

```
Valid interfaces are:
# em0   xx:xx:xx:xx:xx:xx
# em1   xx:xx:xx:xx:xx:xx
```

Determine which of these matches the "admin" MAC address you noted earlier -- that is your LAN interface!

The other MAC address should match the "external" MAC address you noted - that is your WAN interface!

```
Do you want to setup VLANs now? N
Enter the WAN interface name...: em?   (select the interface with a MAC address matching your external_nic)
Enter the LAN interface name...: em?   (select the interface with a MAC address matching your admin_nic)
Enter the optional 1 interface name...: (enter)
```
```
From the menu:
2: Set interface(s) IP address
remember WAN = external_nic
enter IP, netmask as prompted
Do you want to revert to HTTP as the webConfigurator protocol? Y
```

Repeat menu option #2 for WAN, LAN

* Restart webConfigurator
* Enable Secure Shell (sshd)
