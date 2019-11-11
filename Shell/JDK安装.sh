#!/bin/bash

# 2019-8-13
# 安装jdk
# 包要自己下载到本地再传到服务器上面，下载jdk的源码包花费的时间太久了

# 安装jdk1.8
function jdk1_8_install(){
	# 源码包存放目录
	SOFTWARE_DIR="/opt/software/"
	# 安装目录
	INSTALL_DIR="/data/www/"
	# 创建目录
	[ ! -d ${SOFTWARE_DIR} ] && mkdir -p ${SOFTWARE_DIR}
	[ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
	# 下载地址
	# https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
	# 需要点“download this software Accept License Agreement”才可以下载
	PACKAGE_NAME="jdk-8u191-linux-x64.tar.gz"
	# 安装jdk
	cd ${SOFTWARE_DIR}
	tar -zxvf ${SOFTWARE_DIR}${PACKAGE_NAME} -C ${INSTALL_DIR}
	# 解压出来的文件夹名字（应该可以判断包名是什么的，这里写死了）
	# 如果目录下只有一个以jdk开头的文件夹，可以匹配出来
	# UNZIP_PACKAGE_NAME=$(ls ${INSTALL_DIR} | egrep "jdk*")
	UNZIP_PACKAGE_NAME="jdk1.8.0_191"
	#添加jdk环境变量
	echo -e "# jdk1.8\nexport JAVA_HOME=${INSTALL_DIR}${UNZIP_PACKAGE_NAME}\nexport JRE_HOME=${INSTALL_DIR}${UNZIP_PACKAGE_NAME}/jre\n" >> /etc/profile
	echo -e "export CLASSPATH=.:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar:$JRE_HOME/lib:\${CLASSPATH}\nexport PATH=\${JAVA_HOME}/bin:\${PATH}" >> /etc/profile

	# 使环境变量生效（理论流程是这样，但是脚本执行这个命令不生效，脚本结束之后还需要再手动执行一遍。）
	# 好像是source /etc/profile只在当前会话生效，而且shell和打开的当前会话不是同一个会话，重新source /etc/profile后就可以生效了。
	source /etc/profile
	# 查看java版本
	java -version
}

# 安装jdk11
function jdk11_install(){
	# 下载jdk（https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html）
	[ ! -d /opt/software ] && mkdir /opt/software
	cd /opt/software
	wget -c https://blog.forsre.com/java/jdk-11.0.4_linux-x64_bin.tar.gz
	# 解压
	tar -zxvf jdk-11.0.4_linux-x64_bin.tar.gz -C /opt/
	# 添加jdk环境变量
	echo -e "# jdk-11.0.4\nexport JAVA_HOME=/opt/jdk-11.0.4\nexport PATH=\${PATH}:\${JAVA_HOME}/bin" >> /etc/profile
	# 使配置文件生效
	source /etc/profile
	# 查看Java版本
	java --version
}

function main(){
	if [[ ! -z $1 ]]; then
		if [[ $1 == "jdk1.8" ]]; then
			jdk1_8_install
		elif [[ $1 == "jdk11" ]]; then
			jdk11_install
		else
			echo "传入参数错误"
			exit
		fi
	else
		echo "请用 sh $0 jdk1.8|jdk11 来执行脚本"
		exit
	fi
	
}

main $1

# 脚本运行不一定能成功，不喜勿喷！
