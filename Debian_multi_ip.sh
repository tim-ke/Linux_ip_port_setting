#!/bin/bash 
ip_general[0]=206.119.111.14
ip_general[1]=206.119.111.15 
ip_general[2]=206.119.111.16 

netmask=255.255.255.0 
gateway=206.119.111.1
dns=8.8.8.8 
network_name=eno1

#--------------
network_place=/etc/network/interfaces 
len_ip=${#ip_general[@]} 

echo "auto lo 
iface lo inet loopback 

auto "$network_name" 
iface "$network_name" inet static 
    address "${ip_general[0]}" 
    netmask "$netmask" 
    gateway "$gateway" 
" > $network_place 

for ((i=1;i<$len_ip;i++)); 
do 
echo " 
auto "$network_name":$i 
iface "$network_name":$i inet static 
    address "${ip_general[$i]}" 
    netmask "$netmask" 
" >> $network_place 
done

#set-dns
echo "nameserver "$dns"" > /etc/resolv.conf

#modify ssh port 14004 
sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config 
sed -ri 's/^#?Port\s+.*/Port 14004/' /etc/ssh/sshd_config

#restart
/etc/init.d/networking restart
systemctl restart sshd

#close Ping
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all  

#show
ip a |grep "inet*"
ss -plunt
