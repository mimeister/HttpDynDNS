#!/bin/bash

interface_name="" # i.e. 'eth0'
cache_file="/tmp/dyndns_cached_ip"
update_url_template="http://yourupdateservice.com/&myip=<ip6addr>"
username=""
password=""


# Get the current global IPv6 address
current_ipv6=$(ip -f inet6 address show scope global -deprecated $interface_name |  grep -oP '(?<=inet6 )[0-9a-fA-F:]+')

if [ -z "$current_ipv6" ]; then
    echo "Failed to retrieve the current global IPv6 address."
    exit 1
fi


# Check if the cache file exists
if [ -e "$cache_file" ]; then
    cached_ipv6=$(cat "$cache_file" | tr -d '[:space:]')
    if [ "$current_ipv6" == "$cached_ipv6" ]; then
        exit 0 # address unchanged. early exit.
    fi
fi

# Construct the actual update url using the new ip
update_url="${update_url_template//<ip6addr>/$current_ipv6}"

# Make the call to the update api
if command -v curl &> /dev/null; then
    # Use curl if available
    response=$(curl -sS -u "${username}:${password}" -w "%{http_code}" "$update_url")
else
    # Use wget as an alternative
    response=$(wget --user="${username}" --password="${password}" -q -O - "$update_url" --server-response 2>&1 | awk '/^  HTTP/{print $2}')
fi

http_status=$(echo "$response" | tail -n 1)

if [ "$http_status" == "200" ]; then
    # Create/overwrite the cache file
    echo "$current_ipv6" > "$cache_file"
    echo "Update request successful with new IPv6 address $current_ipv6."
else
    echo "Update request failed with status code $http_status."
    exit 1
fi

exit 0
