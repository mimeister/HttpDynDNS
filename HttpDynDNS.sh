#!/bin/bash

interface_name="" # i.e. 'eth0'
cache_file="/tmp/dyndns_cached_ip"
update_url_template="http://yourupdateservice.com/&myip=<ip6addr>"
username=""
password=""


# Get the current global IPv6 address
current_ipv6=$(ip -f inet6 address show scope global $interface_name | grep -oE '\b[0-9a-fA-F:]+\b')

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

# Construct the actual update url using the 
update_url="${update_url_template//<ip6addr>/$current_ipv6}"

# Make the call to the update api
if command -v curl &> /dev/null; then
    # Use curl if available
    curl -sS --user "${username}:${password}" "$modified_url" >/dev/null
    status=$?
else
    # Use wget as an alternative
    wget --user="${username}" --password="${password}" -q -O - "$modified_url" >/dev/null
    status=$?
fi

if [ $status -eq 0 ]; then
    # Create/overwrite the cache file
    echo "$current_ipv6" > "$cache_file"
    echo "Update request successful with new IPv6 address $current_ipv6."
else
    echo "Update request failed with status code $status."
    exit 1
fi

exit 0
