#!/bin/bash   
ip_range[0]=154.23.142.1  
ip_range[1]=154.23.143.1 
ip_range[2]=154.23.144.1   
ip_range[3]=154.23.145.1  
ip_range[4]=154.23.146.1   
ip_range[5]=154.23.147.1  
ip_range[6]=154.23.148.1  
ip_range[7]=154.23.149.1 
   
ip_master=154.23.142.2 
netmask=255.255.255.224 
gateway=154.23.142.1 
dns=8.8.8.8 
network_name=eno1  
num=1

#--------------  
network_place=/etc/network/interfaces  
echo "auto lo   
iface lo inet loopback  

auto "$network_name"  
iface "$network_name" inet static   
    address "$ip_master"   
    netmask "$netmask"   
    gateway "$gateway"" > $network_place   
for ((i=0;i<8;i++));   
do   
  ip_list=(`echo ${ip_range[$i]} |tr "." " "`)  
  for ((j=1;j<30;j++));  
  do  
  if [[ $i == 0 && $j == 1 ]] 
  then  
  continue 
  fi  
echo "   
auto "$network_name":$num   
iface "$network_name":$num inet static   
    address "${ip_list[0]}.${ip_list[1]}.${ip_list[2]}.$((${ip_list[3]}+$j))"   
    netmask "$netmask"" >> $network_place   
let "num++"  
done  
done

#set-dns  
echo "nameserver "$dns"" > /etc/resolv.conf

#modify ssh port 14004   
sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config   
sed -ri 's/^#?Port\s+.*/Port 14004/' /etc/ssh/sshd_config

#close mount CD-ISO 
sed -ri 's/deb cdrom:/#&/' /etc/apt/sources.list  

#restart  
/etc/init.d/networking restart  
systemctl restart sshd

#close Ping  
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all  

#show  
ip a |grep "inet*"  
ss -plunt
