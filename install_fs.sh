#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#安装地址勿做修改
install_path=/fs/


# Root 权限
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}


#检测系统
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS='centos'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='ubuntu'
    else
        echo "Not support OS, Please reinstall OS and retry! Centos debian and ubuntu are acceptable!"
        exit 1
    fi
}


#安装环境
function checkenv(){
		if [[ $OS = "centos" ]]; then
			yum install epel-release -y
			yum -y install libpcap
			yum -y install iptables
			yum install -y java
		else
			apt-get update
			apt-get -y install libpcap-dev
			apt-get -y install iptables
			apt-get install -y openjdk-7-jre			
		fi
}
 
 
#  Install finalspeed
function install_finalspeed(){
	rootness
	checkos
	checkenv
	mkdir -p $install_path
	echo '' > ${install_path}"server.log"
	wget --no-check-certificate https://raw.githubusercontent.com/yu19930123/fs/master/fs1.2_server/fs.jar -O ${install_path}"fs.jar"
    if [ "$OS" == 'centos' ]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/yu19930123/fs/master/finalspeed -O /etc/init.d/finalspeed; then
			echo "Failed to download finalspeed chkconfig file!"
			exit 1
		fi
		chmod +x /etc/init.d/finalspeed
		chkconfig --add finalspeed
		chkconfig finalspeed on	  
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/yu19930123/fs/master/finalspeed-debian -O /etc/init.d/finalspeed; then
			echo "Failed to download finalspeed chkconfig file!"
			exit 1
		fi
		chmod +x /etc/init.d/finalspeed
		update-rc.d -f finalspeed defaults
    fi
	/etc/init.d/finalspeed start	
}

# Uninstall finalspeed
function uninstall_finalspeed(){
    printf "Are you sure uninstall finalspeed? (y/n) "
    printf "\n"
    read -p "(Default: n):" answer
    if [ -z $answer ]; then
        answer="n"
    fi
    if [ "$answer" = "y" ]; then
        /etc/init.d/finalspeed stop
        checkos
        if [ "$OS" == 'centos' ]; then
            chkconfig --del finalspeed
        else
            update-rc.d -f finalspeed remove
        fi
        rm -f /etc/init.d/finalspeed
        rm -rf $install_path
        echo "finalspeed uninstall success!"
    else
        echo "uninstall cancelled, Nothing to do"
    fi
}

# Initialization step
action=$1
case "$action" in
uninstall)
    uninstall_finalspeed
    ;;
*)
    install_finalspeed
   echo "参数uninstall可以卸载finalspeed"
    ;;
esac



