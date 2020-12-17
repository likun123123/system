#!/bin/bash
#2020-07-14
#system	系统管理工具
#编: 微微坤
####################
#时间
date
menu() {
cat <<-EOF
==================================
           系统管理工具          |
            ID:微微坤            |
        h  显示命令帮助          |
--------------网络---------------|
        w  网卡信息收集          |               ************************************************
        b  网卡绑定信息          |               ************************************************
-----------系统硬软件------------|               ****               ********                *****
        r  系统版本信息          |               ****   *********    *******   ******************
        c  cpu信息               |               ****   **********   *******   ******************
        t  top信息收集           |               ****   **********   *******   ******************
        u  系统负载              |               ****   **********   *******   ******************
        n  列出内核加载的模块    |               ****   *********   ********                *****
--------------磁盘---------------|               ****              *********   ******************
        f  磁盘分区              |               ****   ****   *************   ******************
        d  显示磁盘挂载          |               ****   ******   ***********   ******************
        m  磁盘内存使用量        |               ****   ********   *********   ******************
------------系统任务-------------|               ****   **********   *******   ******************
        o  计划任务表            |               ****   ************   *****   ******************
------------虚拟LVM--------------|               ************************************************
        l  lvm分区信息           |               ************************************************
        s  系统分区树形展示      |
--------------环境---------------|
        v  环境变量              |
        up 查看服务启动状态      |
       （up完，脚本不再运行）    |
---------------------------------|
        net 查看指定端口的连接数 |
---------------------------------|
        an 安装软件（YUM）       |
---------------------------------|
        q  直接退出exit          |
==================================
EOF
}

install(){ 
read -p "请输入要安装的软件包名 [例:vsftpd]" bao
	yum=`yum repolist |grep x86 |awk '{print $8}'`
	echo "$yum" >/dev/null
	if [ $? -eq 0 ];then
        	echo "yum is ok....."
	else
		echo "yum is error....."
	fi
	if [ $UID -ne 0 ];then
	        echo "error perm...."
        	exit 1
	fi
		echo "Please wait....."
yum -y install $bao &>/dev/null
if [ $? -eq 0 ];then
        echo "$bao is ok...."
else
	echo "$bao is no install...."
fi

}
net(){
	read -p "请输入要查询的端口号 [例: 80]" net
	declare -A state
	
	states=`ss -an |grep :$net |awk '{print $2}'`

	for i in $states
	do
	        let state[$i]++
	done
	
	for j in ${!state[@]}
	do
	        echo "$j: ${state[$j]}"
	done
}

menu
while true
do
	read -p "Please input [h  显示命令帮助]:" action
	case "$action" in
	an)
		install
		;;
	up)
		systemctl list-unit-files
		;;
	net)
		net
		;;
	n)
		lsmod
		;;
	v)
		env
		;;
	w)
		ifconfig -a
		;;
	b)
		cat /proc/net/bonding/*
		;;
	r)
		uname -a
		;;
	c)
		cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
		echo "CPU核数"
		cat /proc/cpuinfo |grep "cpu cores"|uniq
		;;
	t)
		top -c -b -n 1 |head -n 30
		;;
	o)	
		crontab -l
		;;
	l)
		vgs
		pvs
		lvs #-v --segments
		;;
	s)
		lsblk
		;;
	h)
		clear
		date
		menu       #展示目录
		;;
	f)
		fdisk -l  
		;;
	d)
		df -hT
		;;
	m)
		free -m
		;;
	u)
		uptime
		;;
	q)
		exit
		;;
	"")
		true
		;;
	*)
		echo "error"	
		break
	esac
done
