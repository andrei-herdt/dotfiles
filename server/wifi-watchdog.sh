#!/bin/sh
# Reconnect wifi if the default gateway is unreachable (or there is no default route).
DEV=wlp0s20f3
CON=dingdong
gw=$(ip -4 route show default dev "$DEV" | awk '{print $3; exit}')
if [ -n "$gw" ] && ping -c2 -W2 "$gw" >/dev/null 2>&1; then exit 0; fi
logger -t wifi-watchdog "gateway '${gw:-none}' unreachable, reconnecting $CON"
nmcli device disconnect "$DEV" >/dev/null 2>&1
sleep 2
nmcli connection up "$CON" ifname "$DEV" || { nmcli radio wifi off; sleep 2; nmcli radio wifi on; sleep 5; nmcli connection up "$CON" ifname "$DEV"; }
