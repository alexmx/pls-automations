#!/bin/zsh
# @pls.description: List which apps are listening on which TCP ports, without stopping anything
# @pls.param port: int(0...65535) = 0 -- A port the request names, to show only that one; 0 shows every port
# @pls.example: what's using port 5432?
# @pls.example: which ports are open?
# @pls.example: what's listening on 3000

# Your own processes only; system services would need sudo. lsof's -F output gives one field per line: p<pid>,
# c<full app name>, n<address> such as "*:3000" or "[::1]:5432", where the port follows the last colon.
rows=$(lsof -iTCP -sTCP:LISTEN -n -P +c 0 -F pcn 2>/dev/null | awk '
  /^p/ { pid = substr($0, 2) }
  /^c/ { app = substr($0, 2) }
  /^n/ { port = $0; sub(/.*:/, "", port); print port "\t" app "\t" pid }
' | sort -n -u)

if (( PLS_PORT != 0 )); then
  rows=$(print -r -- "$rows" | awk -F '\t' -v port="$PLS_PORT" '$1 == port')
  [[ -z $rows ]] && { echo "Nothing of yours is listening on port $PLS_PORT."; exit 0; }
fi
[[ -z $rows ]] && { echo "Nothing of yours is listening on any port."; exit 0; }

{ print "PORT\tAPP\tPID"; print -r -- "$rows"; } | column -t -s $'\t'
