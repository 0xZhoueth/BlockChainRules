#!/bin/bash

# 格式化磁盘
sudo mkfs.ext4 /dev/vdb

# 挂载分区
sudo mount /dev/vdb /mnt/newdisk

# 开机自动挂载分区
# 第一步：获取磁盘的uuid
disk_uuid=$(sudo blkid -s UUID -o value /dev/vdb)

# 第二步：编辑文件
sudo sh -c 'echo "UUID='"$disk_uuid"' /mnt/newdisk ext4 defaults 0 2" >> /etc/fstab'

# 第四步：重新挂载所有分区，以验证/etc/fstab配置是否正确。
sudo mount -a
