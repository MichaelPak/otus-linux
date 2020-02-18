02-disk
===

# Создание рейда

К виртуальной машине подключено дополнительно 6 дисков. Создание рейда производится через `provisioner` в `Vagrantfile`:

```ruby
# Create raid
box.vm.provision "shell", inline: <<-SHELL
    mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
    mkdir /etc/mdadm
    echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
    mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
    mdadm -D /dev/md0
SHELL
```
Рейд создается на 5 дисках, при поломке один диск заменим на неиспользованный в рейде.

# Поломка и восстановление рейда
 
### 1. Вывод дисков
```bash
[vagrant@otuslinux ~]$ sudo lshw -short | grep disk
/0/100/1.1/0.0.0    /dev/sda   disk        42GB VBOX HARDDISK
/0/100/d/0          /dev/sdb   disk        262MB VBOX HARDDISK
/0/100/d/1          /dev/sdc   disk        262MB VBOX HARDDISK
/0/100/d/2          /dev/sdd   disk        262MB VBOX HARDDISK
/0/100/d/3          /dev/sde   disk        262MB VBOX HARDDISK
/0/100/d/4          /dev/sdf   disk        262MB VBOX HARDDISK
/0/100/d/5          /dev/sdg   disk        262MB VBOX HARDDISK 
```

### 2. Вывод рейда
```bash
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Feb 17 13:23:53 2020
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Mon Feb 17 13:23:58 2020
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : e6f4178f:f05a9b32:b9c636e9:5df54edf
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```

### 3. Поломка диска
```bash
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid6 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]

unused devices: <none>
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0 | grep sde
       3       8       64        -      faulty   /dev/sde
```

### 4. Удаление старого диска и добавление нового
```bash
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sdg
mdadm: added /dev/sdg
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid6 sdg[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
      [=======>.............]  recovery = 38.8% (98816/253952) finish=0.0min speed=98816K/sec

unused devices: <none>
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid6 sdg[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
      [===============>.....]  recovery = 76.0% (193536/253952) finish=0.0min speed=96768K/sec

unused devices: <none>
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]
md0 : active raid6 sdg[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>
```

### 5. Статус рейда после восстановления
```bash
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Feb 17 13:23:53 2020
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Mon Feb 17 13:34:44 2020
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : e6f4178f:f05a9b32:b9c636e9:5df54edf
            Events : 39

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       5       8       96        3      active sync   /dev/sdg
       4       8       80        4      active sync   /dev/sdf
```

# Созданиие GPT раздела
```bash
[vagrant@otuslinux ~]$ sudo parted -s /dev/md0 mklabel gpt
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux ~]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38456 inodes, 153600 blocks
7680 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2024 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks:
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

[vagrant@otuslinux ~]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux ~]$ for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
[vagrant@otuslinux ~]$ sudo gdisk -l /dev/md0
GPT fdisk (gdisk) version 0.8.10

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.
Disk /dev/md0: 1523712 sectors, 744.0 MiB
Logical sector size: 512 bytes
Disk identifier (GUID): C39554CB-8546-42BE-8A19-88B1757331C0
Partition table holds up to 128 entries
First usable sector is 34, last usable sector is 1523678
Partitions will be aligned on 1024-sector boundaries
Total free space is 6077 sectors (3.0 MiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            3072          304127   147.0 MiB   0700  primary
   2          304128          608255   148.5 MiB   0700  primary
   3          608256          915455   150.0 MiB   0700  primary
   4          915456         1219583   148.5 MiB   0700  primary
   5         1219584         1520639   147.0 MiB   0700  primary
```

# Автоматическое создание GPT партиций
Создание и монтирование партиций происходит через `provisioner`:
```ruby
# Create partitions on raid and mount them
box.vm.provision "shell", inline: <<-SHELL
    parted -s /dev/md0 mklabel gpt
    parted /dev/md0 mkpart primary ext4 0% 20%
    parted /dev/md0 mkpart primary ext4 20% 40%
    parted /dev/md0 mkpart primary ext4 40% 60%
    parted /dev/md0 mkpart primary ext4 60% 80%
    parted /dev/md0 mkpart primary ext4 80% 100%
    
    mkdir /raid
    for i in $(seq 1 5); do
        mkfs.ext4 /dev/md0p$i
        mkdir /raid/part$i
        mount /dev/md0p$i /raid/part$i
    done
SHELL
```

```bash
[vagrant@otuslinux ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        40G  2.9G   38G   8% /
devtmpfs        488M     0  488M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6.7M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
/dev/md0p1      139M  1.6M  127M   2% /raid/part1
/dev/md0p2      140M  1.6M  128M   2% /raid/part2
/dev/md0p3      142M  1.6M  130M   2% /raid/part3
/dev/md0p4      140M  1.6M  128M   2% /raid/part4
/dev/md0p5      139M  1.6M  127M   2% /raid/part5
tmpfs           100M     0  100M   0% /run/user/1000
```
