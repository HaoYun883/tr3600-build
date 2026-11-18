#!/bin/sh
# 用法: pw-sub-swap.sh <订阅URL> [配置名]
URL="$1"; NAME="${2:-sub}"
[ -z "$URL" ] && { echo "usage: $0 <url> [name]"; exit 1; }
TS=$(date +%Y%m%d-%H%M%S); B="/root/sub-backup-$TS"; mkdir -p "$B"
cp /etc/config/openclash "$B/" 2>/dev/null
cp /etc/openclash/config/*.yaml "$B/" 2>/dev/null
cp /etc/openclash/*.yaml "$B/" 2>/dev/null
echo "backup: $B"
TMP=/tmp/newsub.yaml
curl -s -m 60 -H 'User-Agent: clash.meta' -o "$TMP" "$URL" || { echo "download failed"; exit 1; }
grep -q '^proxies:' "$TMP" || { echo "not a clash yaml"; exit 1; }
/etc/openclash/core/clash_meta -t -d /etc/openclash -f "$TMP" >/tmp/subtest.log 2>&1 || { echo "invalid config:"; tail -5 /tmp/subtest.log; exit 1; }
DEST="/etc/openclash/config/$NAME.yaml"
cp "$TMP" "$DEST"
rm -f "/etc/openclash/$NAME.yaml"
uci set openclash.config.config_path="$DEST"; uci commit openclash
/etc/init.d/openclash restart >/tmp/swap-restart.log 2>&1
sleep 25
IP=$(curl -s -m 8 https://www.cloudflare.com/cdn-cgi/trace | sed -n 's/^ip=//p')
if [ -n "$IP" ]; then
  echo "OK egress=$IP"; echo "nodes=$(grep -c 'name:' "$DEST")"
else
  echo "FAILED, rolling back"
  cp "$B/openclash" /etc/config/openclash 2>/dev/null
  cp "$B"/*.yaml /etc/openclash/config/ 2>/dev/null
  /etc/init.d/openclash restart >/dev/null 2>&1
  exit 1
fi
