#!/bin/bash

Server_Dir=$(
	cd $(dirname $0)
	pwd
)
Conf_Dir="$Server_Dir/conf"
Temp_Dir="$Server_Dir/temp"
Log_Dir="$Server_Dir/logs"

# 临时取消环境变量
unset http_proxy
unset https_proxy
unset no_proxy

# 启动Clash服务
echo '\n正在启动Clash服务...'
Text5="服务启动成功！"
Text6="服务启动失败！"

nohup $Server_Dir/bin/clash-linux-amd64 -d $Conf_Dir &>>$Log_Dir/clash.log &
if [ $? -eq 0 ]
then
    echo "服务启动成功！"
else
    echo "服务启动失败！"
fi

# 添加环境变量(root权限)
cat >/etc/profile.d/clash.sh <<EOF
# 开启系统代理
function proxy_on() {
	export http_proxy=http://127.0.0.1:7890
	export https_proxy=http://127.0.0.1:7890
	export no_proxy=127.0.0.1,localhost
	echo -e "\033[32m[√] 已开启代理\033[0m"
}

# 关闭系统代理
function proxy_off(){
	unset http_proxy
	unset https_proxy
	unset no_proxy
	echo -e "\033[31m[×] 已关闭代理\033[0m"
}
EOF

echo "请执行以下命令加载环境变量: source /etc/profile.d/clash.sh"
echo "请执行以下命令开启系统代理: proxy_on"
echo "若要临时关闭系统代理，请执行: proxy_off"
