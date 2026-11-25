#!/bin/zsh
set -eu

app_dir=${0:A:h}
url=http://127.0.0.1:8766/

is_xray_server() {
  /usr/bin/curl --noproxy 127.0.0.1 --fail --silent --max-time 2 "$url" | /usr/bin/cmp -s "$app_dir/index.html" -
}

if is_xray_server; then
  /usr/bin/open -a "Google Chrome" "$url"
  exit
fi

/usr/bin/python3 -m http.server 8766 --bind 127.0.0.1 --directory "$app_dir" &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT

for attempt in {1..30}; do
  if is_xray_server; then
    /usr/bin/open -a "Google Chrome" "$url"
    wait "$server_pid"
    exit
  fi
  kill -0 "$server_pid" 2>/dev/null || break
  sleep 0.1
done

print -u2 "无法启动透视镜。请检查本机端口 8766 是否已被其他应用占用。"
exit 1
