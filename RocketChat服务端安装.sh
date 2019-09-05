#!/bin/bash

# 2019-09-05
# 安装RocketChat服务端
# https://rocket.chat/docs/installation/manual-installation/centos/

# Rocket.Chat 1.0.2
# OS: CentOS 7.6
# Mongodb 4.0.9
# NodeJS 8.11.4

function rocketchat_install(){
	# 安装依赖包
	sudo yum -y check-update

cat << EOF | sudo tee -a /etc/yum.repos.d/mongodb-org-4.0.repo
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
EOF
	# 安装node
	sudo yum install -y curl && curl -sL https://rpm.nodesource.com/setup_8.x | sudo bash -
	# 安装构建工具，MongoDB，nodejs和graphicsmagick：
	sudo yum install -y gcc-c++ make mongodb-org nodejs
	sudo yum install -y epel-release && sudo yum install -y GraphicsMagick
	sudo npm install -g inherits n && sudo n 8.11.4	

	# 安装Rocket.Chat
	# 下载最新的Rocket.Chat版本：
	curl -L https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz
	tar -zxvf /tmp/rocket.chat.tgz -C /tmp
	# 安装
	cd /tmp/bundle/programs/server && npm install
	sudo mv /tmp/bundle /opt/Rocket.Chat	

	# 配置Rocket.Chat服务
	# 添加rocketchat用户，在Rocket.Chat文件夹上设置正确的权限，并创建Rocket.Chat服务文件：
	sudo useradd -M rocketchat && sudo usermod -L rocketchat
	sudo chown -R rocketchat:rocketchat /opt/Rocket.Chat

cat << EOF |sudo tee -a /lib/systemd/system/rocketchat.service
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target nginx.target mongod.target
[Service]
ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=rocketchat
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat?replicaSet=rs01 MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=rs01 ROOT_URL=http://localhost:3000/ PORT=3000
[Install]
WantedBy=multi-user.target
EOF

	# 为MongoDB设置存储引擎和复制（对于版本>1是强制的），并启用并启动MongoDB和Rocket.Chat：

	sudo sed -i "s/^#  engine:/  engine: mmapv1/"  /etc/mongod.conf
	sudo sed -i "s/^#replication:/replication:\n  replSetName: rs01/" /etc/mongod.conf
	sudo systemctl enable mongod && sudo systemctl start mongod
	mongo --eval "printjson(rs.initiate())"
	sudo systemctl enable rocketchat && sudo systemctl start rocketchat
	
	# 配置您的Rocket.Chat服务器
	# 打开Web浏览器并访问配置的ROOT_URL（http://your-host-name.com-as-accessed-from-internet:3000），按照配置步骤设置管理员帐户以及组织和服务器信息。
}

rocketchat_install
