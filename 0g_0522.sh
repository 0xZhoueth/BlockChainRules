#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 创建 /pt 目录（如果不存在）
if [ ! -d "/pt" ]; then
    sudo mkdir /pt
    sudo chown $USER:$USER /pt
fi

# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x -o /pt/nodesource_setup.sh
        sudo -E bash /pt/nodesource_setup.sh
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

# 检查 Go 环境
function check_go_installation() {
    if command -v go > /dev/null 2>&1; then
        echo "Go 环境已安装"
        return 0 
    else
        echo "Go 环境未安装，正在安装..."
        return 1 
    fi
}

# 节点安装功能
function install_node() {
    cd /pt

    install_nodejs_and_npm
    install_pm2

    # 检查curl是否安装，如果没有则安装
    if ! command -v curl > /dev/null; then
        sudo apt update && sudo apt install curl git -y
    fi

    # 更新和安装必要的软件
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip liblz4-tool -y

    # 安装 Go
    if ! check_go_installation; then
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
        go version
    fi

    # 安装所有二进制文件
    git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git /pt/0g-chain
    cd /pt/0g-chain
    make install

    # 配置0gchaind
    export MONIKER="My_Node"
    export WALLET_NAME="wallet"

    # 获取初始文件和地址簿
    0gchaind init $MONIKER --chain-id zgtendermint_16600-1 --home /pt/.0gchain
    0gchaind config chain-id zgtendermint_16600-1 --home /pt/.0gchain
    0gchaind config node tcp://localhost:13457 --home /pt/.0gchain

    # 配置节点
    wget -O /pt/.0gchain/config/genesis.json https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json
    0gchaind validate-genesis --home /pt/.0gchain
    wget https://smeby.fun/0gchaind-addrbook.json -O /pt/.0gchain/config/addrbook.json

    # 配置节点
    SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656"
    PEERS="a8d7c5a051c4649ba7e267c94e48a7c64a00f0eb@65.108.127.146:26656,8f463ad676c2ea97f88a1274cdcb9f155522fd49@209.126.8.121:26657,75a398f9e3a7d24c6b3ba4ab71bf30cd59faee5c@95.216.42.217:26656,5a202fb905f20f96d8ff0726f0c0756d17cf23d8@43.248.98.100:26656,9d88e34a436ec1b50155175bc6eba89e7a1f0e9a@213.199.61.18:26656,2b8ee12f4f94ebc337af94dbec07de6f029a24e6@94.16.31.161:26656,52e30a030ff6ded32e7a499de6246c574f57cc27@152.53.32.51:26656"
    sed -i "s/persistent_peers = \"\"/persistent_peers = \"$PEERS\"/" /pt/.0gchain/config/config.toml
    sed -i "s/seeds = \"\"/seeds = \"$SEEDS\"/" /pt/.0gchain/config/config.toml

    # 配置端口
    node_address="tcp://localhost:13457"
    sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:13458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:13457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:13460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:13456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":13466\"%" /pt/.0gchain/config/config.toml
    sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:13417\"%; s%^address = \":8080\"%address = \":13480\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:13490\"%; s%^address = \"localhost:9091\"%address = \"0.0.0.0:13491\"%; s%:8545%:13445%; s%:8546%:13446%; s%:6065%:13465%" /pt/.0gchain/config/app.toml
    echo "export OG_RPC_PORT=$node_address" >> $HOME/.bash_profile
    source $HOME/.bash_profile

    # 使用 PM2 启动节点进程
    pm2 start 0gchaind -- start --home /pt/.0gchain && pm2 save && pm2 startup

    pm2 stop 0gchaind
    0gchaind tendermint unsafe-reset-all --home /pt/.0gchain --keep-addr-book
    curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C /pt/.0gchain
    mv /pt/.0gchain/priv_validator_state.json.backup /pt/.0gchain/data/priv_validator_state.json
    pm2 restart 0gchaind

    echo '====================== 安装完成,请退出脚本后执行 source $HOME/.bash_profile 以加载环境变量==========================='
}

# 查看0gai 服务状态
function check_service_status() {
    pm2 list
}

# 0gai 节点日志查询
function view_logs() {
    pm2 logs 0gchaind
}

# 主菜单
function main_menu() {
    while true; do
        echo "======== 0gai 管理脚本 ========"
        echo "1. 安装 0gai"
        echo "2. 查看 0gai 服务状态"
        echo "3. 查看 0gai 节点日志"
        echo "0. 退出"
        echo "=============================="
        read -p "请输入操作选项: " choice

        case $choice in
            1) install_node ;;
            2) check_service_status ;;
            3) view_logs ;;
            0) exit 0 ;;
            *) echo "无效的选项，请重新输入" ;;
        esac
    done
}

# 启动主菜单
main_menu
