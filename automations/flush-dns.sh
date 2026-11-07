#!/bin/zsh
# @pls.name: Flush DNS
# @pls.description: Clear the DNS cache, for when websites won't load or still point to their old address
# @pls.example: flush dns
# @pls.example: a site isn't loading after I changed its DNS
# @pls.example: clear the dns cache

# Needs sudo, so it asks for your password unless sudo remembers it.
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS cache cleared."
