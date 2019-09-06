#!/bin/bash
# 2019-08-25
# 源码编译安装 mysql5.7
# 参考：https://blog.csdn.net/zhang_referee/article/details/88212695

function install_mysql57(){
	# 更新源
	yum install -y epel-release
	# 安装依赖包
	yum install -y  gcc gcc-c++ cmake ncurses ncurses-devel bison
	# axel：多线程下载工具，下载文件时可以替代curl、wget。（人家分享的命令，试试看好不好用）
	yum install -y axel
	# axel -n 20 下载链接
	cd /usr/local/src
	# 好像有个bug，如果文件遇到特许情况没有下载完成，文件名还是存在的，所以它不会继续下载
	# wget -c 应该可以解决（-c 断点续传）
	# wget -c https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.25.tar.gz
	[ ! -f mysql-boost-5.7.25.tar.gz ] && axel -n 20 https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.25.tar.gz
	# 添加用户
	useradd -s /sbin/nologin mysql
	# 建立所需目录并更改所有者为mysql
	mkdir -p /data/mysql/data
	chown -R mysql:mysql /data/mysql
	# 将下载好的mysql 解压到/usr/local/mysql 目录下
	mkdir -p /usr/local/mysql/
	tar -zxvf mysql-boost-5.7.25.tar.gz -C /usr/local/mysql/
	# 编译安装
	cd /usr/local/mysql/mysql-5.7.25/
	# cmake安装MySQL默认安装在/usr/local/mysql，如果要指定目录需要加参数：-DCMAKE_INSTALL_PREFIX=
	cmake -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_BOOST=boost
	make -j 2 && make install
# 配置文件
cat > /etc/my.cnf << \EOF
[client]
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
user = mysql

basedir = /usr/local/mysql
datadir = /data/mysql/data
pid-file = /data/mysql/mysql.pid

log_error = /data/mysql/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /data/mysql/mysql-slow.log

skip-external-locking
key_buffer_size = 32M
max_allowed_packet = 1024M
table_open_cache = 128
sort_buffer_size = 768K
net_buffer_length = 8K
read_buffer_size = 768K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 16
query_cache_size = 16M
tmp_table_size = 32M
performance_schema_max_table_instances = 1000

explicit_defaults_for_timestamp = true
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log_bin=mysql-bin
binlog_format=mixed
server_id   = 232
expire_logs_days = 10
early-plugin-load = ""

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_buffer_pool_size = 128M
innodb_log_file_size = 32M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 32M
sort_buffer_size = 768K
read_buffer = 2M
write_buffer = 2M

EOF

	# 修改文件目录属主属组
	chown -R mysql:mysql /usr/local/mysql
	# 初始化mysql
	cd /usr/local/mysql/bin
	./mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql/data
	# 拷贝可执行配置文件
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	# 启动MySQL
	service mysqld start
	# 软连接
	ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
	# 设置开机自启动
	systemctl enable mysqld	

	# 修改密码
	mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123';"
	echo -e "\033[31mMySQL的初始密码为：123\033[0m"

	# 授权远程登录
	# GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123' WITH GRANT OPTION;
	# mysql -uroot -p123 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123' WITH GRANT OPTION;"
	# FLUSH PRIVILEGES;
	# mysql -uroot -p123 -e "FLUSH PRIVILEGES;"
}

install_mysql57

# 脚本运行不一定能成功，不喜勿喷！