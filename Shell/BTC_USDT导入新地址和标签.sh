#!/bin/bash

# 2019-10-10
# BTC和USDT导入新地址和标签

# BTC导入新地址和标签命令(flase是不验证地址)
# BTC_GETNEWADDRESS_COMMAND="/data/coins/BTC-test/bitcoin-0.17.1/bin/bitcoin-cli -conf=/data/coins/BTC-test/btc-test-data/bittest.conf importaddress "地址XXX" "labelXXX" false"
BTC_GETNEWADDRESS_COMMAND="/data/coins/BTC/bitcoin-0.17.1/bin/bitcoin-cli -conf=/data/coins/BTC/btcdata/btccoin.conf"
# BTC新地址和标签合并之后文件存放位置
BTC_PASTE_GETNEWADDRESS_LABEL_DIR="/tmp/btc_paste_getnewaddress_label.txt"
# usdt导入新地址和标签命令
USDT_GETNEWADDRESS_COMMAND="/data/coins/USDT/omnicore-0.3.1/bin/omnicore-cli -conf=/data/coins/USDT/usdtdata/usdtcoin.conf"
# USDT新地址和标签合并之后文件存放位置
USDT_PASTE_GETNEWADDRESS_LABEL_DIR="/tmp/usdt_paste_getnewaddress_label.txt"

# 导入新地址和标签
function import_btc_usdt_getnewaddress_label(){
	# 获取新地址和标签行数
	NEWADDRESS_ROW=$(cat $1 | wc -l)
	for (( i = 1; i <= ${NEWADDRESS_ROW}; i++ )); do
		IMPORT_GETNEWADDRESS=""
		IMPORT_LABEL=""
		# 新地址
		# awk -v 是接收shell变量
		IMPORT_GETNEWADDRESS=$(awk -v newaddress_nr="${i}" 'NR==newaddress_nr {print $1}' $1)
		# 标签
		IMPORT_LABEL=$(awk -v newaddress_nr="${i}" 'NR==newaddress_nr {print $2}' $1)
		# 导入新地址命令+地址+标签+false
		$2 importaddress ${IMPORT_GETNEWADDRESS} ${IMPORT_LABEL} false
	done
}

# 判断需要导入的参数
function main(){
	# 判断传入的参数
	if [[ $1 == "btc" ]]; then
		# 调用函数（传值为btc）
		import_btc_usdt_getnewaddress_label "${BTC_PASTE_GETNEWADDRESS_LABEL_DIR}" "${BTC_GETNEWADDRESS_COMMAND}"
		echo -e "\033[31m用下面的命令测试BTC是否导入地址成功\033[0m"
		echo "${BTC_GETNEWADDRESS_COMMAND} getaddressesbylabel "标签""
	elif [[ $1 == "usdt" ]]; then
		# 调用函数（传值为usdt）
		import_btc_usdt_getnewaddress_label "${USDT_PASTE_GETNEWADDRESS_LABEL_DIR}" "${USDT_GETNEWADDRESS_COMMAND}"
		echo -e "\033[31m用下面的命令测试USDT是否导入地址成功\033[0m"
		echo "${USDT_GETNEWADDRESS_COMMAND} getaddressesbyaccount "标签""
	else
		echo "参数错误"
		echo "$0 btc|usdt"
	fi
}

main $1
