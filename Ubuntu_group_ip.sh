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
network_place=`find /etc/netplan -iname "0*" |sort |head -n 1` 
netmask_prefix=27 
gateway=154.23.142.1 
dns=8.8.8.8 
network_name=eno1 
nameserver=1.1.1.1

#-------------- 
ip_toto=$ip_master/$netmask_prefix 
for ((i=0;i<8;i++)); 
do 
  ip_list=(`echo ${ip_range[$i]} |tr "." " "`) 
  for ((j=1;j<30;j++)); 
  do       
   if [[ $i == 0 && $j == 1 ]] 
   then    
   continue 
   fi    
    ip_toto+=,${ip_list[0]}.${ip_list[1]}.${ip_list[2]}.$((${ip_list[3]}+$j))/$netmask_prefix; 
  done        
done  

echo "network:  
  ethernets:  
    $network_name:  
      addresses: [ $ip_toto ] 
      gateway4: $gateway  
      nameservers:  
       search: [ $dns ]  
       addresses: [ $nameserver ]  
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
sleep 2
ip a |grep "inet*" 
ss -plunt
