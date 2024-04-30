#!/bin/bash
# 示例1：定义颜色别名
#!/bin/bash

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # 恢复默认颜色

# 输出带颜色的文本
#echo -e "${RED}红色文字${NC}"
#echo -e "${GREEN}绿色文字${NC}"
#echo -e "${YELLOW}黄色文字${NC}"
#准备工作
echo -e "${GREEN}第一步：创建挂载文件夹${NC}}"
mkdir /mnt/newdisk
echo -e "${BLUE}    文件夹 ${PINK} /mnt/newdisk ${BLUE}创建成功${NC}"

# 格式化磁盘
echo -e "${GREEN}第二步：格式化磁盘 ${PINK} /dev/vdb ${NC}"
if sudo mkfs.ext4 /dev/vdb; then
    echo -e "${BLUE}    磁盘格式化成功${NC}"
else
    echo -e "${RED}    磁盘格式化失败${NC}"
    exit 1
fi

# 挂载分区
echo -e "${GREEN}第三步：挂载分区 ${PINK}/dev/vdb ${GREEN}在 ${PINK}/mnt/newdisk ${GREEN}下：${NC}"
if sudo mount /dev/vdb /mnt/newdisk; then
    echo -e "${BLUE}    分区挂载成功${NC}"
else
    echo -e "${RED}    分区挂载失败${NC}"
    exit 1
fi

# 开机自动挂载分区
echo -e "${GREEN}第四步：开机自动挂载分区${NC}"
# 第一步：获取磁盘的uuid
disk_uuid=$(sudo blkid -s UUID -o value /dev/vdb)
if [ -z "$disk_uuid" ]; then
    echo -e "${RED}    获取磁盘UUID失败${NC}"
    exit 1
else
    echo -e "${GREEN}    磁盘UUID获取成功：${PINK} $disk_uuid ${NC}"
fi

# 第二步：编辑文件
echo -e "${GREEN}第五步：写入启动文件...${NC}"
if sudo sh -c 'echo "UUID='"$disk_uuid"' /mnt/newdisk ext4 defaults 0 2" >> /etc/fstab'; then
    echo -e "${BLUE}    成功将UUID写入 ${PINK} /etc/fstab ${NC}"
else
    echo -e "${RED}    写入 /etc/fstab 失败${NC}"
    exit 1
fi

# 第四步：重新挂载所有分区，以验证/etc/fstab配置是否正确。
echo -e "${GREEN}最终步：重新挂载所有分区，验证是否正确...${NC}"
if sudo mount -a; then
    echo -e "${BLUE}    重新挂载分区成功!${NC}"
else
    echo -e "${RED}    重新挂载分区失败${NC}"
    exit 1
fi
