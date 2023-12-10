import subprocess
import re
import requests
from pathlib import Path

interface_name = '' # i.e. 'eth0'
cache_file = '/tmp/dyndns_cached_ip'
domain = 'your.domain'
update_url = 'http://yourupdateservice.com/hostname=' + domain + '&myip=<ip6addr>'

def get_global_ipv6_address(interface):
    try:
        result = subprocess.run(['ip', '-f', 'inet6', 'address', 'show', 'scope', 'global', interface], capture_output=True, text=True, check=True)
        output = result.stdout

        ipv6_match = re.search(r'(\b[0-9a-fA-F:]+\b)', output)
        if ipv6_match:
            return ipv6_match.group(0)
        else:
            return None
    except subprocess.CalledProcessError:
        return None

def read_cached_ip_address():
    try:
        with open(cache_file, 'r') as file:
            return file.read().strip()
    except FileNotFoundError:
        return None

def cache_ip_address(ipv6_address):
    with open(cache_file, 'w') as file:
        file.write(ipv6_address)

def update_ddns(new_ipv6):
    try:
        response = requests.get(update_url)
        if response.status_code == 200:
            print(f"Update successful with new IPv6 address {new_ipv6}.")
        else:
            print(f"Update request failed with status code {response.status_code}.")
    except requests.RequestException as e:
        print(f"Update request failed: {e}")


#--------------------------------------------------------------------
current_ipv6 = get_global_ipv6_address(interface_name)

if current_ipv6 is None:
    print("Failed to retrieve the current global IPv6 address.")
    return

cached_ipv6 = read_cached_ip_address(cache_file)

if cached_ipv6 is None or current_ipv6 != cached_ipv6:
    print(f"Detected a new IPv6 address: {current_ipv6}")
    cache_ip_address(new_ipv6)
    update_ddns(new_ipv6)