import netifaces as ni
import ipaddress as ia

# Returns the IPv6 prefix
def getIPv6Prefix(ipv6Addr, prefixLen):
    prefix = ""
    curPrefixLen = 0
    ipv6Parts = ipv6Addr.split(":")
    for part in ipv6Parts:
        if not prefix == "": # if it's not empty
            prefix = prefix + ":"
        prefix = prefix + part
        curPrefixLen += 16
        if int(curPrefixLen) >= int(prefixLen):
            return prefix
    return prefix

ips = ni.ifaddresses('eth0')[ni.AF_INET6]
ip_addr = 0
mask = 0
for ip in ips:
    if ip['addr'][0:4] != 'fe80':
        ip_addr = ip['addr']
        mask = ip['netmask']
        mask = mask[-2:]

print(mask)
print(ip_addr)

prefix = getIPv6Prefix(ip_addr, mask)
print(prefix)
