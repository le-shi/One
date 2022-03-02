# LVM

**概念**
- 逻辑卷管理器(LVM)提供了从物理设备创建虚拟块设备的工具。虚拟设备可能比物理设备更容易管理，并且可以拥有物理设备本身所提供的功能。
- 物理卷PV（physical volume）：物理卷就是LVM的基本存储逻辑块，但和基本的物理存储介质比较却包含与LVM相关的管理参数，创建物理卷可以用磁盘分区，也可以用磁盘本身。
- 卷组VG（Volume Group）：LVM卷组类似于非LVM系统中的物理磁盘，一个卷组VG由一个或多个物理卷PV组成。可以在卷组VG上建立逻辑卷LV。
- 逻辑卷LV（logical volume）：类似于非LVM系统中的磁盘分区，逻辑卷LV建立在卷组VG之上。在逻辑卷LV之上建立文件系统。
- 根据内核中的Device Mapper (DM)实现的算法，LV中的每个数据块都存储在VG中的一个或多个PV上。

**利**
- 基于lvm的分区可以进行在线热扩容，可以在不停止业务的情况下进行文件系统容量的提升，减去了数据迁移的成本

**弊**
- 一台机器上，所有被 lvm 管理的磁盘，在开机时需要正确挂载，否则会影响到文件系统的使用

**安装软件**

    yum install lvm2

1. 新的开始

> 这里演示的是通过划分磁盘分区的方式，和通过磁盘的方式区别只在于多了磁盘的分区这一步
```bash
[root@yoyo ~]# # 查看机器的磁盘分区表
[root@yoyo ~]# fdisk -l

Disk /dev/vda: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0d11

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048    41943006    20970479+  83  Linux

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@yoyo ~]# # 可以看到盘符号是 /dev/vdb 的是新挂载的磁盘，容量大小是20G，我们用它来做lvm分区的实验
[root@yoyo ~]# # 先对磁盘进行分区
[root@yoyo ~]# fdisk /dev/vdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0xd7d3ecae.

# 查看帮助信息，了解每个命令的含义
Command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

# 创建新的分区
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
## 这里的p是属于n的子命令，作用是创建主分区
Select (default p): p
## 设置分区ID，默认是1
Partition number (1-4, default 1): 1
## 设置分区的起始扇区，默认是2048
First sector (2048-41943039, default 2048): 
Using default value 2048
## 设置分区的结尾扇区，默认是当前磁盘的结尾扇区(所有容量都给这个分区)
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): 
Using default value 41943039
Partition 1 of type Linux and of size 20 GiB is set

# 这里分区就创建好了，通过p命令(此p非彼p，这是跟n同级的命令)进行查看，当前操作数据都存储在内存中
Command (m for help): p

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xd10ee99c

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1            2048    41943039    20970496   83  Linux

## 可以看到分区类型是Linux，不是 Linux LVM ，接下来修改分区类型
Command (m for help): t
Selected partition 1
## 查看所有可选的代号
Hex code (type L to list all codes): L

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
## 8e代表的是 Linux LVM 所以选择这个
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'
## 再次查看分区类型已经变更为了 Linux LVM
Command (m for help): p

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xd10ee99c

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1            2048    41943039    20970496   8e  Linux LVM

## 使用w保存一下我们刚刚做的操作
Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

[root@yoyo ~]# # 再次查看机器的磁盘分区表，发现已经有了刚刚创建好的分区 /dev/vdb1 类型为 Linux LVM
[root@yoyo ~]# fdisk -l

Disk /dev/vda: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0d11

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048    41943006    20970479+  83  Linux

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xd10ee99c

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1            2048    41943039    20970496   8e  Linux LVM

# 到这里磁盘的分区操作就做好了，接下来开始使用lvm命令制作逻辑卷(LV)

[root@yoyo ~]# # 初始化之前，通知操作系统 /dev/vdb 的分区表发生变化, 它通过请求操作系统重新读取分区表来通知操作系统内核分区表的变化
[root@yoyo ~]# partprobe /dev/vdb
[root@yoyo ~]# # 1 - 创建(初始化)供LVM使用的磁盘或分区
[root@yoyo ~]# pvcreate /dev/vdb1
  Physical volume "/dev/vdb1" successfully created.
[root@yoyo ~]# # 可以看到 /dev/vdb1 分区已经添加到了lvm中
[root@yoyo ~]# pvs
  PV         VG Fmt  Attr PSize   PFree  
  /dev/vdb1     lvm2 ---  <20.00g <20.00g
[root@yoyo ~]# # 2 - 创建卷组, 这里我给卷组定义的名字的 vgyoyo
[root@yoyo ~]# vgcreate vgyoyo /dev/vdb1
  Volume group "vgyoyo" successfully created
[root@yoyo ~]# # 查看刚才创建的卷组
[root@yoyo ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree  
  vgyoyo   1   0   0 wz--n- <20.00g <20.00g
[root@yoyo ~]# # 可以看到 /dev/vdb1 分区的 VG 字段已经被 vgyoyo 填充上，是我刚才创建的卷组
[root@yoyo ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree  
  /dev/vdb1  vgyoyo lvm2 a--  <20.00g <20.00g
[root@yoyo ~]# # 3 - 在已有的卷组中创建逻辑卷, 这里我使用 -l 参数指定逻辑卷大小为可用容量(FREE)的100%, 使用 -n 参数定义逻辑卷的名字是 lvdata , 使用的卷组是 vgyoyo
[root@yoyo ~]# lvcreate -l +100%FREE -n lvdata vgyoyo
  Logical volume "lvdata" created.
[root@yoyo ~]# # 查看刚才创建的逻辑卷, 所属卷组是 vgyoyo , 容量大小是 20G , 跟上面vg、pv查询出的容量一致
[root@yoyo ~]# lvs
  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvdata vgyoyo -wi-a----- <20.00g                                                    
[root@yoyo ~]# # 查看卷组 vgyoyo 的VFree已经是0
[root@yoyo ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  vgyoyo   1   1   0 wz--n- <20.00g    0 
[root@yoyo ~]# # 查看分区 /dev/vdb1 的VFree已经是0
[root@yoyo ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/vdb1  vgyoyo lvm2 a--  <20.00g    0 
[root@yoyo ~]# # 再次查看分区表信息，出现了刚才创建好的逻辑卷，这里显示的分区名字是 /dev/mapper/vgyoyo-lvdata , 大小是 20G
[root@yoyo ~]# fdisk -l

Disk /dev/vda: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0d11

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048    41943006    20970479+  83  Linux

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xd10ee99c

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1            2048    41943039    20970496   8e  Linux LVM

Disk /dev/mapper/vgyoyo-lvdata: 21.5 GB, 21470642176 bytes, 41934848 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

# 到这里逻辑卷(LV)就制作好了，现在逻辑卷和普通的分区没有什么区别,下面开始在逻辑卷创建文件系统

[root@yoyo ~]# # 我们需要一个格式为 ext4 的文件系统，使用 mkfs.ext4 命令进行创建
[root@yoyo ~]# mkfs.ext4 /dev/mapper/vgyoyo-lvdata
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1310720 inodes, 5241856 blocks
262092 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2153775104
160 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   

[root@yoyo ~]# # 使用 lsblk -f 命令, 查看块设备的文件系统信息, 可以看到我们的逻辑卷 vgyoyo-lvdata 文件系统类型是 ext4
[root@yoyo ~]# lsblk -f
NAME              FSTYPE      LABEL UUID                                   MOUNTPOINT
vda                                                                        
└─vda1            xfs               9cff3d69-3769-4ad9-8460-9c54050583f9   /
vdb                                                                        
└─vdb1            LVM2_member       LjiCsU-MO4i-Ef0g-7DH8-2Xjn-pwft-vdXoqd 
  └─vgyoyo-lvdata ext4              494fbed0-f7f2-4792-9eb5-4657c885f5d7  

[root@yoyo ~]# # 挂载文件系统，挂载点为 /mnt
[root@yoyo ~]# mount /dev/mapper/vgyoyo-lvdata /mnt
[root@yoyo ~]# # 使用 df 命令查看文件系统磁盘空间使用情况，可以看到刚才挂载点为 /mnt 的文件系统，文件系统类型是 ext4
[root@yoyo ~]# df -hT
Filesystem                Type      Size  Used Avail Use% Mounted on
devtmpfs                  devtmpfs  895M     0  895M   0% /dev
tmpfs                     tmpfs     919M     0  919M   0% /dev/shm
tmpfs                     tmpfs     919M   17M  903M   2% /run
tmpfs                     tmpfs     919M     0  919M   0% /sys/fs/cgroup
/dev/vda1                 xfs        20G  1.9G   19G  10% /
tmpfs                     tmpfs     184M     0  184M   0% /run/user/1000
/dev/mapper/vgyoyo-lvdata ext4       20G   45M   19G   1% /mnt
[root@yoyo ~]# # 检查文件系统的可用性 - 查看 /mnt 目录, lost+found 是ext4系统默认创建的文件夹
[root@yoyo ~]# ls /mnt
lost+found
[root@yoyo ~]# # 检查文件系统的可用性 - 写入(创建)一个文件
[root@yoyo ~]# date +%F > /mnt/a
[root@yoyo ~]# # 检查文件系统的可用性 - 读取一个文件
[root@yoyo ~]# cat /mnt/a
2021-08-27
[root@yoyo ~]# # 检查文件系统的可用性 - 查看刚才创建的文件
[root@yoyo ~]# ls /mnt/
a  lost+found

# 到这里逻辑卷(LV)已经可用正常使用了，用着跟普通的Linux分区没什么区别，接下来就是让文件系统开机自动挂载

[root@yoyo ~]# # 添加 fstab 记录，让文件系统可以开机自动挂载
[root@yoyo ~]# grep /dev/mapper/vgyoyo-lvdata /etc/fstab 
/dev/mapper/vgyoyo-lvdata /mnt ext4 defaults 0 0
[root@yoyo ~]# 验证正确性 - 先卸载刚刚的挂载点
[root@yoyo ~]# umount /mnt
[root@yoyo ~]# 验证正确性 - 使用 mount -a 命令挂载所有的文件系统
[root@yoyo ~]# mount -a
[root@yoyo ~]# 验证正确性 - 再次查看逻辑卷已经被挂载到了 /mnt
[root@yoyo ~]# df -h
Filesystem                 Size  Used Avail Use% Mounted on
devtmpfs                   895M     0  895M   0% /dev
tmpfs                      919M     0  919M   0% /dev/shm
tmpfs                      919M   17M  903M   2% /run
tmpfs                      919M     0  919M   0% /sys/fs/cgroup
/dev/vda1                   20G  1.9G   19G  10% /
tmpfs                      184M     0  184M   0% /run/user/1000
/dev/mapper/vgyoyo-lvdata   20G   45M   19G   1% /mnt


注意：
* /etc/fstab 文件一定要正确填写路径,一旦出错,可能导致服务器无法正常启动.
* 有些服务器挂载一个新的磁盘后无法通过 fdisk -l 命令查询，原因是 fdisk -l 命令是对设备分区表进行了扫描，但是新挂载的磁盘没有注册到系统上，需要通知操作系统重新读取分区表 partprobe
* 还有一种情况是在使用中的磁盘上进行扩容操作(这是外部管理工具操作的，比如Vmware控制台、[私有云|公有云]的云服务器控制台)，但机器上还会显示扩容之前的大小，这时执行 partprobe 命令扫描会报错，提示文件系统是只读的，这时候只能重启服务器才可以重新读取到磁盘信息
* 还有第二种情况是在使用中的磁盘上进行扩容操作(这是外部管理工具操作的，比如Vmware控制台、[私有云|公有云]的云服务器控制台)，可以通过 fdisk -l 查询到磁盘大小是扩容后的，也可以通过 fdisk -l 进行分区但是lvm添加分区时确找不到这个分区，这时执行 partprobe 命令扫描会报错，提示文件系统是只读的，这时候也是只能重启服务器才可以重新刷新磁盘信息
```

> 小结

```bash
# 安装lvm软件
yum install lvm2

# === 使用分区方式 ===
# 查看磁盘分区表
fdisk -l
# 对磁盘进行分区操作
fdisk /dev/vdb
# 重新读取分区表
partprobe /dev/vdb
# 1 - 创建(初始化)供LVM使用的分区
pvcreate /dev/vdb1
# 2 - 创建卷组, 这里我给卷组定义的名字的 vgyoyo
vgcreate vgyoyo /dev/vdb1
# 3 - 在已有的卷组中创建逻辑卷, 这里我使用 -l 参数指定逻辑卷大小为可用容量(FREE)的100%, 使用 -n 参数定义逻辑卷的名字是 lvdata , 使用的卷组是 vgyoyo
lvcreate -l +100%FREE -n lvdata vgyoyo
# 使用 mkfs.ext4 命令在逻辑卷 /dev/mapper/vgyoyo-lvdata 上创建格式为 ext4 的文件系统
mkfs.ext4 /dev/mapper/vgyoyo-lvdata
# 挂载文件系统，挂载点为 /mnt
mount /dev/mapper/vgyoyo-lvdata /mnt
# 添加 fstab 记录，让文件系统可以开机自动挂载
grep /dev/mapper/vgyoyo-lvdata /etc/fstab
/dev/mapper/vgyoyo-lvdata /mnt ext4 defaults 0 0

# === 使用磁盘本身方式 ===
# 1 - 创建(初始化)供LVM使用的磁盘
pvcreate /dev/vdb
# 2 - 创建卷组, 这里我给卷组定义的名字的 vgyoyo
vgcreate vgyoyo /dev/vdb
# 3 - 在已有的卷组中创建逻辑卷, 这里我使用 -l 参数指定逻辑卷大小为可用容量(FREE)的100%, 使用 -n 参数定义逻辑卷的名字是 lvdata , 使用的卷组是 vgyoyo
lvcreate -l +100%FREE -n lvdata vgyoyo
# 使用 mkfs.ext4 命令在逻辑卷 /dev/mapper/vgyoyo-lvdata 上创建格式为 ext4 的文件系统
mkfs.ext4 /dev/mapper/vgyoyo-lvdata
# 挂载文件系统，挂载点为 /mnt
mount /dev/mapper/vgyoyo-lvdata /mnt
# 添加 fstab 记录，让文件系统可以开机自动挂载
grep /dev/mapper/vgyoyo-lvdata /etc/fstab
/dev/mapper/vgyoyo-lvdata /mnt ext4 defaults 0 0
```


2. 扩容

```bash

# 如果卷组(VG)或逻辑卷(LV)的空间即将用完, 我们可以添加新的磁盘, 然后对正在使用的文件系统进行热扩容操作

[root@yoyo ~]# # 现在开始模拟热扩容, 这里我们使用磁盘本身的方式进行操作, 首先查看一下新挂载的磁盘信息是否加载到了分区表中
[root@yoyo ~]# fdisk -l

Disk /dev/vda: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0d11

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048    41943006    20970479+  83  Linux

Disk /dev/vdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xd10ee99c

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1            2048    41943039    20970496   8e  Linux LVM

Disk /dev/mapper/vgyoyo-lvdata: 21.5 GB, 21470642176 bytes, 41934848 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdc: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

# 这里可以看到 /dev/vdc 是新挂载的磁盘，我们接下来使用这块磁盘进行扩容操作

[root@yoyo ~]# # 查看当前 pv 管理的磁盘和分区
[root@yoyo ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/vdb1  vgyoyo lvm2 a--  <20.00g    0 
[root@yoyo ~]# # 将我们新挂载的磁盘 /dev/vdc ，交给pv进行管理
[root@yoyo ~]# pvcreate /dev/vdc
  Physical volume "/dev/vdc" successfully created.
[root@yoyo ~]# # 添加磁盘后，再次查看当前 pv 管理的磁盘和分区
[root@yoyo ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree 
  /dev/vdb1  vgyoyo lvm2 a--  <20.00g     0 
  /dev/vdc          lvm2 ---   10.00g 10.00g
[root@yoyo ~]# # 查看当前所有 vg 的容量情况
[root@yoyo ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  vgyoyo   1   1   0 wz--n- <20.00g    0 
[root@yoyo ~]# # 使用新的磁盘，对卷组 vgyoyo 进行扩容
[root@yoyo ~]# vgextend vgyoyo /dev/vdc
  Volume group "vgyoyo" successfully extended
[root@yoyo ~]# # 卷组扩容后，再次查看卷组 vgyoyo 的容量情况
[root@yoyo ~]# vgs
  VG     #PV #LV #SN Attr   VSize  VFree  
  vgyoyo   2   1   0 wz--n- 29.99g <10.00g
[root@yoyo ~]# # 查看当前所有 lv 的使用情况
[root@yoyo ~]# lvs
  LV     VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvdata vgyoyo -wi-ao---- <20.00g                                                    
[root@yoyo ~]# # 给逻辑卷 lvdata 进行扩容，我们将 100% 的 Free 容量都给逻辑卷 lvdata
[root@yoyo ~]# lvextend -l +100%FREE /dev/mapper/vgyoyo-lvdata 
  Size of logical volume vgyoyo/lvdata changed from <20.00 GiB (5119 extents) to 29.99 GiB (7678 extents).
  Logical volume vgyoyo/lvdata successfully resized.
[root@yoyo ~]# # 逻辑卷扩容后，再次查看逻辑卷 lvdata 的使用情况
[root@yoyo ~]# lvs
  LV     VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvdata vgyoyo -wi-ao---- 29.99g

# 到这里新的磁盘已经被lvm管理，并且卷组和逻辑卷已经得到了扩容，扩容大小的 100% 的 Free 容量，接下来我们调整文件系统的大小

[root@yoyo ~]# # 查看当前文件系统的容量信息
[root@yoyo ~]# df -hT
Filesystem                Type      Size  Used Avail Use% Mounted on
devtmpfs                  devtmpfs  895M     0  895M   0% /dev
tmpfs                     tmpfs     919M     0  919M   0% /dev/shm
tmpfs                     tmpfs     919M   17M  903M   2% /run
tmpfs                     tmpfs     919M     0  919M   0% /sys/fs/cgroup
/dev/vda1                 xfs        20G  2.0G   18G  10% /
tmpfs                     tmpfs     184M     0  184M   0% /run/user/1000
/dev/mapper/vgyoyo-lvdata ext4       20G   45M   19G   1% /mnt
[root@yoyo ~]# # 对文件系统 /dev/mapper/vgyoyo-lvdata 进行大小调整
[root@yoyo ~]# resize2fs /dev/mapper/vgyoyo-lvdata
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/mapper/vgyoyo-lvdata is mounted on /mnt; on-line resizing required
old_desc_blocks = 3, new_desc_blocks = 4
The filesystem on /dev/mapper/vgyoyo-lvdata is now 7862272 blocks long.

[root@yoyo ~]# # 调整大小后，再次查看文件系统的容量信息
[root@yoyo ~]# df -hT
Filesystem                Type      Size  Used Avail Use% Mounted on
devtmpfs                  devtmpfs  895M     0  895M   0% /dev
tmpfs                     tmpfs     919M     0  919M   0% /dev/shm
tmpfs                     tmpfs     919M   17M  903M   2% /run
tmpfs                     tmpfs     919M     0  919M   0% /sys/fs/cgroup
/dev/vda1                 xfs        20G  2.0G   18G  10% /
tmpfs                     tmpfs     184M     0  184M   0% /run/user/1000
/dev/mapper/vgyoyo-lvdata ext4       30G   44M   28G   1% /mnt

# 到这里可以看的到，文件系统的大小已经变大了，说明热扩容操作成功


注意:
* 当文件系统的格式为xfs时，如果使用 resize2fs 命令进行扩容操作，就会提示 "找不到有效的文件系统超级块" ，并且不会对磁盘(lv)进行扩容，这时候需要使用 xfs_growfs 命令进行扩容操作: xfs_growfs /dev/mapper/vgyoyo-lvdata
，然后通过 df -hT 就可以看到扩容后的大小了
* 执行lvm相关命令提示 "Couldn't create temporary archive name." 原因：原有的存储空间已经使用100%，无法挂载，须预留部分空间出来。解决办法：删掉其中无用文件、log日志继续操作即可。
```

> 小结

```bash
# === 使用磁盘本身方式 ===
# 首先查看一下新挂载的磁盘信息是否加载到了分区表中
# fdisk -l
# 将我们新挂载的磁盘 /dev/vdc ，交给pv进行管理
pvcreate /dev/vdc
# 使用新的磁盘，对卷组 vgyoyo 进行扩容
vgextend vgyoyo /dev/vdc
# 给逻辑卷 lvdata 进行扩容，我们将 100% 的 Free 容量都给逻辑卷 lvdata
lvextend -l +100%FREE /dev/mapper/vgyoyo-lvdata 
# 对文件系统 /dev/mapper/vgyoyo-lvdata 进行大小调整
resize2fs /dev/mapper/vgyoyo-lvdata
# 调整大小后，再次查看文件系统的容量信息
df -hT

# ext 格式的文件系统扩容命令
resize2fs /dev/mapper/vgyoyo-lvdata
# xfs 格式的文件系统扩容命令
xfs_growfs /dev/mapper/vgyoyo-lvdata
```
