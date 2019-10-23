#!/bin/bash

# 2019-10-10
# BTC和USDT生成随机地址和标签
# 生成新地址个数
GETNEWADDRESS_NUMBER=5
# 生成标签长度
LABEL_LENGTH=16

# BTC获取新地址命令
BTC_GETNEWADDRESS_COMMAND="/data/coins/BTC/bitcoin-0.17.1/bin/bitcoin-cli -conf=/data/coins/BTC/btcdata/bitcoin.conf getnewaddress"
# BTC新地址文件存放位置
BTC_GETNEWADDRESS_DIR="/tmp/btc_getnewaddress.txt"
# BTC标签文件存放位置
BTC_LABEL_DIR="/tmp/btc_label.txt"
# BTC新地址和标签合并之后文件存放位置
BTC_PASTE_GETNEWADDRESS_LABEL_DIR="/tmp/btc_paste_getnewaddress_label.txt"
# USDT获取新地址命令
USDT_GETNEWADDRESS_COMMAND="/data/coins/USDT/omnicore-0.3.1/bin/omnicore-cli --datadir=/data/coins/USDT/usdtdata --conf=/data/coins/USDT/usdtdata/usdtcoin.conf getnewaddress"
# USDT新地址文件存放位置
USDT_GETNEWADDRESS_DIR="/tmp/usdt_getnewaddress.txt"
# USDT标签文件存放位置
USDT_LABEL_DIR="/tmp/usdt_label.txt"
# USDT新地址和标签合并之后文件存放位置
USDT_PASTE_GETNEWADDRESS_LABEL_DIR="/tmp/usdt_paste_getnewaddress_label.txt"

# 清空文件
function clear_dir(){
	> $1
	> $2
	> $3
}

# 生成新地址
function generate_btc_usdt_getnewaddress(){
	# 生成新地址个数
	for (( i = 0; i < ${GETNEWADDRESS_NUMBER}; i++ )); do
		$1 >> $2
	done
}
# 生成固定标签
function generate_fixed_labels(){
	for (( i = 0; i < ${GETNEWADDRESS_NUMBER}; i++ )); do
		echo $1 >> $2
	done
}
# 生成随机标签
function generate_random_labels(){
	# 数字0-9
	NUMBER=($(echo {0..9}))
	# 小写字母
	LOWERCASE_LETTERS=($(echo {a..z}))
	# 大写字母
	CAPITAL_LETTER=($(echo {A..Z}))
	# 全部字符
	ALL_CHARACTERS=(${NUMBER[@]} ${LOWERCASE_LETTERS[@]} ${CAPITAL_LETTER[@]})
	# 全部字符长度
	ALL_CHARACTERS_LENGTH=${#ALL_CHARACTERS[@]}

	# 计数器
	COUNT=0
	while [[ true ]]; do
		# 生成标签长度
		# LABEL_LENGTH=16
		LABEL=""
		for (( j = 0; j < ${LABEL_LENGTH}; j++ )); do
			# 随机下标
			INDEX=$(($RANDOM%${ALL_CHARACTERS_LENGTH}))
			# 标签组合
			LABEL=${LABEL}${ALL_CHARACTERS[INDEX]}
		done
		echo ${LABEL} >> $1
		# 多少个标签就停止输出
		let COUNT++
		if [[ ${COUNT} -ge ${GETNEWADDRESS_NUMBER} ]]; then
			break
		fi
	done
}
# 合并新地址和标签
function paste_btc_usdt_getnewaddress_label(){
	paste $1 $2 > $3
}

function main(){
	if [[ $1 == "btc" ]]; then
		# 清空文件
		clear_dir "${BTC_GETNEWADDRESS_DIR}" "${BTC_LABEL_DIR}" "${BTC_PASTE_GETNEWADDRESS_LABEL_DIR}"
		# 生成新地址
		generate_btc_usdt_getnewaddress "${BTC_GETNEWADDRESS_COMMAND}" "${BTC_GETNEWADDRESS_DIR}"
		if [[ $2 == "fixed" ]]; then
			# 生成固定标签
			BTC_LABEL="BTC$(date +"%Y%m%d%H%M")${GETNEWADDRESS_NUMBER}"
			generate_fixed_labels "${BTC_LABEL}" "${BTC_LABEL_DIR}"
		elif [[ $2 == "random" ]]; then
			# 生成随机标签
			generate_random_labels "${BTC_LABEL_DIR}"
		else
			echo "参数错误！"
			echo "$0 btc|usdt fixed|random"
		fi
		# 合并新地址和标签
		paste_btc_usdt_getnewaddress_label "${BTC_GETNEWADDRESS_DIR}" "${BTC_LABEL_DIR}" "${BTC_PASTE_GETNEWADDRESS_LABEL_DIR}"

	elif [[ $1 == "usdt" ]]; then
		# 清空文件
		clear_dir "${USDT_GETNEWADDRESS_DIR}" "${USDT_LABEL_DIR}" "${USDT_PASTE_GETNEWADDRESS_LABEL_DIR}"
		# 生成新地址
		generate_btc_usdt_getnewaddress "${USDT_GETNEWADDRESS_COMMAND}" "${USDT_GETNEWADDRESS_DIR}"
		if [[ $2 == "fixed" ]]; then
			# 生成固定标签
			USDT_LABEL="USDT$(date +"%Y%m%d%H%M")${GETNEWADDRESS_NUMBER}"
			generate_fixed_labels "${USDT_LABEL}" "${USDT_LABEL_DIR}"
		elif [[ $2 == "random" ]]; then	
			# 生成随机标签
			generate_random_labels "${USDT_LABEL_DIR}"
		else
			echo "参数错误！"
			echo "$0 btc|usdt fixed|random"
		fi
		# 合并新地址和标签
		paste_btc_usdt_getnewaddress_label "${USDT_GETNEWADDRESS_DIR}" "${USDT_LABEL_DIR}" "${USDT_PASTE_GETNEWADDRESS_LABEL_DIR}"
		
	else
		echo "参数错误！"
		echo "$0 btc|usdt fixed|random"
	fi
}

main $1 $2
