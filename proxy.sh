#!/bin/bash

Server_Dir=$(
	cd $(dirname "$0") || exit
	pwd
)
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"
# hostip=$(hostname -I | awk '{print $1}')

set_proxy() {
	export http_proxy=http://127.0.0.1:7890
	export https_proxy=http://127.0.0.1:7890
	export no_proxy=127.0.0.1,localhost
}

unset_proxy() {
	unset http_proxy
	unset https_proxy
	unset no_proxy
}

test_setting() {
	echo "Try to connect to Google..."
	resp=$(curl -I -s --connect-timeout 5 -m 5 -w "%{http_code}" -o /dev/null www.google.com)
	if [ "${resp}" = 200 ]; then
		echo "Proxy setup succeeded!"
	else
		echo "Proxy setup failed!"
	fi
}

start_clash() {
	# 重复性检测
	PID_NUM=$(ps -ef | grep [c]lash-linux-a | wc -l)
	PID=$(ps -ef | grep [c]lash-linux-a | awk '{print $2}')
	if [ "$PID_NUM" -ne 0 ]; then
		echo "Clash 服务已启动！"
	else
		# 启动Clash服务
		nohup "$Server_Dir"/bin/clash-linux-amd64 -d "$Conf_Dir" &>>"$Log_Dir"/clash.log &
		if test $? -eq 0; then
			echo "Clash 服务启动成功！"
		else
			echo "Clash 服务启动失败！"
		fi
	fi
}

exit_clash() {
	PID_NUM=$(ps -ef | grep [c]lash-linux-a | wc -l)
	PID=$(ps -ef | grep [c]lash-linux-a | awk '{print $2}')
	if [ "$PID_NUM" -ne 0 ]; then
		kill -9 "$PID"
		echo -e "clash服务关闭成功 $PID\n"
	fi
}

help() {
	printf "proxy on\n"
	printf "proxy off\n"
	printf "proxy test\n"
}

if [ "$1" = "test" ]; then
	test_setting
elif [ "$1" = "off" ]; then
	unset_proxy
	exit_clash
elif [ "$1" = "on" ]; then
	start_clash
	set_proxy
else
	echo "Unsupported arguments."
fi
