#!/usr/bin/env bash

# set column width
COLUMNS=2
# colors
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Skipping container listing..."
    containers=()
else
    # Extract container names and status
    mapfile -t containers < <( docker ps -a --format '{{.Names}}\t{{.Status}}' | awk '{ print $1, $2 }'  )
fi


out=""
for i in "${!containers[@]}"; do
    IFS=" " read -r name status <<< "${containers[i]}"
    # color green if service is active, else red
    if [[ "${status}" == "Up" ]]; then
        out+="${name}:,${green}${status,,}${undim},"
    else
        out+="${name}:,${red}${status,,}${undim},"
    fi
    # insert \n every $COLUMNS column
    if [ $(((i+1) % COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n\n"

if [[ -z "${containers}" ]]; then
    out+="no containers\n"
else
    printf "\ndocker status:\n"
    printf "$out" | column -ts $',' | sed -e 's/^/  /'
fi

echo
echo -e "\e[1;33m##################################################\e[m"
echo
