#!/bin/zsh
# @pls.name: My IP
# @pls.description: Show this Mac's IP address on the local network and on the internet
# @pls.param which: enum(local|public|both) = both -- local is the address on this network; public is the one websites see
# @pls.example: what's my IP?
# @pls.example: what's my public IP address
# @pls.example: my local IP

parts=()
if [[ $PLS_WHICH != public ]]; then
  interface=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
  local_ip=$([[ -n $interface ]] && ipconfig getifaddr "$interface")
  parts+=("Local ${local_ip:-none (not connected)}")
fi
if [[ $PLS_WHICH != local ]]; then
  # A DNS lookup against OpenDNS, which answers with the address the query came from.
  public_ip=$(dig +short +time=3 +tries=1 myip.opendns.com @resolver1.opendns.com 2>/dev/null | tail -1)
  [[ $public_ip == <->.<->.<->.<-> ]] || public_ip="unknown (offline?)"
  parts+=("Public $public_ip")
fi
echo ${(j: · :)parts}
