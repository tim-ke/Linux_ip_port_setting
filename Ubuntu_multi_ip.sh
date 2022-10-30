#!/bin/bash  
ip_general[0]=206.119.111.14 
ip_general[1]=206.119.111.15 
ip_general[2]=206.119.111.16

network_place=`find /etc/netplan -iname "0*" |sort |head -n 1` 
netmask_prefix=24 
gateway=206.119.111.1 
dns=8.8.8.8 
network_name=eno1 
nameserver=1.1.1.1

#-------------- 
echo "network:  
  ethernets:  
    $network_name:  
      addresses: [ "`for ((i=0;i<${#ip_general[@]};i++)); do echo ${ip_general[$i]}/$netmask_prefix; if [ $(($i+1)) '<' ${#ip_general[@]} ];then echo ','; fi; done`" ]  
      gateway4: "$gateway"  
      nameservers:  
       search: [ "$dns" ]  
       addresses: [ "$nameserver" ]  
      dhcp4: no  
  version: 2  
" > $network_place

#close Ping  
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

#modify ssh port 14004    
sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config 
sed -ri 's/^#?Port\s+.*/Port 14004/' /etc/ssh/sshd_config

#restart   
systemctl restart sshd 
netplan apply
#netplan try

#show   
ip a |grep "inet*" 
ss -plunt
