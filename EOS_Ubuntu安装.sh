#!/bin/bash

# 2019-09-16
# EOS部署(Ubuntu 16.04.6 LTS)
# 参考：https://www.cnblogs.com/elvi/p/10205785.html
# https://www.cnblogs.com/sinsenliu/p/9634670.html

# 安装eos
function eosio_install(){
	sudo apt update
	# 安装git
	sudo apt install -y git
	[ ! -d /data ] && mkdir -p /data
	cd /data/
	# 参数 --recursive 表示下载项目需要的所有子模块
	git clone https://github.com/EOS-Mainnet/eos.git --recursive
	[ $? -ne 0 ] && exit 1
	cd /data/eos/
	# 切换到最新版本
	git checkout $(git tag | grep mainnet | tail -n 1)
	git branch
	# 更新子模块
	git submodule update --init --recursive
	# 修改MongoDB的下载地址
	sed -i 's#https://fastdl.mongodb.org#http://downloads.mongodb.org#' /data/eos/scripts/*.sh
	echo -e "\033[31m准备运行编译，要几个小时才完成\033[0m"
	echo -e "\033[31m需要输入“1”去确认下载依赖包，之后就是等待编译完成\033[0m"
	sleep 5
	# 运行编译，要几个小时才完成
	/data/eos/eosio_build.sh -s "EOS"

	# 需要输入“1”去确认下载依赖包
	
	# 出现信息，成功
	# EOSIO has been successfully built. 02:04:58	

	# To verify your installation run the following commands:
	# /root/data/mongodb/bin/mongod -f /root/data/mongodb/mongod.conf &
	# source /data/rh/python33/enable
	# export PATH=${HOME}/data/mongodb/bin:$PATH
	# cd /data/eos/build; make test
	# For more information:
	# EOSIO website: https://eos.io
	# EOSIO Telegram channel @ https://t.me/EOSProject
	# EOSIO resources: https://eos.io/resources/
	# EOSIO Stack Exchange: https://eosio.stackexchange.com
	# EOSIO wiki: https://github.com/EOSIO/eos/wiki	

	# 编译完成后，安装
	/data/eos/eosio_install.sh
	# 出现信息，成功
	# Installing EOSIO Binary Symlinks
	#  _______  _______  _______ _________ _______
	# (  ____ \(  ___  )(  ____ \\__   __/(  ___  )
	# | (    \/| (   ) || (    \/   ) (   | (   ) |
	# | (__    | |   | || (_____    | |   | |   | |
	# |  __)   | |   | |(_____  )   | |   | |   | |
	# | (      | |   | |      ) |   | |   | |   | |
	# | (____/\| (___) |/\____) |___) (___| (___) |
	# (_______/(_______)\_______)\_______/(_______)
	# For more information:
	# EOSIO website: https://eos.io
	# EOSIO Telegram channel @ https://t.me/EOSProject
	# EOSIO resources: https://eos.io/resources/
	# EOSIO Stack Exchange: https://eosio.stackexchange.com
	# EOSIO wiki: https://github.com/EOSIO/eos/wiki	

	# 创建主网节点目录
	[ ! -d /data/EOSmainNet ] && mkdir -p /data/EOSmainNet
	cd /data/EOSmainNet/
	git clone https://github.com/CryptoLions/EOS-MainNet.git ./
	chmod a+x /data/EOSmainNet/*.sh
	chmod a+x /data/EOSmainNet/Wallet/*.sh
	# 修改区块存储限制
	# 备份初始文件
	cp /data/EOSmainNet/config.ini /tmp/config.ini_initial
	sed -i 's/chain-state-db-size-mb = 65536/chain-state-db-size-mb = 102400/' /data/EOSmainNet/config.ini
	# 更改nodeos编译路径（cleos.sh，start.sh，Wallet/start_wallet.sh）
	sed -i 's#/home/eos-sources/eos#/data/eos#' /data/EOSmainNet/*.sh
	sed -i 's#/home/eos-sources/eos#/data/eos#' /data/EOSmainNet/Wallet/*.sh
	# 修改脚本路径
	sed -i 's/opt/data/g' /data/EOSmainNet/*.sh
	sed -i 's/opt/data/g' /data/EOSmainNet/Wallet/*.sh

	# 提前解决报错
	sed -i "s/http-threads.*/#&/" /data/EOSmainNet/config.ini
	# 首次启动,清除现有区块并加入主网
	sudo /data/EOSmainNet/start.sh --genesis-json /data/EOSmainNet/genesis.json --delete-all-blocks

	# 再次启动，不需指定genesis.json
	# sudo /data/EOSmainNet/start.sh
	# 关闭 
	# sudo /data/EOSmainNet/stop.sh	

	# “首次启动,清除现有区块并加入主网”报错
	# std::exception::what: unrecognised dataion 'http-threads'
	# 解决
	# 注释掉config.ini里面的http-threads = 6
	# 再启动
	# sudo /data/EOSmainNet/start.sh --genesis-json /data/EOSmainNet/genesis.json --delete-all-blocks
}

# 倒计时
function countdown(){
	# 倒计时多少时间
	TIME="120"
	i=0
	while [[ ${TIME} -ge ${i} ]]; do
		echo -e "\033[31m倒计时\033[0m \033[34m ${TIME} \033[0m"
		let TIME-=1
		sleep 1
	done
}

# 解决不可用节点
function p2p_peer_address(){

	# 查看错误日志，报错Connection refused和Host not found和Connection timed out
	# tail -f stderr.txt 
	# error 2019-09-17T02:19:26.665 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to peering.dutcheos.io:9876: Connection refused
	# error 2019-09-17T02:19:26.773 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to peer.eosio.sg:9876: Connection refused
	# error 2019-09-17T02:19:56.354 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to p2p.mainnet.eosgermany.online:9876: Connection refused
	# error 2019-09-17T02:19:56.399 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to 94.130.250.22:9806: Connection refused
	# error 2019-09-17T02:19:56.689 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to peering.dutcheos.io:9876: Connection refused
	# error 2019-09-17T02:19:56.754 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to peer.eosio.sg:9876: Connection refused
	# error 2019-09-17T02:15:34.028 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to 45.33.60.65:9820: Connection timed out
	# error 2019-09-17T02:15:34.028 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to fullnode.eoslaomao.com:443: Connection timed out
	# error 2019-09-17T02:15:34.029 thread-0  net_plugin.cpp:1903           operator()           ] connection failed to peering.eosio.cr:1976: Connection timed out
	# error 2019-09-17T02:17:26.528 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve dc1.eosemerge.io:9876: Host not found (authoritative)
	# error 2019-09-17T02:17:26.568 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve new.eoshenzhen.io:10034: Host not found (authoritative)
	# error 2019-09-17T02:17:26.706 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve p2p-public.hkeos.com:19875: Host not found (authoritative)
	# error 2019-09-17T02:17:26.762 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve node.eosmeso.io:9876: Host not found (authoritative)
	# error 2019-09-17T02:17:26.813 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve 807534da.eosnodeone.io:19872: Host not found (authoritative)
	# error 2019-09-17T02:17:26.873 thread-0  net_plugin.cpp:1875           operator()           ] Unable to resolve mainnet.eoseco.com:10010: Host not found (authoritative)	
	
	# 先睡眠2分钟，尽量让不能用的节点都显示出来，做好替换的准备。
	countdown

	EOSMAINNET_DIR="/data/EOSmainNet/"
	cd ${EOSMAINNET_DIR}
	
	EOS_STDERR_LOG="/data/EOSmainNet/stderr.txt"
	EOS_CONFIG_INI="/data/EOSmainNet/config.ini"
	# 获取全部不可用的节点
	CONNECTION_REFUSED_ARRAY=($(awk '/Connection refused/{print $10}' ${EOS_STDERR_LOG} | awk -F':' '{print $1":"$2}' | sort -u))
	HOST_NOT_FOUND_ARRAY=($(awk '/Host not found/{print $10}' ${EOS_STDERR_LOG} | awk -F':' '{print $1":"$2}' | sort -u))
	CONNECTION_TIMED_OUT_ARRAY=($(awk '/Connection timed out/{print $10}' ${EOS_STDERR_LOG} | awk -F':' '{print $1":"$2}' | sort -u))
	# 放到大数组里
	UNAVAILABLE_NODES=(${CONNECTION_REFUSED_ARRAY[@]} ${HOST_NOT_FOUND_ARRAY[@]} ${CONNECTION_TIMED_OUT_ARRAY[@]})

	# 备份原文件
	cp config.ini{,_$(date +%F).bak}
	for nodes in ${UNAVAILABLE_NODES[@]}; do
		sed -i "s/^p2p-peer-address.*${nodes}/#&/" ${EOS_CONFIG_INI}
	done

	# 添加可用节点
	# 输出看看可用节点
	echo -e "\033[31m可用节点\033[0m"
	curl https://eosnodes.privex.io/?config=1 -w "\n"
	cp config.ini{,_$(date +%F).bak}
	# 输出到文件
	AVAILABLE_NODE_DIRECTORY="/tmp/p2p_peer_address.txt"
	curl https://eosnodes.privex.io/?config=1 -w "\n" > ${AVAILABLE_NODE_DIRECTORY}
	# 然后添加可用节点到/data/EOSmainNet/config.ini文件里
	for i in $(awk '{print $NF}' ${AVAILABLE_NODE_DIRECTORY}); do
		if [[ ! $(grep ${i} ${EOS_CONFIG_INI}) ]]; then
			echo "p2p-peer-address = ${i}" >> ${EOS_CONFIG_INI}
		fi
	done

	# 重启EOS
	sudo /data/EOSmainNet/start.sh
}

function main(){
	eosio_install
	p2p_peer_address
}

main

# 查看chain_id是否为：aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906（主网的id）
# sudo /data/EOSmainNet/cleos.sh get info
# 查看区块同步
# curl -s  http://localhost:8888/v1/chain/get_info | jq