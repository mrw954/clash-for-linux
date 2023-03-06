#!/bin/bash

Server_Dir=$(
	cd $(dirname "$0") || exit
	pwd
)
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"
# hostip=$(hostname -I | awk '{print $1}')
hostip=127.0.0.1
port=7890
PROXY_HTTP="http://${hostip}:${port}"

start_clash() {
	# 启动Clash服务
	nohup "$Server_Dir"/bin/clash-linux-amd64 -d "$Conf_Dir" &>>"$Log_Dir"/clash.log &
	if test $? -eq 0; then
		echo "Clash 服务启动成功！"
	else
		echo "Clash 服务启动失败！"
	fi
}

set_proxy() {
	export http_proxy="${PROXY_HTTP}"
	export HTTP_PROXY="${PROXY_HTTP}"

	export https_proxy="${PROXY_HTTP}"
	export HTTPS_proxy="${PROXY_HTTP}"

	export ALL_PROXY="${PROXY_SOCKS5}"
	export all_proxy="${PROXY_SOCKS5}"

	git config --global http.https://github.com.proxy "${PROXY_HTTP}"
	git config --global https.https://github.com.proxy "${PROXY_HTTP}"

	echo "Proxy has been opened."
}

unset_proxy() {
	unset http_proxy
	unset HTTP_PROXY
	unset https_proxy
	unset HTTPS_PROXY
	unset ALL_PROXY
	unset all_proxy
	git config --global --unset http.https://github.com.proxy
	git config --global --unset https.https://github.com.proxy

	echo "Proxy has been closed."
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

exit_clash() {
	PID_NUM=$(ps -ef | grep [c]lash-linux-a | wc -l)
	PID=$(ps -ef | grep [c]lash-linux-a | awk '{print $2}')
	if [ "$PID_NUM" -ne 0 ]; then
		kill -9 "$PID"
		echo -e "clash服务关闭成功\n"
	fi
}
help() {
	printf "proxy on\n"
	printf "proxy off\n"
	printf "proxy test\n"
}

if [ "$1" = "help" ]; then
	help
elif [ "$1" = "set" ]; then
	set_proxy
elif [ "$1" = "unset" ]; then
	unset_proxy
elif [ "$1" = "test" ]; then
	test_setting
elif [ "$1" = "off" ]; then
	unset_proxy
	exit_clash
elif [ "$1" = "on" ]; then
	start_clash
	set_proxy
	test_setting
else
	echo "Unsupported arguments."
fi
