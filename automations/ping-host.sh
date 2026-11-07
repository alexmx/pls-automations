#!/bin/zsh
# @pls.description: Check whether a host or website is reachable and how fast it answers
# @pls.param host: string = apple.com -- A website or IP address the request names; otherwise apple.com, to test the connection
# @pls.param count: int(1...20) = 4 -- How many pings to send
# @pls.example: ping google.com
# @pls.example: is github reachable?
# @pls.example: can I reach 192.168.1.1
# @pls.example: is the internet down?

host=$PLS_HOST
# "github" means github.com; a name with no dot (other than localhost) can't be a website otherwise.
[[ $host != *.* && $host != localhost ]] && host=$host.com

output=$(ping -c "$PLS_COUNT" -t $(( PLS_COUNT + 3 )) "$host" 2>&1)
received=$(print -r -- "$output" | awk '/packets transmitted/ {print $4}')
if [[ -z $received ]]; then
  # No summary: the name didn't resolve, or ping refused the address.
  echo "Can't ping $host: $(print -r -- "$output" | tail -1 | sed 's/^ping: //')" >&2
  exit 1
fi
if (( received == 0 )); then
  echo "$host didn't answer."
  exit 1
fi
average=$(print -r -- "$output" | awk -F'/' '/round-trip/ {printf "%.0f", $5}')
echo "$host is reachable: $received/$PLS_COUNT replies, $average ms average."
