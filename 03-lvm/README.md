03-lvm
===

# Уменьшить том под / до 8G
Так как вся система в `/`, необходимо корень перенести в другой LV и только после этого уменьшать размер.

1. Создаем временные VG и LV;
2. Монтируем во временную папку `/mnt` с фаловой системой XFS (для быстроты переноса большого количества файлов через `xfsdump`);
3. Переносим все файлы во временную папку `/mnt`;
4. При помощи команды `chroot` переносим корень системы в `/mnt` и перезагружаемся;
5. Теперь, когда система на другой LV, можем уменьшить размер первоначального LV, можно через удаление/создание LV;
6. Переносим корень системы обратно.

```bash
[vagrant@lvm ~]$ df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00  8.0G  829M  7.2G  11% /
devtmpfs                         110M     0  110M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   61M  954M   6% /boot
```

# Выделить том под /var в зеркало
Опцией `-mX` в команде `lvcreate` создаются зеркала. `X` определяет количество зеркал. 

```bash
[root@lvm vagrant]# lsblk
...
sdc                          8:32   0    2G  0 disk 
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:4    0  952M  0 lvm  
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  952M  0 lvm  
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var

[root@lvm vagrant]# lvdisplay /dev/vg_var/lv_var
  --- Logical volume ---
  LV Path                /dev/vg_var/lv_var
  LV Name                lv_var
  VG Name                vg_var
  LV UUID                ok3XsF-a5qf-VKRg-9Ln1-iyW8-Ddop-Xd0XZ9
  LV Write Access        read/write
  LV Creation host, time lvm, 2020-02-17 21:37:34 +0000
  LV Status              available
  # open                 1
  LV Size                952.00 MiB
  Current LE             238
  Mirrored volumes       2
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:7

```

# Выделить том под /home
Основная сложность в том, что `/home` не пустой - там уже есть хомяк пользователя `vagrant`.
1. Создаем новывй LV;
2. Монтируем в любое место;
3. Переносим все файлы из `/home`;
4. Очищаем папку `/home`;
5. Монтириуем LV в `/home`.

```bash
[root@lvm vagrant]# df -h
Filesystem                          Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00     8.0G  829M  7.2G  11% /
devtmpfs                            110M     0  110M   0% /dev
tmpfs                               118M     0  118M   0% /dev/shm
tmpfs                               118M  4.5M  114M   4% /run
tmpfs                               118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                          1014M   61M  954M   6% /boot
/dev/mapper/vg_var-lv_var           922M  137M  722M  16% /var
/dev/mapper/VolGroup00-LogVol_Home  2.0G   33M  2.0G   2% /home

```

# /home - сделать том для снапшотов
Опцией `-s` можно создать снепшот. Командой `lvconvert` восстановиться из снепшота.
```
[root@lvm vagrant]# lsblk
NAME                            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                               8:0    0   40G  0 disk 
├─sda1                            8:1    0    1M  0 part 
├─sda2                            8:2    0    1G  0 part /boot
└─sda3                            8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00         253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01         253:1    0  1.5G  0 lvm  [SWAP]
  ├─VolGroup00-LogVol_Home-real 253:8    0    2G  0 lvm  
  │ ├─VolGroup00-LogVol_Home    253:2    0    2G  0 lvm  /home
  │ └─VolGroup00-home_snap      253:10   0    2G  0 lvm  
  └─VolGroup00-home_snap-cow    253:9    0  128M  0 lvm  
    └─VolGroup00-home_snap      253:10   0    2G  0 lvm  
...
```

После восстановления snapshot исчезает (смерджился):
```bash
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home

```

# P.S.
`fstab` - текстовый файл, в котором описывается, что куда вмонтировано. Иначе при перезапуске система не сможет автоматически монтировать разделы.
