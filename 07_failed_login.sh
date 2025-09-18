#!/usr/bin/env bash
set -euo pipefail

# ANSI colors
RED="\e[1;31m"
CYAN="\e[1;36m"
NONE="\e[0m"

# Get timestamp of last successful login (excluding reboots and SSH key auth)
last_login=$(last -F "$USER" | grep -m1 'logged in' | sed 's/ still logged in.*//' | awk '{print $5, $6, $7, $8, $9}')

if [[ -z "$last_login" ]]; then
    echo -e "${CYAN}No previous login found.${NONE}"
    exit 0
fi

echo -e "${CYAN}Last login:${NONE} $last_login"

# Convert to timestamp
since=$(date -d "$last_login" +"%Y-%m-%d %H:%M:%S")

echo -e "${CYAN}Failed login attempts since last login:${NONE}"

# Try journalctl first (systemd-based systems)
if command -v journalctl &> /dev/null; then
    journalctl --since "$since" _COMM=sshd | grep -i "Failed password" || echo -e "${RED}No failed attempts found.${NONE}"
else
    # Fallback to /var/log/auth.log (Debian/Ubuntu) or /var/log/secure (RHEL/CentOS)
    log_file=""
    if [[ -f /var/log/auth.log ]]; then
        log_file="/var/log/auth.log"
    elif [[ -f /var/log/secure ]]; then
        log_file="/var/log/secure"
    fi

    if [[ -n "$log_file" ]]; then
        awk -v since="$since" '
            BEGIN { split(since, d, "[- :]"); ts = mktime(d[1]" "d[2]" "d[3]" "d[4]" "d[5]" "d[6]) }
            {
                split($0, a, " ");
                log_ts = mktime(strftime("%Y ") a[1]" "a[2]" "a[3]" "a[4]" "a[5]" "a[6]);
                if (log_ts >= ts && /Failed password/) print $0;
            }
        ' "$log_file" || echo -e "${RED}No failed attempts found.${NONE}"
    else
        echo -e "${RED}No log source found for failed login attempts.${NONE}"
    fi
fi

echo
echo -e "\e[1;33m##################################################\e[m"
echo
