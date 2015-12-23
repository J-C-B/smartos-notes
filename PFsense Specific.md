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
