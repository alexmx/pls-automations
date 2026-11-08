#!/bin/zsh
# @pls.name: Ghostty SSH
# @pls.description: Open a new Ghostty tab connected over SSH to a host
# @pls.param host: string -- The host's name from your SSH config, or its address, optionally as user@host
# @pls.example: ssh to build-mac
# @pls.example: open a tab on staging
# @pls.example: connect to pi.local in a new tab
# @pls.example: ssh into admin@10.0.0.5

host=$PLS_HOST
# The hosts named in ~/.ssh/config, without patterns, to point out a typo.
config_hosts=(${(f)"$(awk 'tolower($1) == "host" { for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i }' \
  ~/.ssh/config 2>/dev/null)"})

# It's typed into a shell, so only what a host can be: letters, digits, . _ - and user@ (and : for IPv6).
if [[ ! $host =~ '^[A-Za-z0-9._:@-]+$' || $host == -* ]]; then
  echo "\"$host\" isn't a host name or address.${config_hosts:+ Hosts in ~/.ssh/config: ${(j:, :)config_hosts}}" >&2
  exit 1
fi

# Typed into the new tab's shell, so the tab stays open with a shell when the connection ends.
output=$(osascript - "ssh ${(q)host}" 2>&1 <<'APPLESCRIPT'
on run argv
	tell application "Ghostty"
		activate
		if (count of windows) > 0 then
			set newTab to new tab in front window
		else
			set newTab to selected tab of (new window)
		end if
		input text (item 1 of argv) & linefeed to focused terminal of newTab
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $output == *"-1708"* || $output == *"-2741"* || $output == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$output" >&2
  fi
  exit 1
fi
echo "Opened a tab running ssh $host."
if (( ${#config_hosts} )) && [[ $host != *[.:]* && -z ${config_hosts[(r)${host#*@}]} ]]; then
  echo "${host#*@} isn't in ~/.ssh/config; hosts there: ${(j:, :)config_hosts}"
fi
