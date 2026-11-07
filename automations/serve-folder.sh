#!/bin/zsh
# @pls.description: Serve a folder over HTTP on a local port, to preview a website or share files, until Ctrl-C
# @pls.param folder: path = . -- The folder to serve
# @pls.param port: int(1024...65535) = 8000 -- The port to serve on
# @pls.param share: bool = false -- true only when the request asks to share on the network; otherwise this Mac only
# @pls.example: serve this folder
# @pls.example: start a web server for ~/Sites/blog on port 3000
# @pls.example: preview this site locally
# @pls.example: share this folder with my phone over wifi

if [[ ! -d $PLS_FOLDER ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi
if lsof -ti tcp:"$PLS_PORT" -sTCP:LISTEN >/dev/null; then
  echo "Port $PLS_PORT is in use; pick another, or free it with kill-port." >&2
  exit 1
fi

if [[ $PLS_SHARE == true ]]; then
  bind=0.0.0.0
  interface=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
  address=$([[ -n $interface ]] && ipconfig getifaddr "$interface")
  echo "Serving ${PLS_FOLDER:A} at http://localhost:$PLS_PORT and, on this network, http://${address:-<this Mac>}:$PLS_PORT"
else
  bind=127.0.0.1
  echo "Serving ${PLS_FOLDER:A} at http://localhost:$PLS_PORT (this Mac only)"
fi
echo "Press Ctrl-C to stop."
exec python3 -I -m http.server --bind "$bind" --directory "$PLS_FOLDER" "$PLS_PORT"
