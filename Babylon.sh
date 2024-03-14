#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Babylon.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="bbl"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

sudo apt update && sudo apt upgrade -y

# 安装构建工具
sudo apt -qy install curl git jq lz4 build-essential

# 安装 Go
rm -rf $HOME/go
sudo rm -rf /usr/local/go
cd $HOME
curl https://dl.google.com/go/go1.22.0.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
go version


# 克隆项目仓库
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon
cd babylon
git checkout v0.8.4

# 创建安装
make install


# 创建节点名称
read -p "输入节点名称: " MONIKER

# 配置节点
babylond init $MONIKER --chain-id bbn-test-3


# 安装创世文件
wget https://github.com/babylonchain/networks/raw/main/bbn-test-3/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json

# 设置种子节点
sed -i -e 's|^seeds *=.*|seeds = "49b4685f16670e784a0fe78f37cd37d56c7aff0e@3.14.89.82:26656,9cb1974618ddd541c9a4f4562b842b96ffaf1446@3.16.63.237:26656"|' $HOME/.babylond/config/config.toml

# 设置BTC网络
sed -i -e "s|^\(network = \).*|\1\"signet\"|" $HOME/.babylond/config/app.toml

# 设置最小gas
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00001ubbn\"|" $HOME/.babylond/config/app.toml


# 设置peers
#PEERS="8507d5156b82aaf3543d680bd3a279498c11e69f@89.117.20.184:26656,45aa09557d7378092488a60593d03ad7e3c8ffb4@46.250.255.253:20656,0d801b953096f0652eb46598ff700ca76a91d970@45.85.146.205:26656,a3d0e46ba4715079dc796c130994b026d9c7f126@109.199.108.19:26656,47a7101a7a47e0b3c4324ff1ff3006f4b5432b63@89.58.36.186:26656,326fee158e9e24a208e53f6703c076e1465e739d@193.34.212.39:26659,28231715fa2fa058f9885c4dc33ac430472b03b1@89.117.20.206:26656,0d54afe9faee734593c8f34bfd95db5a77802dce@95.111.225.90:26656,12f9061449bd4e3a62d01c5b3435a09c79b7bee2@54.204.198.231:26656,66af16cf6b888ef0c631cc293d26f3cb06a04b4a@194.163.177.76:26656,79e00df888f58754175f461095086d4ac2bc0349@109.199.124.231:26656,49928d23fd8d39d8944d8998cfbc21bd24f33523@31.220.88.222:26656,a747fec310ed2b4193c02d36d2105ac6f582aa0c@109.199.117.89:26656,e782905eeb44e10c9c79a591d3eafb28ac6de4cd@95.111.232.55:26656,bdd4940c17fe152016b1420e7665a40d0fbe6838@95.217.107.53:45656,efb4b5c0274eae783fc3061195eb190c09d932a8@109.123.236.193:26656,74190795eb8a9b87cdd144d58764633d30ab4275@82.219.13.245:26656,a98cc26a454e90fca5c77f432e14b1b397832ca8@158.180.95.206:26656,67090988292901f282913132a3ac0ee8d08c9a82@95.217.237.154:35656,d93b84fb35968ddae81418b2da0362e718aefcb0@194.163.154.2:26656,702228072fc2df5be0ea37733dc72116cb72a870@109.199.124.233:26656,8b0f715a3a8170d68e350243db2387f487c171c8@89.117.20.183:26656,13cefaad47176760b3040ce4a54ea78fd4346350@46.4.105.114:20735,9242051637ea91aff3a23fc2b0278d5048e07ae9@31.220.75.195:26656,dd7a541e505517a065c34b5dfa24ca03158ef4a4@176.9.20.101:26656,5bd45f1ac56314e75719baef76ee6a51e66a5b2d@89.58.37.76:26656,d5e3731e3c460270d93a7590df7dcf1b4277f1f3@45.85.146.159:26656,c6afbd18c78d97a4aa29c2153ab349de4db79316@38.242.141.8:26656,374179060d2b52beef20a16d91964104e1a76709@37.60.249.119:26656,e3a563e593b4e5a25e6f58eee7f4e04b3c7b6b70@46.250.240.35:26656,0907bf7627dcb1740cb8cce32ec241ed43802eec@167.86.74.162:26656,471b759544ac8d579f3cce3f17328e156b6c5caa@213.199.33.105:26656,043ea117e80db71472b1346ed3258cbfcc04529a@167.86.101.2:20656,37290697a7a9a2f5684996003446c099efffdbe3@207.180.212.184:26656,2e53b8bea549c2c3128dc43cfc9e7dce867be42f@178.124.188.210:26656,4ea9ae29c99f7e7d8f5a06d30b193b01c7d4e326@202.182.107.108:26656,e7848e82dc4ed1e84ed984e1b5fafbea0b2dd88e@109.199.125.212:26656,fa3ee91b6ee163eac98b78780754efba8f12ba50@45.41.204.210:26656,68b2ac39f0c2685edb39c82b4608174f3e55a6c9@51.79.230.113:26656,c6b79273820e512d138e4cac84dbd4f2941e8750@23.94.253.58:26656,01b8c4919b6238eb92d9087539c2e7c4dc6abd59@74.118.136.139:26656,726bf809df4d87093ae1405f056a2d9b0c571e65@194.233.83.93:26656,76a4440ec50f1ec1307fc70cc2a13221ce88a483@65.109.118.244:26656,8c0fb792011e92cc19d9313f34e5a439a08dad26@144.126.133.175:26656,0e315f7b5c8a03181ff7eb2518c37d9ed00d3768@37.60.242.28:26656,ba6782372f1d6f378f611d239d70558486442c91@154.26.132.31:26656,0bf64111fbab730ea78ab7d544053aba4c94c3de@46.250.240.33:26656,431d12da3eea8ab53da4ba6dd065acb267b07e0f@46.250.240.26:26656,85c3ff5b89d66111b1af47a491b7688bf9592fde@178.18.250.181:28656,b845d57ec7090860afb04df2fd3b69d6076c21da@65.109.32.125:26656,9041f8c106c94b4703a8fa09bd41e857b104f60b@84.247.163.55:20656,24ed34d52342f4ed05bac86138cbfa15f14eebd1@164.68.125.145:26656,53479566a96fba20ecc7e44f0251c66656777d59@178.18.253.146:26656,c5e5955f569c7e514e9a42c03ce9ea880eef3b06@134.119.205.117:26656,d3b2c3323a1eef519cec232d209710d1f0539daa@88.198.57.55:26656,756ee5c1d184aa9cc2e7f3683b966cbffb5107a5@92.222.200.51:16656,11c841e72bf04b12a0f9018c35ce2fdd6b51ebac@161.97.149.174:26656,fb05a42074eb397312708682a95ddef792c4b63b@185.217.127.47:26656,9af3a75b4de23829fb1a72c740ed1b0ad8cec20e@158.220.85.37:26656,21d9dd05fa924cbcdaf501b92b74bf106af29c95@89.58.32.218:25000,0e40b0c37dcdcc07dfad8891065656b48a9edc58@173.249.34.49:20656,4b5ed6e8caed5bbaa7669d113f92efbb6641f83c@84.247.139.5:26656,20b478baab7c0f3d2f51a748a9817019623f0b91@213.199.39.153:26656,444067c6a233ce94cc168af089d3058c9283c5d9@109.199.117.45:26656,46cad0e37277872e6898e3e31d7d93c2684d52ed@37.60.248.135:26656,32d075953958ce60714eabc06d7693b5632aa25c@84.247.139.14:26656,1f1c85c1cde41e5d878468fa03bd4cbf1fc19cc6@89.117.20.205:26656,ef1b1044a4c7cc9732932e16bcf742b57dc6f6c8@194.163.131.83:26656,fd0a6c4c0e74eef8c76cfca48a8dc7d30f1b6f27@154.26.134.177:26656,f840a2065d031569550fa71d8a2b79cdebdd359a@158.220.85.35:26656,52820c8ea646454529c43d6a8d2e1e30bf50cb46@185.227.135.168:26656,bec7e26f83cdd618117222df98179dde5267c320@5.199.133.245:26656,768c9b6ba484084e2190378031fa7e00e034d5d7@18.208.126.139:26656,93187d76f68379e638a765d29085b3ba9563d9a2@109.199.124.225:26656,acca2380e72b373f675377cb701c4d7c53bf60f5@158.220.123.155:26656,bb3964b5fdf85ed514b87b5fac648b92af0d17e9@62.171.158.190:26656,a5ad471d86ad96662386f818e5154b752dd0db5b@45.138.74.92:26656,7aff157c9b8acdb9a08ccd815e3c84291f788d97@213.199.35.110:26656,5ba1ee130906c7237ee57746e10659f912fb013c@154.26.137.205:26656,faf2b157f2708d42a6290ffb8c0973c878ae070e@46.250.240.29:26656,3e8b4282a845b3fa3d81833fc7d8ddda957cb5d1@144.126.156.170:26656,16c7e580da86a32162428304e7f75b716565e172@109.199.122.14:26656,4e574b3a07a103b21b3b403969f3fa1bad205511@213.199.40.197:26656,f999e0e4c3cdca471a0c482fe9c0bc01b63b53bf@144.76.14.158:20735,70e48b8da492ea80e4c2d03434e4a3700a0df267@84.46.252.156:26656,ff405d11154781893a55e40b2de9d1223b504c23@84.247.139.43:26656,1a34a682210d72380c24af5e93e84f751983e396@207.180.193.69:26656,12491be96b69bac51b422f76dd8fa4acd58756b9@109.123.248.212:26656,1a0af60b43129f4d73705547c3a6e6b94db9713c@5.182.33.155:26656,6563d4a89eeb574a635f74b6ed36d70cdd437656@173.249.35.247:26656,9a899eb2ec0f5e9e8324b8d228f18a0bcec27692@158.220.85.33:26656,6a246cca48b4fb3cb8b927f8c4edc67feb7ca32c@84.247.169.150:26656,bbabc2d8aa0e04bb3f64bf3bfaad8bb826443fc4@110.15.215.66:26656,4edc6cbd46a3de2b0c710298bf403e06d5e7725d@209.126.3.74:26656,6632c44bd71a583e9f6682b3a62fc3e9160968fd@144.91.123.67:20656,cd11f2d87e2e0237c675c88a603b8a20e239a4a6@194.233.78.49:26656,8b40f51bcfd600278edcb9fd666f52b490b0c67c@154.26.137.255:26656,79cea34432411b5a8c97b4042d496346dcd2bc0a@5.189.130.6:26656,ae628ef30029e007f9cca98062b8eff74c34ac8e@168.119.4.132:26656,5c8c0de422a6bedaabcc582252aebe4f77d51be8@185.209.223.10:26656,0b789e5315cdddb90866010139a278b46c4f9788@167.86.111.177:26656,aa1c8ecb1a4c7e53d76f0f317ec942a2dc8fe7cd@185.182.186.238:26656,9eeded526eb53136ffbb1b3696d0254941a06618@109.199.105.57:26656,2b192c278abb626af9465c75b94f932d48a391a8@185.218.125.65:26656,051780104a73614e2da295fb5a11ef0def62be0b@154.26.128.108:26656,70e9138321d134672cae29a42dc78eae1c57f7fa@45.138.74.85:26656,1839ecc203a5138d93b10c51cfa751c5f7ff8cca@164.68.98.110:26656,96635f71e098071103138c35ffe27d4215200ec1@213.199.35.217:26656,455400419ca3feeb75d175605e86cd8f3b7609f6@149.102.129.144:26656,0c71004baa6be84cf5f27f2aac2f5e29e2b1a981@43.159.33.114:20656,99eece2e4a476b9c82ae212d6dbdef53081b6f3b@154.26.139.132:26656,b79179f00d657db37464fc46bc6a3c463c174f1f@176.9.11.189:26656,6c70ab8f7f2be0b15646d00da9da6980b5ab2063@193.87.163.5:16456,eb0ef2428e4540bb00b797824e052c7933263bf7@84.247.183.75:26656,3fb451b99f0c2055a88febdd2962d75b6b730205@178.63.147.45:20656,163439dd5fc57394b9b13d395d252115c8e8cd7f@152.53.0.41:26656,740541323452e4bec7b61f50c6efbb3d9eb5e096@94.72.106.222:26656,df3eefcb6ecb62c477a9a019b5f2fb285b9f48f4@109.199.111.124:26656,dc1bf859aa5285ea2a52b1f805a9482556a8381d@194.163.164.240:28656,6f117f7e259482f4477a09664b4528e4a0fe9be2@5.199.173.45:26656,f53c5a6184f33a8c9a1d4ecd39b7982261dbbe9d@173.249.17.188:26656,69f9af24d68a73b30afa2490fcde51abd665b878@207.180.233.46:20656,79870ad22fdf23027a36f3b515d8a0d28be9beeb@109.123.237.16:26656,bd514dc5cf5599b3dc18a9bf31591047f18b5b6d@38.242.250.40:26656,317fe00292707fb14ada256d1685586bdeb948b7@123.118.9.33:26656,0515c5df5673e79a2c56495ee99c85e4b29ff736@154.12.245.42:26656"
#PEERS="8922e2644ed7af59a2a724819432aae5df8c1197@154.26.128.52:26656,724c8c4b382a2832b65b19462baaa879ede4a647@85.148.51.82:26656,79973384380cb9135411bd6d79c7159f51373b18@133.242.221.45:26656,5145171795b9929c41374ce02feef8d11228c33b@160.202.128.199:55706,75d9957d90caa8a457a94d33dc69f7e847f4b58c@37.60.248.54:26656,38b27d582d7fcbe9ce3ef0b30b4e8e70acad7b62@116.203.55.220:26656,f43d529b140714bc12745662185b5107d464410d@78.46.61.108:46656,1566d505b8fa40b067f2d881c380f5866c618561@94.228.162.187:26656,79befb0680b4d3670bc46777677b4e904faab5e1@154.26.130.53:26656,d328c6f74f5039a0d3d829a86c3c3911ddf03e7a@109.199.115.129:26656,faeb6f14ed03744e3bdda42f207224944c2d5e90@173.249.52.53:26656,2d241785bf3004d82be8d32c901d62d21d9e70f2@180.83.70.240:26656,4ba238c40cbd54b654cff009fbd02373a2235a61@207.180.218.52:26656,54fce5236ad360aaccc731a164f720d9eb62951c@109.199.115.132:26656,487cbabe4db1d1dcbf45ad271ad57a367f3bc138@45.94.58.53:26656,2c1de581a482ba5765f400d3e3bb144e6e6994c5@149.102.129.209:26656,9fafb42160d1a4d657ecd48c59060162b373c1bf@68.183.195.179:26656,e022461bf6ffc2d1880eca75e00dfd9920832ee7@147.45.71.126:26656,0be8a6aa4c29eb72b90bccced27574c1224ddb30@62.171.189.52:26656,3be7d5d891d5174865789ee32288a67ae37816ac@152.89.105.112:26656"
#sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.babylond/config/config.toml
#PEERS="1a34a682210d72380c24af5e93e84f751983e396@207.180.193.69:26656,96635f71e098071103138c35ffe27d4215200ec1@213.199.35.217:26656,3e8b4282a845b3fa3d81833fc7d8ddda957cb5d1@144.126.156.170:26656,aa1c8ecb1a4c7e53d76f0f317ec942a2dc8fe7cd@185.182.186.238:26656,740541323452e4bec7b61f50c6efbb3d9eb5e096@94.72.106.222:26656"
#sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.babylond/config/config.toml
PEERS="f42d0a170fb29b0e79946da834c2df8f4717e786@37.60.244.156:26656,93646841a8d3b2567c5bdb27daecdfb265434576@195.201.177.4:26656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.babylond/config/config.toml


# 设置启动服务
sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=Babylon daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which babylond) start
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_NAME=babylond"
Environment="DAEMON_HOME=${HOME}/.babylond"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"

[Install]
WantedBy=multi-user.target
EOF

sudo -S systemctl daemon-reload
sudo -S systemctl enable babylond
sudo -S systemctl start babylond

    echo '====================== 安装完成 ==========================='
    
}

# 创建钱包
function add_wallet() {
    read -p "请输入钱包名称: " wallet_name
    babylond keys add "$wallet_name"
}

# 创建验证者
function add_validator() {
    read -p "请输入你的验证者名称: " validator_name
    sudo tee ~/validator.json > /dev/null <<EOF
{
  "pubkey": $(babylond tendermint show-validator),
  "amount": "100000ubbn",
  "moniker": "$validator_name",
  "details": "dalubi",
  "commission-rate": "0.10",
  "commission-max-rate": "0.20",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
EOF
    /root/go/bin/babylond tx checkpointing create-validator ~/validator.json \
    --chain-id=bbn-test-3 \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.025ubbn" \
    --from=wallet
}

# 导入钱包
function import_wallet() {
    read -p "请输入钱包名称: " wallet_name
    babylond keys add "$wallet_name" --recover
}

# 查询余额
function check_balances() {
    read -p "请输入钱包地址: " wallet_address
    babylond query bank balances "$wallet_address" 
}

# 查看节点同步状态
function check_sync_status() {
    babylond status | jq .sync_info
}

# 查看babylon服务状态
function check_service_status() {
    systemctl status babylond
}

# 节点日志查询
function view_logs() {
    sudo journalctl -f -u babylond.service 
}

# 卸载脚本功能
function uninstall_script() {
    local alias_name="babylondf"
    local shell_rc_files=("$HOME/.bashrc" "$HOME/.zshrc")

    for shell_rc in "${shell_rc_files[@]}"; do
        if [ -f "$shell_rc" ]; then
            # 移除快捷键
            sed -i "/alias $alias_name='bash $SCRIPT_PATH'/d" "$shell_rc"
        fi
    done

    echo "快捷键 '$alias_name' 已从shell配置文件中移除。"
    read -p "是否删除脚本文件本身？(y/n): " delete_script
    if [[ "$delete_script" == "y" ]]; then
        rm -f "$SCRIPT_PATH"
        echo "脚本文件已删除。"
    else
        echo "脚本文件未删除。"
    fi
}

# 主菜单
function main_menu() {
    clear
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 创建钱包"
    echo "3. 导入钱包"
    echo "4. 创建验证者"
    echo "5. 查看钱包地址余额"
    echo "6. 查看节点同步状态"
    echo "7. 查看当前服务状态"
    echo "8. 运行日志查询"
    echo "9. 卸载脚本"
    echo "10. 设置快捷键"  
    read -p "请输入选项（1-10）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) add_wallet ;;
    3) import_wallet ;;
    4) add_validator ;;
    5) check_balances ;;
    6) check_sync_status ;;
    7) check_service_status ;;
    8) view_logs ;;
    9) uninstall_script ;;
    10) check_and_set_alias ;;  
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
