<br>
![OSLOGO](https://wiki.smartos.org/download/attachments/753666/DOC?version=1&modificationDate=1333386297000)
<br>

#SmartOS - SmartDataCenter, from scratch, at home, with minimal gear..

## My Setup

* Dell T601
* 6i raid card
* 2 x 300gb drives
* 2 x 2 tb drives
* 16 GB ECC ram
* "Dumb" GB switch (so no vlans for me :( next time...)
* Old tplink wifi switch (for admin network)

## Before you begin, nuggets of wisdom...

* The **ADMIN** and **External** networks MUST be separate subnets
	* I used an old wifi router for **admin** on 192.168.10.1, you then need to give your laptop a static IP in that range to connect
	* The **external** went to my LAN on 192.168.2.x
	* later when provisioning a machine - ensure they are connected to the **external** network so they show up on your LAN
	* VNC is bound to the **ADMIN** network so need to connect to that to use it (I'm looking how to move it to the LAN side... but if thats your internet watch for security issues)
* SDC installer does what it will with your disks, no options during install
	* So i used 1 x 300gb for the initial install
	* then before you add any zones follow the "zpool expand" section below (adapt to match your config)

## Base OS

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

#### boot console change required?... mine did

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

#### SSH Keys

https://docs.joyent.com/private-cloud/install#sshkeys

Populating root's authorized_keys file on boot
It is possible to have Triton Elastic Container Infrastructure automatically add SSH keys to the ~root/.ssh/authorized_keys file on boot. To do this, you need to add a file called root.authorized_keys to the /mnt/usbkey/config.inc directory on the USB key.

Note: The directory path given assumes you are mounting under /mnt/usbkey. You will need to adjust this as appropriate. For example, under /Volumes/HEADNODE if you are mounting it under OS X.

#### If just a headnode (no cluster/ other compute nodes) then need to allow headnode provisioning

```
sdcadm post-setup dev-headnode-prov
```

#### In order to download images via SDC, the SDC adminui zone needs an external link

```
sdcadm post-setup common-external-nics
```
#### Save disk space with compression
```
zfs set compression=on zones && zfs get compression zones
```

```
zfs get compressratio zones
```

##### Error I got after wiping the zpool and then not fresh installing SDC on USB

I found no way out of this except to go back to make a new SDC image... and start from scratch

```
sdcadm post-setup: error: requests must originate from CNAPI address
```

#### Patch your "s"

Update!

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

#### Adding more NICs

https://docs.joyent.com/private-cloud/install/post-installation#AddingExternalNICstoHeadNodeVMs

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

vmadm info <UUID> vnc

### zpool expand

http://blog.beulink.org/smartos-mirroring-your-zones-pool/

http://blog.alainodea.com/en/article/448/making-a-zfs-4-disk-mirrored-vdev-zpool-on-smartos-on-r720xd

When prompted at install I selected c0t0d0 as the drive for the zones zpool.

Here is how I made it a mirrored vdev zpool:

```
zpool attach zones c0t0d0 c0d1t0
zpool add zones mirror c0t2d0 c0t3d0
```

Running zpool status shows the following:

```
 pool: zones
 state: ONLINE
  scan: resilvered 4.00G in 0h0m with 0 errors on Fri Jan 18 01:11:15 2013
config:

        NAME        STATE     READ WRITE CKSUM
        zones       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            c0t0d0  ONLINE       0     0     0
            c0t1d0  ONLINE       0     0     0
          mirror-1  ONLINE       0     0     0
            c0t2d0  ONLINE       0     0     0
            c0t3d0  ONLINE       0     0     0
```

If you have mismatched disks like me, start smalles first and create the pool.

now my plan is to replace the 300gb with 2 tb as money allows, so i will turn on auto expand so as i replace the disks the pool grows and i can fit more machines

```
zpool set autoexpand=on zones
```

### Tools

http://timboudreau.com/blog/smartos/read

#### GB / MB Rounding

In oder to create a machine via SDC you need the **exact** size (e.g. 40000 mb is not accurate enough) so 40Gb is actually 40960 MB so you need to 40960, no less, no more.... (note google is not strict enough)

use this converter to help

http://www.convertunits.com/from/GB/to/MB

#### AWESOME TIPS

https://wiki.smartos.org/display/DOC/SmartOS+Command+Line+Tips

## Thanks

Thanks to everyone whos posts i have used (to many to mention!) but I have back linked where i had them as a reference.
