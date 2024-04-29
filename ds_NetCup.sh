#!/bin/bash

# 格式化磁盘
if sudo mkfs.ext4 /dev/vdb; then
    echo "磁盘格式化成功"
else
    echo "磁盘格式化失败"
    exit 1
fi

# 挂载分区
if sudo mount /dev/vdb /mnt/newdisk; then
    echo "分区挂载成功"
else
    echo "分区挂载失败"
    exit 1
fi

# 开机自动挂载分区
# 第一步：获取磁盘的uuid
disk_uuid=$(sudo blkid -s UUID -o value /dev/vdb)
if [ -z "$disk_uuid" ]; then
    echo "获取磁盘UUID失败"
    exit 1
else
    echo "磁盘UUID获取成功：$disk_uuid"
fi

# 第二步：编辑文件
if sudo sh -c 'echo "UUID='"$disk_uuid"' /mnt/newdisk ext4 defaults 0 2" >> /etc/fstab'; then
    echo "成功将UUID写入 /etc/fstab"
else
    echo "写入 /etc/fstab 失败"
    exit 1
fi

# 第四步：重新挂载所有分区，以验证/etc/fstab配置是否正确。
if sudo mount -a; then
    echo "重新挂载分区成功"
else
    echo "重新挂载分区失败"
    exit 1
fi
