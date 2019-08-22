#!/bin/bash
# 2019-8-13
# 安装jdk1.8
# 包要自己下载到本地再传到服务器上面，下载jdk的源码包花费的时间太久了

mkdir -p /opt/software
mkdir -p /data/www

function jdk_install(){
	#安装jdk
	cd /opt/software
	tar -zxvf /opt/software/jdk-8u191-linux-x64.tar.gz -C /data/www/
	mv /data/www/jdk1.8.0_191 /data/www/jdk8
	#添加jdk环境变量
	cat >> /etc/profile << \EOF
	#jdk8
	export JAVA_HOME=/data/www/jdk8
	export JRE_HOME=/data/www/jdk8/jre
	export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH
	export PATH=$JAVA_HOME/bin:$PATH
	EOF
	#使环境变量生效
	source /etc/profile
	#查看java版本
	java -version
}

jdk_install