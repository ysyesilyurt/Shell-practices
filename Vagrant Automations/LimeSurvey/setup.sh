#!/bin/bash

# bash script for automating LimeSurvey installations
# (with all its dependencies Apache/nginx,PHP,MySQL) and configurations 

parent_dir=/var/www

if ! [ -d "${parent_dir}" ]; then
        mkdir "${parent_dir}"
fi

echo "Installing nginx..."
	
	# adding the CentOS 7 EPEL repository
	yum -y install epel-release > /dev/null
	# installing nginx
	yum -y install nginx > /dev/null
	firewall-cmd --add-port=80/tcp --permanent > /dev/null
	firewall-cmd --add-port=443/tcp --permanent > /dev/null
	firewall-cmd --reload > /dev/null
	systemctl start nginx 
 	systemctl enable nginx > /dev/null

echo "Installing latest required PHP packages from IUS repository..."
	
	# Downloading IUS repository installation script
	curl -s 'https://setup.ius.io/' -o setup-ius.sh
	# Installing IUS repository with script
	bash setup-ius.sh > /dev/null
	yum -y install php70u-json mod_php70u php70u-cli php70u-mysqlnd php70u-gd php70u-xml php70u-mbstring > /dev/null
	systemctl restart nginx 
	rm -f setup-ius.sh 

echo "Installing MySQL from Percona MySQL server..." 
	
	# Adding Percona MySQL server repository
	yum -y install https://www.percona.com/redir/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm > /dev/null  
	yum -y install Percona-Server-server-57 Percona-Server-client-57 Percona-Server-devel-57 > /dev/null
	yum -y update > /dev/null
	systemctl start mysqld 
	systemctl enable mysqld 

	# Getting the temporary root password that is predefined
	# on default to run "mysql_secure_installation" script
	A=$(grep "temporary password" /var/log/mysqld.log)
	B=$(echo "${A}" | awk '{print $NF}')

	# Installing expect for automating user prompts 
	yum install -y expect > /dev/null

	# MySQL Password goes here
	MYSQL_ROOT_PASSWORD="P@ssw0rd"

	# Executing "mysql_secure_installation" script with expect
	# to change password and configurations
	MYSQL_INS_OUTPUT=$(expect -c "
	set timeout -1
	spawn mysql_secure_installation

	expect \"Enter password for user root:\"
	send \"$B\r\"

	expect \"New password:\"
	send \"${MYSQL_ROOT_PASSWORD}\r\"

	expect \"Re-enter new password:\"
	send \"${MYSQL_ROOT_PASSWORD}\r\"

	expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) :\"
	send \"y\r\"

	expect \"New password:\"
	send \"${MYSQL_ROOT_PASSWORD}\r\"

	expect \"Re-enter new password:\"
	send \"${MYSQL_ROOT_PASSWORD}\r\"

	expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :\"
	send \"y\r\"

	expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
	send \"y\r\"

	expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
	send \"n\r\"

	expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
	send \"y\r\"

	expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
	send \"y\r\"
	expect eof
	")

	# Creating ".my.cnf" to make MySQL not to prompt user to enter password on each use 
	echo -e "[client]\nuser=root\nhost=localhost\npassword='P@ssw0rd'" > /root/.my.cnf
	# Ensuring that this file can only be seen by root user
	chmod 0600 /root/.my.cnf
	# Adding MySQL configurations on "mysql_settings"
	# to "/etc/my.cnf"
	sed -i '/Systemd/r /vagrant/mysql_settings' /etc/my.cnf
	# A "slow.log" file needs to be created manually at first to log 'slow' logs 
	touch /var/log/mysqld-slow.log
	chown -R mysql:mysql /var/log/mysqld-slow.log
	# Configuration for slow logs on logrotate
	cat /vagrant/mysql_logrotate_conf >> /etc/logrotate.d/mysql

echo "Installing LimeSurvey..." 

	# Disabling Selinux
	setenforce 0
	sed -i -e "s/SELINUX=enforcing.*/SELINUX=disabled/g" /etc/sysconfig/selinux

	# Creating database and user with mysql for Matomo
	Q1="CREATE DATABASE ${1} CHARACTER SET utf8 COLLATE utf8_general_ci;"
	Q2="CREATE USER '${1}'@'localhost' identified by 'P@ssw0rd';"
	Q3="GRANT ALL PRIVILEGES ON ${1}.* to '${1}'@'localhost';"
	Q4="FLUSH PRIVILEGES;"
	SQL="${Q1}${Q2}${Q3}${Q4}"

	mysql -e "$SQL"

	# Getting the version of the latest release
	latest_release=$(curl https://www.limesurvey.org/stable-release | grep -o 'limesurvey.*.tar.gz')
	# Downloading and unzipping latest release
	cd ${parent_dir} && wget https://download.limesurvey.org/latest-stable-release/$latest_release -q
	tar xzf $latest_release && rm -rf $latest_release

	# Installing php-fpm additional php package 
	yum -y install php70u-fpm > /dev/null
	# Configuring php-fpm pool settings correctly
	rm -rf /etc/php-fpm.d/www.conf && cp /vagrant/www.conf /etc/php-fpm.d/

	# Authorizing 'nginx' user for limesurvey/
	chown -R nginx:nginx ${parent_dir}/limesurvey 

	# Virtualhost Definition for nginx
	cat /vagrant/vhosts_defs > /etc/nginx/conf.d/limesurvey.conf
	sed -i -e 's/change/'"$site_name.com"'/g' /etc/nginx/conf.d/limesurvey.conf

	# Starting the services
	systemctl start php-fpm
	systemctl enable php-fpm > /dev/null
	systemctl restart nginx

	echo -e "LimeSurvey has been installed to Vagrant Virtual Machine successfully with ${1}.com name.\n\
	You can log in to your machine with 'vagrant ssh'."  
