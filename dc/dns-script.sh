#!/bin/bash

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
echo $ip


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

echo $prefix
