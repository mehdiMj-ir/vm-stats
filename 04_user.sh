#!/usr/bin/env bash

set -euo pipefail

WHITE="\e[1;37m"
LIGHT_RED="\e[1;31m"
LIGHT_GREEN="\e[1;32m"
NONE="\e[m"

user=${USER:-$(id -un)}
hostname=${HOSTNAME:-$(hostname)}

printf "You logged as %b${user} %bon %b${hostname} %bserver.\n\n" "$LIGHT_GREEN" "$NONE" "$LIGHT_RED" "$NONE"

echo -e "${WHITE}logged in users:"
echo "  $(w|sed -e ':a;N;$!ba;s/\n/\n  /g')"

echo
echo -e "\e[1;33m##################################################\e[m"
echo
