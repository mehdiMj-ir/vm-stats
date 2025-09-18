#!/usr/bin/env bash
set -euo pipefail

# ANSI colors
RED="\e[1;31m"
GREEN="\e[1;32m"
CYAN="\e[1;36m"
NONE="\e[0m"

# Get all non-loopback, non-virtual interfaces
real_ifaces=$(ip -o link show | awk -F': ' '!/LOOPBACK|docker|veth|br-|virbr|tun|tap/ {print $2}')

# Collect IPv4 and IPv6 addresses
ip4s=()
ip6s=()

for iface in $real_ifaces; do
    # IPv4
    while IFS= read -r ip; do
        ip4s+=("$iface: $ip")
    done < <(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)

    # IPv6
    while IFS= read -r ip; do
        ip6s+=("$iface: $ip")
    done < <(ip -6 addr show "$iface" | awk '/inet6 / && /global/ {print $2}' | cut -d/ -f1)
done

# Output IPv4
echo -e "${CYAN}OS IPv4 addresses:${NONE}"
for ip in "${ip4s[@]}"; do
    echo -e "  ${GREEN}$ip${NONE}"
done

# Output IPv6 only if any exist
if (( ${#ip6s[@]} > 0 )); then
    echo -e "${CYAN}OS IPv6 addresses:${NONE}"
    for ip in "${ip6s[@]}"; do
        echo -e "  ${GREEN}$ip${NONE}"
    done
fi

# Function to fetch public IP with timeout
get_ip() {
    local version=$1
    local label=$2
    local ip

    if ip=$(curl -${version} --silent --max-time 3 https://ip.mehdimj.ir); then
        echo -e "${CYAN}${label}:${NONE} ${GREEN}${ip}${NONE}"
    else
        echo -e "${CYAN}${label}:${NONE} ${RED}Not Available!${NONE}"
    fi
}

# Check public IPv4 and IPv6
get_ip 4 "Public IPv4"
get_ip 6 "Public IPv6"

echo
echo -e "\e[1;33m##################################################\e[m"
echo
