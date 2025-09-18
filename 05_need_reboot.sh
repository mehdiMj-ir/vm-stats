#!/usr/bin/env bash

LIGHT_RED="\e[1;31m"
NONE="\e[m"
LIGHT_GREEN="\e[1;32m"

REBOOT_FLAG="/var/run/reboot-required"

# Check if reboot-required file exists
if [ -e "$REBOOT_FLAG" ]; then
    printf "%bPending kernel upgrade!%b You should consider rebooting your machine.\n\n" "$LIGHT_RED" "$NONE"
else
    printf "%bNo pending updates.%b\n" "$LIGHT_GREEN" "$NONE"
fi

echo
echo -e "\e[1;33m##################################################\e[m"
echo
