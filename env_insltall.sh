#!/bin/bash

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

# 输出带颜色的文本
# echo -e "${RED}红色文字${NC}"
# echo -e "${GREEN}绿色文字${NC}"
# echo -e "${YELLOW}黄色文字${NC}"



echo -e "${RED}------------即将开始安装本机环境----------${NC}"
echo -e "${GREEN}【1】第一步：安装Go...${NC}"
#安装go
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile
go version
echo -e "${GREEN}【1】Go环境安装成功... ${NC}"
#安装npm
sudo apt-get install -y npm
echo -e "${GREEN}【2】npm 安装成功... ${NC}"
#安装nodejs
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
echo -e "${GREEN}【3】nodejs 安装成功... ${NC}"
#安装pm2
npm install pm2@latest -g
#安装其他组件
sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev lz4 snapd
echo -e "${GREEN}【4】组件 安装成功... ${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}【5】所有依赖更新成功... ${NC}"
