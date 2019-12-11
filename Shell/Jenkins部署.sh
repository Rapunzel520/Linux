#!/bin/bash

# 2019-09-09
# Jenkins部署
# 参考：https://jenkins.io/doc/pipeline/tour/getting-started/

# 安装jdk
function jdk_install(){
	echo -e "\033[31m 安装JDK \033[0m"
	# 下载jdk（https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html）
	[ ! -d /opt/software ] && mkdir /opt/software
	cd /opt/software
	wget -c https://blog.forsre.com/java/jdk-11.0.4_linux-x64_bin.tar.gz
	# 解压
	tar -zxvf jdk-11.0.4_linux-x64_bin.tar.gz -C /opt/
	# 添加jdk环境变量
cat >> /etc/profile << \EOF
# jdk-11.0.4
export JAVA_HOME=/opt/jdk-11.0.4
export PATH=${PATH}:${JAVA_HOME}/bin
EOF
	# 使配置文件生效
	source /etc/profile
	# 查看Java版本
	java --version
}

# 安装tomcat8
function tomcat8_jenkins_install(){
	echo -e "\033[31m 安装Tomcat \033[0m"
	[ ! -d /opt/software ] && mkdir -p /opt/software
	[ ! -d /data/www/tomcat8_jenkins ] && mkdir -p /data/www/tomcat8_jenkins
	cd /opt/software/
	wget -c http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz
	tar -zxvf apache-tomcat-8.5.35.tar.gz
	\cp -r apache-tomcat-8.5.35/* /data/www/tomcat8_jenkins/
	/data/www/tomcat8_jenkins/bin/version.sh
	rm -rf /data/www/tomcat8_jenkins/webapps/*
}

# 安装Jenkins
function jenkins_install(){
	echo -e "\033[31m 安装Jenkins \033[0m"
	# 安装依赖
	yum install -y fontconfig
	fc-cache --force
	# 创建目录
	[ ! -d /opt/software ] && mkdir -p /opt/software
	cd /opt/software/
	# 下载包
	wget -c http://mirrors.jenkins.io/war-stable/latest/jenkins.war
	# 把jenkins.war包放到tomcat8目录下面
	mv /opt/software/jenkins.war /data/www/tomcat8_jenkins/webapps/
	# 修改端口
	sed -i 's/<Server port="8005" shutdown="SHUTDOWN">/<Server port="38005" shutdown="SHUTDOWN">/' /data/www/tomcat8_jenkins/conf/server.xml
	sed -i 's/<Connector port="8080" protocol="HTTP/<Connector port="8091" protocol="HTTP/' /data/www/tomcat8_jenkins/conf/server.xml
	sed -i 's/<Connector port="8009" protocol="AJP/<Connector port="38009" protocol="AJP/' /data/www/tomcat8_jenkins/conf/server.xml
	# 启动
	sh /data/www/tomcat8_jenkins/bin/startup.sh
	echo -e "\033[31m浏览器访问   http://IP地址:端口/jenkins   进行Jenkins的初始化！\033[0m"
	sleep 20
	PASSWORD=$(cat /root/.jenkins/secrets/initialAdminPassword)
	echo -e "\033[31m 安全令牌：${PASSWORD} \033[0m"
}

function main(){
	jdk_install
	tomcat8_jenkins_install
	jenkins_install
}

main

# 问题记录
function problem(){
	# 启动Jenkins报错
	sh /data/www/tomcat8_jenkins/bin/startup.sh
	Jenkins home directory: /root/.jenkins found at: $user.home/.jenkins
	11-Dec-2019 22:10:30.045 严重 [localhost-startStop-1] hudson.util.BootFailure.publish Failed to initialize Jenkins
	hudson.util.AWTProblem: java.lang.InternalError: java.lang.reflect.InvocationTargetException

	# 解决
	# 参考：https://www.jianshu.com/p/15cb422a6e58
	# https://blog.csdn.net/crystonesc/article/details/86305466
	yum install -y fontconfig
	fc-cache --force
}