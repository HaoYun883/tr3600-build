#!/bin/sh
# 在 OpenClash 与 PassWall 之间切换运行时，失败自动回滚
# 用法: runtime-switch.sh openclash|passwall
T="$1"
case "$T" in
	openclash|passwall) ;;
	*) echo "usage: $0 openclash|passwall"; exit 1 ;;
esac

LOG=/root/runtime-switch-$(date +%H%M%S).log
echo "== before" | tee -a "$LOG"
/etc/init.d/passwall enabled 2>/dev/null && echo "passwall_boot=on" | tee -a "$LOG" || echo "passwall_boot=off" | tee -a "$LOG"
/etc/init.d/openclash enabled 2>/dev/null && echo "oc_boot=on" | tee -a "$LOG" || echo "oc_boot=off" | tee -a "$LOG"

test_net() {
	i=0
	while [ $i -lt 3 ]; do
		ip=$(curl -s -m 8 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | sed -n 's/^ip=//p')
		[ -n "$ip" ] && { echo "$ip"; return 0; }
		i=$((i+1)); sleep 5
	done
	return 1
}

if [ "$T" = "openclash" ]; then
	/etc/init.d/passwall stop
	/etc/init.d/passwall disable
	uci set openclash.config.enable='1'
	uci commit openclash
	/etc/init.d/openclash start
else
	/etc/init.d/openclash stop 2>/dev/null
	/etc/init.d/openclash disable
	/etc/init.d/passwall start
	/etc/init.d/passwall enable
fi

echo "waiting for egress..." | tee -a "$LOG"
sleep 20
IP=$(test_net)
if [ -n "$IP" ]; then
	echo "OK runtime=$T egress=$IP" | tee -a "$LOG"
	exit 0
fi

echo "FAILED: no egress, rolling back" | tee -a "$LOG"
if [ "$T" = "openclash" ]; then
	/etc/init.d/openclash disable
	/etc/init.d/passwall enable
	/etc/init.d/passwall start
else
	/etc/init.d/passwall disable
	uci set openclash.config.enable='1'
	uci commit openclash
	/etc/init.d/openclash start
fi
exit 1
