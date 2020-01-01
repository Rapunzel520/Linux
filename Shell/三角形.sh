#!/bin/bash

# 各类三角形
# 2020-01-01

function triangle_szie(){
	read -p "请输入三角形的大小:" TRIANGLE_SZIE
}

# 正三角形
function regular_triangle(){
	triangle_szie
	for i in $(seq 1 ${TRIANGLE_SZIE}); do
		for j in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
			if [[ ${j} -le $[TRIANGLE_SZIE-i] || ${j} -ge $[TRIANGLE_SZIE+i] ]]; then
				echo -n " "
			else
				echo -n "*"
			fi
		done
		echo
	done
}

# 倒三角形
function inverted_triangle(){
	triangle_szie
	for i in $(seq 1 ${TRIANGLE_SZIE}); do
		for j in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
			if [[ ${j} -lt ${i} || ${j} -gt $[2*TRIANGLE_SZIE-i] ]]; then
				echo -n " "
			else
				echo -n "*"
			fi
		done
		echo
	done
}

# 左三角形
function left_triangle(){
	triangle_szie
	for i in $(seq 1 ${TRIANGLE_SZIE}); do
		for j in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
			if [[ ${j} -le $[TRIANGLE_SZIE-i] || ${j} -gt ${TRIANGLE_SZIE} ]]; then
				echo -n " "
			else
				echo -n "*"
			fi
		done
		echo
	done
}

# 右三角形
function right_triangle(){
	triangle_szie
	for i in $(seq 1 ${TRIANGLE_SZIE}); do
		for j in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
			if [[ ${j} -lt ${TRIANGLE_SZIE} || ${j} -ge $[TRIANGLE_SZIE+i] ]]; then
				echo -n " "
			else
				echo -n "*"
			fi
		done
		echo
	done
}

# 菱形
function diamond(){
	triangle_szie
	for i in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
		for j in $(seq 1 $[2*TRIANGLE_SZIE-1]); do
			if [[ ${i} -le ${TRIANGLE_SZIE} ]]; then
				if [[ ${j} -le $[TRIANGLE_SZIE-i] || ${j} -ge $[TRIANGLE_SZIE+i] ]]; then
					echo -n " "
				else
					echo -n "*"
				fi
			elif [[ ${i} -gt ${TRIANGLE_SZIE} ]]; then
				if [[ ${j} -le $[i-TRIANGLE_SZIE] || ${j} -ge $[3*TRIANGLE_SZIE-i] ]]; then
					echo -n " "
				else
					echo -n "*"
				fi
			fi	
		done
		echo
	done
}

function menu(){
	echo -e "\033[31m ******************************* \033[0m"
	echo -e "\033[31m 请选择需要打印的三角形 \033[0m"
	echo -e "\033[31m 1.正三角形 \033[0m"
	echo -e "\033[31m 2.倒三角形 \033[0m"
	echo -e "\033[31m 3.左三角形 \033[0m"
	echo -e "\033[31m 4.右三角形 \033[0m"
	echo -e "\033[31m 5.菱形 \033[0m"
	echo -e "\033[31m 6.退出 \033[0m"
	echo -e "\033[31m ******************************* \033[0m"
	read -p "请输入需要打印三角形的序号：" SERIAL_NUMBER
}

function case_menu(){
	menu
	case ${SERIAL_NUMBER} in
		1 )
			# 正三角形
			regular_triangle
			;;
		2 )
			# 倒三角形
			inverted_triangle
			;;
		3 )
			# 左三角形
			left_triangle
			;;
		4 )
			# 右三角形
			right_triangle
			;;
		5 )
			# 菱形
			diamond
			;;
		6 )
			echo -e "\033[31m 退出 \033[0m"
			exit
			;;
		* )
			echo -e "\033[31m 输入错误，请重新输入 \033[0m"
			;;
	esac
}

function main(){
	while [[ true ]]; do
		case_menu
	done
}

main
