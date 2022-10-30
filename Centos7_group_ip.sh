#!/bin/bash

ip_range[0]=192.168.229.97
ip_range[1]=192.168.230.97
ip_range[2]=192.168.231.97
ip_range[3]=192.168.232.97
ip_range[4]=192.168.233.97
ip_range[5]=192.168.234.97
ip_range[6]=192.168.235.97
ip_range[7]=192.168.236.97

ip_master=192.168.229.98
netmask=255.255.255.224
gateway=192.168.229.97
dns=8.8.8.8

#you can put 'ifcfg*' the value replace with correct-----------
network_place=`find /etc/sysconfig/network-scripts/ -iname 'ifcfg*' |sort |head -n 1`

#---------------------------------------
#ip group use-------------
clonenum=(0 28 57 86 115 144 173 202)

#modify BOOTPROTO-----------
sed -ri '/^BOOTPROTO=/cBOOTPROTO=static' $network_place

#delete---------------
#sed -ri '/^ZONE=/d' $network_place
sed -ri '/^PREFIX=/d' $network_place

#modify & add -> IP & NETMASK & GATEWAY & DNS-------------
if [ "`cat $network_place |grep "IPADDR=*" |head -n 1`" == "" ]
then
echo 'IPADDR='$ip_master'' >> $network_place
else
sed -ri '/^IPADDR=/cIPADDR='$ip_master'' $network_place
fi

if [ "`cat $network_place |grep "NETMASK=*" |head -n 1`" == "" ]
then
echo 'NETMASK='$netmask'' >> $network_place
else
sed -ri '/^NETMASK=/cNETMASK='$netmask'' $network_place
fi

if [ "`cat $network_place |grep "GATEWAY=*" |head -n 1`" == "" ]
then
echo 'GATEWAY='$gateway'' >> $network_place
else
sed -ri '/^GATEWAY=/cGATEWAY='$gateway'' $network_place
fi

if [ "`cat $network_place |grep "DNS1=*" |head -n 1`" == "" ]
then
echo 'DNS1='$dns'' >> $network_place
else
sed -ri '/^DNS1=/cDNS1='$dns'' $network_place
fi

#modify & add -> ARPCHECK & NM_CONTROLLED & ZONE-----------
if [ "`cat $network_place |grep "ARPCHECK=*" |head -n 1`" == "" ]
then
echo 'ARPCHECK=no' >> $network_place
else
sed -ri '/^ARPCHECK=/cARPCHECK=no' $network_place
fi

if [ "`cat $network_place |grep "NM_CONTROLLED=*" |head -n 1`" == "" ]
then
echo 'NM_CONTROLLED=no' >> $network_place
else
sed -ri '/^NM_CONTROLLED=/cNM_CONTROLLED=no' $network_place
fi

if [ "`cat $network_place |grep "ZONE=*" |head -n 1`" == "" ]
then
echo 'ZONE=public' >> $network_place
else
sed -ri '/^ZONE=/cZONE=public' $network_place
fi


#loop echo ip-range----------
for ((i=0;i<8;i++));
do
  start_plus=1
  if [ $i == 0  ]
  then
  start_plus=2
  fi
  ip_list=(`echo ${ip_range[$i]} |tr "." " "`)
  ip_start=$((${ip_list[3]}+$start_plus))
  ip_end=$((${ip_list[3]}+29))
  echo \
IPADDR_START=${ip_list[0]}.${ip_list[1]}.${ip_list[2]}.$ip_start$'\n'\
IPADDR_END=${ip_list[0]}.${ip_list[1]}.${ip_list[2]}.$ip_end$'\n'\
NETMASK=$netmask$'\n'\
CLONENUM_START=${clonenum[$i]}$'\n'\
ARPCHECK=no\
 > $network_place-range$i
done

#modify ssh 
sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/^#?Port\s+.*/Port 14004/' /etc/ssh/sshd_config

#install selinux & set firewall
yum -y install policycoreutils-python
semanage port -a -t ssh_port_t -p tcp 14004
firewall-cmd --zone=public --remove-port=22/tcp 
firewall-cmd --permanent --zone=public --add-port=14004/tcp
firewall-cmd --reload 

#close Ping 
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

#restart service
systemctl restart sshd
systemctl restart network

#show ip & port
ip a |grep "inet*"
ss -plunt
