#!/bin/bash

# 2019-8-13
# 随机生成?位字符

function generate_random_strings(){
	# 数字0-9
	NUMBER=($(echo {0..9}))
	# 小写字母
	LOWERCASE_LETTERS=($(echo {a..z}))
	# 大写字母
	CAPITAL_LETTER=($(echo {A..Z}))
	# 特殊字符
	SPECIAL_CHARACTERS=(\! \@ \# \$ \% \^ \& \: \-)
	# 全部字符
	ALL_CHARACTERS=(${NUMBER[@]} ${LOWERCASE_LETTERS[@]} ${CAPITAL_LETTER[@]} ${SPECIAL_CHARACTERS[@]})
	# 全部字符长度
	ALL_CHARACTERS_LENGTH=${#ALL_CHARACTERS[@]}

	# 计数器
	COUNT=0
	# 生成密码个数
	# NUMBER_OF_PASSWORDS=10
	NUMBER_OF_PASSWORDS=$1
	while [[ true ]]; do
		# 生成密码长度
		# PASSWORD_LENGTH=16
		PASSWORD_LENGTH=$2
		PASSWORD=""
		for (( j = 0; j < ${PASSWORD_LENGTH}; j++ )); do
			# 随机下标
			INDEX=$(($RANDOM%${ALL_CHARACTERS_LENGTH}))
			# 密码组合
			PASSWORD=${PASSWORD}${ALL_CHARACTERS[INDEX]}
		done
		# 正则表达式，判断生成的密码强度
		REGULAR_EXPRESSION="[0-9a-zA-Z]{2,}[!@#$%^&:-]{2,}"
		echo ${PASSWORD} | egrep "${REGULAR_EXPRESSION}" > /dev/null
		# 符合正则表达式就输出
		if [[ $? -eq 0 ]]; then
			# 密码输出到文件
			# PASSWORD_STORAGE_DIRECTORY="/c/Users/Administrator/Desktop/生成16位随机密码.txt"
			# echo ${PASSWORD} >> ${PASSWORD_STORAGE_DIRECTORY}
			echo ${PASSWORD}
			# 多少个密码就停止输出
			let COUNT++
			if [[ ${COUNT} -ge ${NUMBER_OF_PASSWORDS} ]]; then
				break
			fi
		fi
	done
}

# generate_random_strings

# 生成?个密码，长度为?
generate_random_strings $1 $2

# 脚本运行不一定能成功，不喜勿喷！
