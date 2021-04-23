#!/bin/bash -e

interface=$1
event=$2

echo "$interface received $event" | systemd-cat -p info -t dispatch_script

if [[ $interface != "eth0" ]] && ( [[ $event != "up" ]] || [[ $event != "dhcp6-change" ]] )
then
  echo "$interface $event"
  exit 0
fi


ip6=$(ip -o -6 addr list eth0 | awk '{print $4}' | cut -f1)
for ip in $ip6
do
    val=$(echo $ip | cut -d":" -f1)
    if [[ "$val" != "fe80" ]];
    then
        ip6=$ip
    fi
done


mask=$(echo $ip6 | cut -d/ -f2)
ip=$(echo $ip6 | cut -d/ -f1)
echo $mask
#echo $ip

ip=$(sipcalc $ip | fgrep Expanded | cut -d '-' -f 2)
#echo $ip

sudo touch -f "/etc/dnsmasq.d/dnsmasq-ipv6.more.conf"
echo "listen-address=$ip" | sudo tee "/etc/dnsmasq.d/dnsmasq-ipv6.more.conf" > "/dev/null"

prefix_len=0

IFS=':' read -ra part <<< "$ip"
for i in "${part[@]}"; do
    prefix+=$i
    prefix+=":"
    prefix_len=$((prefix_len + 16))
    if (($prefix_len >= $mask)); then
        break 
    fi
done

#echo $prefix

prefix=$(echo $prefix | rev | cut -c 4- | rev )
#echo $prefix
sudo touch -f "/etc/hosts.ipv6"
echo "# IPv6 <host, IP> map " | sudo tee "/etc/hosts.ipv6" > "/dev/null"
while IFS= read -r line; do
    echo  "$prefix$line" | sudo tee -a "/etc/hosts.ipv6" > "/dev/null"
done < "/etc/dnsmasq.d/EUI64-ips"