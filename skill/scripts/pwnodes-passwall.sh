#!/bin/sh
uci_get(){ uci get "passwall.$1" 2>/dev/null; }
nname(){ uci_get "$1.remarks"; }
nprov(){ case "$(uci_get "$1.group")" in nvenix) echo Nvenix ;; sushi) echo 寿司云 ;; liangxin) echo 良心云 ;; *) uci_get "$1.group" ;; esac; }
nmult(){ nn=$(nname "$1"); case "$nn" in *×*) echo "${nn##*×}" | sed 's/^\([0-9.]*\).*/\1/' ;; *) echo 1 ;; esac; }
members(){ uci_get "$1.urltest_node"; }

label(){
  case "$1" in
    "") echo "未设置" ;;
    UTFAST|UTGOOGLE|UTSTREAM|UT10X|UTDAILY) echo "$1 · 自动选优" ;;
    *) if [ -n "$(nname "$1")" ]; then echo "$(nname "$1")｜$(nprov "$1") ×$(nmult "$1")"; else echo "$1"; fi ;;
  esac
}

role_name(){ case "$1" in default) echo 日常 ;; x) echo "X / 推特" ;; google) echo Google ;; stream) echo 流媒体 ;; ai) echo AI ;; esac; }
role_groups(){ case "$1" in default) echo "UTFAST" ;; x|google) echo UTGOOGLE ;; stream) echo UTSTREAM ;; ai) if [ -n "$(members ya88bYVS)" ]; then echo ya88bYVS; fi ;; esac; }
role_field(){ case "$1" in default) echo default_node ;; x) echo XSG ;; google) echo GoogleSG ;; stream) echo Streaming ;; ai) echo AIGC ;; esac; }

hdr(){ echo "Content-Type: text/html; charset=utf-8"; echo; }

head_open(){
  cat <<HTML
<!doctype html><html lang="zh"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover,interactive-widget=resizes-content">
<meta name="theme-color" content="#0b0c0f">
<meta name="color-scheme" content="dark">
<title>TR3600$1</title>
<style>
:root{
--bg:#0b0c0f;--surface:#14161a;--surface2:#191c21;--line:rgba(255,255,255,.07);--line2:rgba(255,255,255,.13);
--text:#f3f4f6;--text2:#9aa0aa;--text3:#6b7280;--accent:#5b9dff;--accent-d:#2f6fd0;
--ok:#3ecf8e;--bad:#ff6b6b;--ease-out:cubic-bezier(.23,1,.32,1);
}
*{box-sizing:border-box;-webkit-tap-highlight-color:transparent}
html{-webkit-text-size-adjust:100%;overscroll-behavior:none;background:var(--bg)}
body{margin:0;background:var(--bg);color:var(--text);font:15px/1.45 -apple-system,BlinkMacSystemFont,"SF Pro Text","Segoe UI",sans-serif;-webkit-font-smoothing:antialiased;padding-bottom:calc(84px + env(safe-area-inset-bottom,0px))}
a{color:var(--accent);text-decoration:none;touch-action:manipulation}
h1,h2,p{margin:0}
.hd{position:sticky;top:0;z-index:10;padding-top:env(safe-area-inset-top,0px);background:rgba(11,12,15,.82);backdrop-filter:blur(20px) saturate(1.7);-webkit-backdrop-filter:blur(20px) saturate(1.7);border-bottom:1px solid var(--line)}
.hd-in{padding:14px 16px 12px}
.hd h1{font-size:21px;font-weight:600;letter-spacing:-.02em}
.hd p{margin-top:3px;color:var(--text3);font-size:12.5px}
main{padding:0 16px}
.sec{display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin:24px 0 9px}
.sec h2{font-size:12px;font-weight:600;letter-spacing:.07em;text-transform:uppercase;color:var(--text3)}
.sec span{font-size:12px;color:var(--text3);max-width:56%;text-align:right;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.card{background:var(--surface);border:1px solid var(--line);border-radius:16px;padding:14px;margin:10px 0}
.card.pad0{padding:2px 14px}
.row{display:flex;align-items:baseline;justify-content:space-between;gap:14px;padding:9px 0;border-bottom:1px solid var(--line);font-size:14.5px;min-width:0}
.row:last-child{border-bottom:0;padding-bottom:3px}
.row .k{color:var(--text2);flex:0 0 auto}
.row .v{text-align:right;color:var(--text);min-width:0;overflow-wrap:anywhere}
.mono{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:13.5px;font-variant-numeric:tabular-nums}
.dot{display:inline-block;width:7px;height:7px;border-radius:50%;background:var(--text3);margin-right:6px;vertical-align:1px}
.dot.ok{background:var(--ok);box-shadow:0 0 0 3px rgba(62,207,142,.14)}
.dot.bad{background:var(--bad);box-shadow:0 0 0 3px rgba(255,107,107,.14)}
.st{font-size:12px;color:var(--text3);font-variant-numeric:tabular-nums}
.chip{display:inline-block;padding:3px 8px;border-radius:999px;background:rgba(255,255,255,.055);border:1px solid var(--line);color:var(--text2);font-size:11px;margin:0 5px 5px 0;user-select:none;-webkit-user-select:none}
.chip.acc{color:#bcd4ff;background:rgba(91,157,255,.12);border-color:rgba(91,157,255,.22)}
.btn{display:block;width:100%;border:0;appearance:none;font-family:inherit;color:#07121f;background:var(--accent);border-radius:13px;padding:14px;margin-top:10px;font-size:15px;font-weight:600;touch-action:manipulation;user-select:none;-webkit-user-select:none;transition:transform .16s var(--ease-out),background .16s ease}
.btn:active{transform:scale(.98);background:var(--accent-d)}
.btn.ghost{background:var(--surface2);color:var(--text);border:1px solid var(--line2);font-weight:500}
.btn.ghost:active{background:#22262e}
.lr{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:13px 0;border-bottom:1px solid var(--line);color:var(--text)}
.lr:last-child{border-bottom:0}
.lr b{font-size:14.5px;font-weight:500}
.lr small{display:block;color:var(--text3);font-size:12px;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.lr svg{width:15px;height:15px;flex:0 0 auto;stroke:var(--text3);fill:none;stroke-width:1.9;stroke-linecap:round;stroke-linejoin:round}
.lr:active b{opacity:.6}
.pickrow{display:flex;align-items:center;gap:10px;padding:11px 0;border-bottom:1px solid var(--line)}
.pickrow:last-child{border-bottom:0}
.pick-main{flex:1;min-width:0;color:var(--text);display:block}
.pick-main b{display:block;font-size:14.5px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pick-main small{display:block;color:var(--text3);font-size:11.5px;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pick-main:active b{opacity:.6}
.pill{flex:0 0 auto;min-width:58px;text-align:center;padding:7px 9px;border-radius:9px;font-size:12px;font-weight:600;font-variant-numeric:tabular-nums;background:rgba(255,255,255,.055);color:var(--text2);border:1px solid var(--line);touch-action:manipulation;user-select:none;-webkit-user-select:none;transition:transform .15s var(--ease-out),background .15s ease}
.pill:active{transform:scale(.95);background:rgba(255,255,255,.1)}
.pill.ok{color:#8ff0bc;background:rgba(62,207,142,.12);border-color:rgba(62,207,142,.22)}
.pill.mid{color:#ffd79a;background:rgba(245,177,76,.12);border-color:rgba(245,177,76,.22)}
.pill.bad{color:#ffb3b3;background:rgba(255,107,107,.12);border-color:rgba(255,107,107,.22)}
.pill.auto{color:#bcd4ff;background:rgba(91,157,255,.12);border-color:rgba(91,157,255,.22)}
.ghead{display:flex;align-items:center;justify-content:space-between;gap:8px;margin:3px 0 5px}
.ghead b{font-size:14px;font-weight:600}
.ghead span{display:flex;align-items:center;gap:8px;font-size:12px;color:var(--text3);white-space:nowrap}
.ghead .chip{margin:0}
details.pools{margin-top:2px;border-top:1px solid var(--line)}
details.pools summary{list-style:none;cursor:pointer;padding:10px 0 6px;font-size:12.5px;color:var(--accent);touch-action:manipulation;user-select:none;-webkit-user-select:none}
details.pools summary::-webkit-details-marker{display:none}
details.pools summary::after{content:"›";float:right;color:var(--text3)}
details.pools[open] summary::after{content:"⌄"}
.tag{display:inline-block;margin-left:6px;padding:0 5px;border-radius:5px;background:rgba(255,255,255,.06);border:1px solid var(--line);color:var(--text3);font-size:10px;font-weight:500;vertical-align:1px}
.curmark{display:inline-block;margin-left:6px;padding:1px 6px;border-radius:6px;background:rgba(91,157,255,.16);color:#bcd4ff;font-size:10.5px;font-weight:600;vertical-align:1px}
.seg{display:flex;gap:3px;background:var(--surface2);border:1px solid var(--line);border-radius:13px;padding:3px;margin-top:10px}
.seg a{flex:1;text-align:center;padding:10px 4px;font-size:13.5px;color:var(--text2);border-radius:10px;user-select:none;-webkit-user-select:none;transition:background .15s ease,color .15s ease}
.seg a.on{background:rgba(255,255,255,.08);color:var(--text)}
.seg a:active{background:rgba(255,255,255,.05)}
.prog{height:3px;border-radius:2px;background:rgba(255,255,255,.08);overflow:hidden;margin-top:16px}
.prog i{display:block;height:100%;width:0;background:var(--accent);animation:fill 25s linear forwards}
.prog.p30 i{animation-duration:30s}
@keyframes fill{to{width:100%}}
.tabbar{position:fixed;left:0;right:0;bottom:0;z-index:20;display:flex;padding:5px 8px calc(5px + env(safe-area-inset-bottom,0px));background:rgba(11,12,15,.9);backdrop-filter:blur(20px) saturate(1.7);-webkit-backdrop-filter:blur(20px) saturate(1.7);border-top:1px solid var(--line)}
.tabbar a{flex:1;display:flex;flex-direction:column;align-items:center;gap:3px;padding:7px 0 4px;color:var(--text3);font-size:10.5px;border-radius:12px;touch-action:manipulation;user-select:none;-webkit-user-select:none;transition:color .16s ease}
.tabbar a .ic{width:22px;height:22px;stroke:currentColor;fill:none;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round;transition:transform .16s var(--ease-out)}
.tabbar a.on{color:var(--accent)}
.tabbar a:active .ic{transform:scale(.92)}
.tip{color:var(--text3);font-size:12px;line-height:1.6;margin:10px 2px 0}
.wrap{max-width:560px;margin:0 auto}
@media (prefers-reduced-motion:reduce){*{animation-duration:.01ms!important;transition-duration:.01ms!important}}
</style></head><body>
HTML
}

icon(){
  case "$1" in
    overview) printf '%s' '<svg class="ic" viewBox="0 0 24 24"><rect x="3.6" y="3.6" width="6.8" height="6.8" rx="2"/><rect x="13.6" y="3.6" width="6.8" height="6.8" rx="2"/><rect x="3.6" y="13.6" width="6.8" height="6.8" rx="2"/><rect x="13.6" y="13.6" width="6.8" height="6.8" rx="2"/></svg>' ;;
    bind) printf '%s' '<svg class="ic" viewBox="0 0 24 24"><path d="M12 3.4l8 4.3-8 4.3-8-4.3 8-4.3z"/><path d="M4 11.7l8 4.3 8-4.3"/><path d="M4 16l8 4.3 8-4.3"/></svg>' ;;
    nodes) printf '%s' '<svg class="ic" viewBox="0 0 24 24"><path d="M4 6.5h16M4 12h16M4 17.5h16"/><circle cx="7.2" cy="6.5" r="1.5" fill="currentColor" stroke="none"/><circle cx="7.2" cy="17.5" r="1.5" fill="currentColor" stroke="none"/></svg>' ;;
    settings) printf '%s' '<svg class="ic" viewBox="0 0 24 24"><path d="M4 7.2h9.4M17.4 7.2H20M4 16.8h2.6M10.6 16.8H20"/><circle cx="15.4" cy="7.2" r="2.1"/><circle cx="8.6" cy="16.8" r="2.1"/></svg>' ;;
  esac
}

chev(){ printf '%s' '<svg viewBox="0 0 24 24"><path d="M9 6l6 6-6 6"/></svg>'; }

tablink(){
  if [ "$1" = "$tab" ]; then cls=" on"; else cls=""; fi
  printf '<a class="t%s" href="/cgi-bin/pwnodes?tab=%s">%s<span>%s</span></a>' "$cls" "$1" "$(icon "$1")" "$2"
}

# ---------- query ----------
tab=""; action=""; target=""; value=""; id=""; group=""
qs="$QUERY_STRING"
while [ -n "$qs" ]; do
  case "$qs" in
    *"&"*) pair=${qs%%&*}; qs=${qs#*&} ;;
    *) pair=$qs; qs="" ;;
  esac
  k=${pair%%=*}; v=${pair#*=}
  [ "$k" = "$pair" ] && v=""
  case "$k" in
    tab) tab=$v ;; action) action=$v ;; target) target=$v ;; value) value=$v ;; id) id=$v ;; group) group=$v ;;
  esac
done

def=$(uci_get SB_SHUNT.default_node)
xnode=$(uci_get SB_SHUNT.XSG)
gnode=$(uci_get SB_SHUNT.GoogleSG)
snode=$(uci_get SB_SHUNT.Streaming)
anode=$(uci_get SB_SHUNT.AIGC)

role_cur(){ case "$1" in default) echo "$def" ;; x) echo "$xnode" ;; google) echo "$gnode" ;; stream) echo "$snode" ;; ai) echo "$anode" ;; esac; }

node_ip(){
  nf="/tmp/pw_dns_$1"
  if [ -f "$nf" ]; then
    nt=$(awk '{print $1}' "$nf" 2>/dev/null); nip=$(awk '{print $2}' "$nf" 2>/dev/null)
    if [ -n "$nip" ] && [ $(( $(date +%s) - nt )) -lt 3600 ]; then echo "$nip"; return; fi
  fi
  na=$(uci_get "$1.address")
  [ -z "$na" ] && return
  case "$na" in
    *[!0-9.]*) nip=$(nslookup "$na" 127.0.0.1 2>/dev/null | awk '/^Address: /{print $2}' | tail -1) ;;
    *) nip=$na ;;
  esac
  [ -n "$nip" ] && echo "$(date +%s) $nip" > "$nf"
  echo "$nip"
}

group_now(){
  gn2=""
  if [ "$(netstat -ltn 2>/dev/null | grep -c ':9090 ')" -gt 0 ]; then
    gn2=$(curl -s --max-time 2 "http://127.0.0.1:9090/proxies/$1" 2>/dev/null | sed -n 's/.*"now":"\([^"]*\)".*/\1/p')
  fi
  if [ -z "$gn2" ]; then
    conns=$(netstat -tn 2>/dev/null | awk '$6=="ESTABLISHED"{print $5}' | sort | uniq -c)
    best=0; bestid=""; ties=0
    for gmid in $(members "$1"); do
      mip=$(node_ip "$gmid"); [ -z "$mip" ] && continue
      mport=$(uci_get "$gmid.port"); [ -z "$mport" ] && mport=443
      mc=$(printf '%s\n' "$conns" | awk -v ep=" $mip:$mport" '$0 ~ (ep "$") {s+=$1} END{print s+0}')
      if [ "$mc" -gt "$best" ]; then best=$mc; bestid=$gmid; ties=1
      elif [ "$mc" -eq "$best" ] && [ "$mc" -gt 0 ]; then ties=$((ties+1)); fi
    done
    sf="/tmp/pw_now_$1"
    if [ -n "$bestid" ] && [ "$best" -gt 0 ]; then
      echo "$(date +%s) $bestid" > "$sf"
      gn2=$(nname "$bestid")
      [ -z "$gn2" ] && gn2=$bestid
    elif [ -f "$sf" ]; then
      st=$(awk '{print $1}' "$sf" 2>/dev/null); sid=$(awk '{print $2}' "$sf" 2>/dev/null)
      age=$(( $(date +%s) - st ))
      if [ -n "$sid" ] && [ "$age" -lt 21600 ]; then
        gn2=$(nname "$sid"); [ -z "$gn2" ] && gn2=$sid
        [ "$age" -ge 600 ] && gn2="$gn2（$((age/60)) 分钟前）"
      fi
    fi
  fi
  if [ -n "$gn2" ]; then
    for gmid in $(members "$1"); do
      if [ "$gmid" = "$gn2" ]; then gn2=$(nname "$gmid"); break; fi
    done
  fi
  printf '%s' "$gn2"
}

role_home(){
  h=""
  [ -f /root/pw-rolepool.conf ] && h=$(sed -n "s/^$1=//p" /root/pw-rolepool.conf 2>/dev/null | head -1)
  if [ -n "$h" ]; then echo "$h"; return; fi
  case "$1" in
    default) echo UTFAST ;;
    x|google) echo UTGOOGLE ;;
    stream) echo UTSTREAM ;;
    ai) if [ -n "$(members ya88bYVS)" ]; then echo ya88bYVS; fi ;;
  esac
}

set_home(){
  f=/root/pw-rolepool.conf
  { grep -v "^$1=" "$f" 2>/dev/null; echo "$1=$2"; } > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" 2>/dev/null
}

role_allowed(){
  case "$1" in
    default) echo "UTFAST UT10X UTDAILY $(members UTFAST) $(members UT10X) $(members UTDAILY)" ;;
    x|google) echo "UTGOOGLE $(members UTGOOGLE)" ;;
    stream) echo "UTSTREAM $(members UTSTREAM)" ;;
    ai) echo "ya88bYVS $(members ya88bYVS)" ;;
  esac
}

# ---------- probes ----------
pingnode(){
  pna=$(uci_get "$1.address"); pnp=$(uci_get "$1.port")
  [ -z "$pnp" ] && pnp=443
  pm=0
  if [ -n "$pna" ]; then
    ptc=$(curl -s --max-time 2 -o /dev/null -w '%{time_connect}' "http://$pna:$pnp" 2>/dev/null)
    pm=$(awk -v v="$ptc" 'BEGIN{printf "%d", (v+0)*1000}')
  fi
  echo "$(date +%s) $pm" > "/tmp/pw_ping_$1"
  echo "$pm"
}

probe_all(){
  pn=0
  for pid in "$@"; do
    pingnode "$pid" >/dev/null 2>&1 &
    pn=$((pn+1))
    [ $((pn % 8)) -eq 0 ] && wait
  done
  wait
}

raw_ms(){ pf="/tmp/pw_ping_$1"; [ -f "$pf" ] || { echo ""; return; }; awk '{print $2}' "$pf" 2>/dev/null; }
sortkey(){ ms=$(raw_ms "$1"); case "$ms" in ""|0) echo 99999 ;; *) echo "$ms" ;; esac; }
pillcls(){ ms=$1; case "$ms" in ""|0) echo "pill" ;; *) if [ "$ms" -lt 200 ]; then echo "pill ok"; elif [ "$ms" -lt 500 ]; then echo "pill mid"; else echo "pill bad"; fi ;; esac; }
pilltext(){ ms=$1; case "$ms" in "" ) echo "测" ;; 0) echo "超时" ;; *) echo "${ms}ms" ;; esac; }
fresh(){
  pf="/tmp/pw_ping_$1"; [ -f "$pf" ] || { echo ""; return; }
  ts=$(awk '{print $1}' "$pf"); a=$(( $(date +%s) - ts ))
  if [ "$a" -lt 90 ]; then echo "刚测"
  elif [ "$a" -lt 3600 ]; then echo "$((a/60)) 分钟前"
  elif [ "$a" -lt 86400 ]; then echo "$((a/3600)) 小时前"
  else echo "超过一天"; fi
}

egress(){
  ef=/tmp/pw_egress
  ea=999
  [ -f "$ef" ] && ea=$(( $(date +%s) - $(stat -c %Y "$ef" 2>/dev/null || echo 0) ))
  if [ "$ea" -gt 90 ]; then
    curl -s -x socks5h://127.0.0.1:1070 --max-time 7 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -E '^(ip|loc|colo)=' | tr '\n' ' ' > "$ef"
  fi
  cat "$ef" 2>/dev/null
}

# ---------- actions ----------
if [ "$action" = "auto" ]; then
  action=bind
  value=$(role_home "$target")
fi

if [ "$action" = "bind" ]; then
  field=$(role_field "$target")
  allowed=$(role_allowed "$target")
  ok=0
  case "$value" in
    *[!A-Za-z0-9_]*) ok=0 ;;
    *)
      case " $allowed " in *" $value "*) ok=1 ;; esac
      if [ -z "$ok" ] || [ "$ok" = "0" ]; then
        if [ -n "$(uci_get "$value.type")" ]; then
          case "$(uci_get "$value.protocol")" in _urltest|_shunt) ok=0 ;; *) ok=1 ;; esac
        fi
      fi ;;
  esac
  hdr
  if [ -n "$field" ] && [ "$ok" = "1" ]; then
    uci set "passwall.SB_SHUNT.$field=$value"
    uci commit passwall
    case "$value" in UTFAST|UTGOOGLE|UTSTREAM|UT10X|UTDAILY) set_home "$target" "$value" ;; esac
    ( /etc/init.d/passwall restart >/root/pw-web.log 2>&1 ) &
    head_open " · 切换中"
    cat <<HTML
<div class="hd"><div class="hd-in"><h1>正在切换</h1><p>$(role_name "$target") → $value</p></div></div>
<main class="wrap"><div class="prog"><i></i></div>
<p class="tip">重启代理中，约 15~25 秒后自动回到节点列表；<a href="/cgi-bin/pwnodes?tab=bind&amp;target=$target">手动返回</a>。</p></main>
<meta http-equiv="refresh" content="25;url=/cgi-bin/pwnodes?tab=bind&amp;target=$target">
HTML
    echo '</body></html>'
  else
    head_open " · 参数无效"
    cat <<HTML
<div class="hd"><div class="hd-in"><h1>参数无效</h1><p>目标或节点不在允许范围内</p></div></div>
<main class="wrap"><a class="btn ghost" href="/cgi-bin/pwnodes?tab=bind" style="text-align:center;text-decoration:none;margin-top:18px">返回</a></main>
HTML
    echo '</body></html>'
  fi
  exit 0
fi

if [ "$action" = "mode" ]; then
  case "$value" in
    normal|boost) ( /root/pw-mode.sh "$value" >>/root/pw-mode.log 2>&1 ) & ;;
  esac
  hdr
  head_open " · 重排中"
  cat <<HTML
<div class="hd"><div class="hd-in"><h1>正在重排</h1><p>$value 模式 · 重设默认组并重启</p></div></div>
<main class="wrap"><div class="prog p30"><i></i></div>
<p class="tip">约 25~30 秒。<a href="/cgi-bin/pwnodes?tab=settings">手动返回</a></p></main>
<meta http-equiv="refresh" content="30;url=/cgi-bin/pwnodes?tab=settings">
HTML
  echo '</body></html>'
  exit 0
fi

if [ "$action" = "restart" ]; then
  ( /etc/init.d/passwall restart >/root/pw-web.log 2>&1 ) &
  hdr
  head_open " · 重启中"
  cat <<HTML
<div class="hd"><div class="hd-in"><h1>重启 PassWall</h1><p>约 15~25 秒恢复</p></div></div>
<main class="wrap"><div class="prog"><i></i></div>
<p class="tip"><a href="/cgi-bin/pwnodes?tab=overview">手动返回</a></p></main>
<meta http-equiv="refresh" content="25;url=/cgi-bin/pwnodes?tab=overview">
HTML
  echo '</body></html>'
  exit 0
fi

if [ "$action" = "ping" ] && [ -n "$id" ]; then
  pingnode "$id" >/dev/null
  if [ -n "$target" ]; then tab=bind; else tab=nodes; fi
fi

if [ "$action" = "pingtarget" ] && [ -n "$target" ]; then
  seen=" "
  list=""
  for g in $(role_groups "$target"); do
    for nid in $(members "$g"); do
      case "$seen" in *" $nid "*) continue ;; esac
      seen="$seen$nid "
      list="$list $nid"
    done
  done
  probe_all $list
  hdr
  echo "<!doctype html><html><head><meta charset=\"utf-8\"><meta http-equiv=\"refresh\" content=\"0;url=/cgi-bin/pwnodes?tab=bind&amp;target=$target\"></head><body></body></html>"
  exit 0
fi

if [ "$action" = "pinggroup" ] && [ -n "$group" ]; then
  case "$group" in
    UTFAST|UTGOOGLE|UTSTREAM|UT10X|UTDAILY)
      probe_all $(members "$group") ;;
  esac
  hdr
  echo '<!doctype html><html><head><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=/cgi-bin/pwnodes?tab=nodes"></head><body></body></html>'
  exit 0
fi

case "$action" in
  probe|latency|speed) tab=overview ;;
esac
[ "$tab" = "test" ] && tab=overview
[ -z "$tab" ] && tab=overview

# ---------- page ----------
pwrun=$(netstat -ltn 2>/dev/null | grep -c ':1070 ')
[ "$pwrun" = "0" ] && pwrun=$(pgrep -f sing-box 2>/dev/null | wc -l)
mem=$(free -m 2>/dev/null | awk '/Mem:/{print $3" / "$2" MB"}')
eg=$(egress)
eip=$(echo "$eg" | sed -n 's/.*ip=\([^ ]*\).*/\1/p')
eloc=$(echo "$eg" | sed -n 's/.*loc=\([^ ]*\).*/\1/p')
ecol=$(echo "$eg" | sed -n 's/.*colo=\([^ ]*\).*/\1/p')

case "$tab" in
  overview) if [ -n "$eip" ]; then subtitle="${eloc:-?}${ecol:+ · $ecol}"; else subtitle="出口信息获取中"; fi ;;
  bind) if [ -n "$target" ]; then subtitle="选一个出口，可先测"; else subtitle="选节点，顺带测速"; fi ;;
  nodes) subtitle="各组节点与最新测速" ;;
  settings) subtitle="时段模式与维护" ;;
esac

hdr
head_open ""
cat <<HTML
<div class="hd"><div class="hd-in"><h1>TR3600</h1><p>$subtitle</p></div></div>
<main class="wrap">
HTML

# 诊断结果卡（概览页内）
diag_result(){
  case "$action" in
    probe)
      tr=$(curl -s -x socks5h://127.0.0.1:1070 --max-time 10 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null)
      pip=$(echo "$tr" | sed -n 's/^ip=//p'); ploc=$(echo "$tr" | sed -n 's/^loc=//p'); pcol=$(echo "$tr" | sed -n 's/^colo=//p')
      cat <<HTML
<div class="sec"><h2>出口</h2></div>
<div class="card">
<div class="row"><span class="k">IP</span><span class="v mono">${pip:-未取到}</span></div>
<div class="row"><span class="k">地区</span><span class="v">${ploc:-?}${pcol:+ · $pcol}</span></div>
</div>
HTML
    ;;
    latency)
      l1=$(curl -s -x socks5h://127.0.0.1:1070 --max-time 8 -o /dev/null -w '%{time_total}' https://www.gstatic.com/generate_204 2>/dev/null)
      l2=$(curl -s -x socks5h://127.0.0.1:1070 --max-time 8 -o /dev/null -w '%{time_total}' https://www.gstatic.com/generate_204 2>/dev/null)
      l3=$(curl -s -x socks5h://127.0.0.1:1070 --max-time 8 -o /dev/null -w '%{time_total}' https://www.gstatic.com/generate_204 2>/dev/null)
      lm=$(awk -v a="$l1" -v b="$l2" -v c="$l3" 'BEGIN{printf "%d", (a+b+c)*1000/3}')
      cat <<HTML
<div class="sec"><h2>代理延迟</h2><span>三次平均</span></div>
<div class="card"><div class="row"><span class="k">gstatic</span><span class="v mono">${lm} ms</span></div>
<div class="row"><span class="k">样本</span><span class="v mono">$l1 / $l2 / $l3 s</span></div></div>
HTML
    ;;
    speed)
      so=$(curl -s -x socks5h://127.0.0.1:1070 --max-time 30 -o /dev/null -w '%{speed_download} %{time_total} %{size_download}' "https://speed.cloudflare.com/__down?bytes=10000000" 2>/dev/null)
      ss=$(echo "$so" | awk '{print $1}'); st=$(echo "$so" | awk '{print $2}'); sb=$(echo "$so" | awk '{print $3}')
      smb=$(awk -v s="$ss" 'BEGIN{printf "%.1f", s*8/1000000}')
      sbz=$(awk -v b="$sb" 'BEGIN{printf "%.1f", b/1048576}')
      cat <<HTML
<div class="sec"><h2>下载</h2><span>10 MB 样本</span></div>
<div class="card"><div class="row"><span class="k">速度</span><span class="v mono">${smb} Mbps</span></div>
<div class="row"><span class="k">用时</span><span class="v mono">${sbz} MB · ${st}s</span></div></div>
HTML
    ;;
  esac
}

# 单个角色行（概览/代理页共用）
glabel(){ case "$1" in UTFAST|UTGOOGLE|UTSTREAM|UT10X|UTDAILY) echo "$1" ;; *) gn3=$(nname "$1"); if [ -n "$gn3" ]; then echo "$gn3"; else echo "$1"; fi ;; esac; }

role_sub(){
  rc=$(role_cur "$1")
  if [ -z "$rc" ]; then echo "未设置"; return; fi
  if [ -n "$(members "$rc")" ]; then
    ng=$(group_now "$rc")
    if [ -n "$ng" ]; then echo "现在 $ng"; else echo "现在 —"; fi
  else
    echo "固定 · $(nname "$rc")"
  fi
}

role_row(){
  rs=$(role_sub "$1")
  printf '<a class="lr" href="/cgi-bin/pwnodes?tab=bind&amp;target=%s"><span><b>%s</b><small>%s</small></span>%s</a>' "$1" "$(role_name "$1")" "$rs" "$(chev)"
}

case "$tab" in
overview)
  if [ "$pwrun" -gt 0 ]; then pws="<span class=\"dot ok\"></span>运行中"; else pws="<span class=\"dot bad\"></span>未运行"; fi
  cat <<HTML
<div class="sec"><h2>连接</h2><span>$( [ "$def" = UT10X ] && echo 高峰模式 || echo 常态模式 )</span></div>
<div class="card">
<div class="row"><span class="k">出口 IP</span><span class="v mono">${eip:-未取到}</span></div>
<div class="row"><span class="k">出口地区</span><span class="v">${eloc:-?}${ecol:+ · $ecol}</span></div>
<div class="row"><span class="k">代理</span><span class="v">$pws</span></div>
<div class="row"><span class="k">内存</span><span class="v mono">${mem:-?}</span></div>
</div>

<div class="sec"><h2>角色</h2><span>点一行换出口</span></div>
<div class="card pad0">
HTML
  role_row default
  role_row x
  role_row google
  role_row stream
  role_row ai
  echo '</div>'

  cat <<HTML
<div class="sec"><h2>诊断</h2><span>经当前默认出口</span></div>
HTML
  diag_result
  cat <<HTML
<div class="card pad0">
<a class="lr" href="/cgi-bin/pwnodes?tab=overview&amp;action=probe"><span><b>出口身份</b><small>IP、国家、Cloudflare 机房</small></span>$(chev)</a>
<a class="lr" href="/cgi-bin/pwnodes?tab=overview&amp;action=latency"><span><b>代理延迟</b><small>三次 gstatic 平均</small></span>$(chev)</a>
<a class="lr" href="/cgi-bin/pwnodes?tab=overview&amp;action=speed"><span><b>下载带宽</b><small>10 MB 样本，3~20 秒</small></span>$(chev)</a>
</div>
<p class="tip">出口信息缓存 90 秒。节点级测速在「代理」或「节点」页，点毫秒数字即可。</p>
HTML
;;
bind)
  if [ -z "$target" ]; then
    cat <<HTML
<div class="sec"><h2>角色</h2><span>点一行挑节点</span></div>
<div class="card pad0">
HTML
    role_row default
    role_row x
    role_row google
    role_row stream
    role_row ai
    echo '</div>'
    echo '<p class="tip">每个角色独立出口。点进去就是该角色的节点列表，最上面一行是自动选择。</p>'
  else
    cur=$(role_cur "$target")
    home=$(role_home "$target")
    curgrp=""
    [ -n "$(members "$cur")" ] && curgrp=$cur
    nowlab=$(group_now "${curgrp:-$home}")
    cnt=0
    ord="/tmp/pw_ord.$$"
    : > "$ord"
    seen=" "
    for g in $(role_groups "$target"); do
      for nid in $(members "$g"); do
        case "$seen" in *" $nid "*) continue ;; esac
        seen="$seen$nid "
        echo "$(sortkey "$nid") $nid" >> "$ord"
      done
    done
    cnt=$(wc -l < "$ord" 2>/dev/null | tr -d ' ')
    [ -z "$cnt" ] && cnt=0

    echo "<div class=\"sec\"><h2>$(role_name "$target")</h2><span><a href=\"/cgi-bin/pwnodes?tab=bind&amp;target=$target&amp;action=pingtarget\">测全部</a> · <a href=\"/cgi-bin/pwnodes?tab=bind\">返回</a></span></div>"
    echo '<div class="card">'
    if [ -n "$curgrp" ]; then
      if [ -n "$nowlab" ]; then autosub="$(glabel "$curgrp") · 现在 $nowlab"; else autosub="$(glabel "$curgrp") · 现在 —"; fi
      echo "<div class=\"pickrow\"><div class=\"pick-main\"><b>自动选择</b><small>$autosub</small></div><span class=\"pill auto\">使用中</span></div>"
    else
      echo "<a class=\"pickrow\" href=\"/cgi-bin/pwnodes?action=auto&amp;target=$target\"><div class=\"pick-main\"><b>自动选择</b><small>回到 $home${nowlab:+ · 上次 $nowlab}</small></div><span class=\"pill auto\">恢复</span></a>"
    fi
    sort -n "$ord" | while read -r sk nid; do
      [ -z "$nid" ] && continue
      nn=$(nname "$nid"); [ -z "$nn" ] && continue
      ms=$(raw_ms "$nid")
      mark=""
      [ "$cur" = "$nid" ] && mark='<span class="curmark">使用中</span>'
      fr=$(fresh "$nid")
      sub="$(nprov "$nid") ×$(nmult "$nid")"
      [ -n "$fr" ] && sub="$sub · $fr"
      echo "<div class=\"pickrow\"><a class=\"pick-main\" href=\"/cgi-bin/pwnodes?action=bind&amp;target=$target&amp;value=$nid\"><b>$nn$mark</b><small>$sub</small></a><a class=\"$(pillcls "$ms")\" href=\"/cgi-bin/pwnodes?tab=bind&amp;target=$target&amp;action=ping&amp;id=$nid\">$(pilltext "$ms")</a></div>"
    done
    rm -f "$ord"

    # 其它节点：不在本组、但可直连绑定（含 Xray），按角色地区过滤
    case "$target" in
      default) pat="香港 澳门"; rlabel="香港/澳门" ;;
      stream) pat="香港"; rlabel="香港" ;;
      x) pat="新加坡 美国"; rlabel="新加坡/美国" ;;
      google) pat="新加坡"; rlabel="新加坡" ;;
      ai) pat="台湾"; rlabel="台湾" ;;
      *) pat=""; rlabel="" ;;
    esac
    NOW=$(date +%s); ocnt=0
    MF="/tmp/pw_meta.$$"
    uci show passwall 2>/dev/null | awk -F"'" '
      /^passwall\.[A-Za-z0-9_]+\.[A-Za-z0-9_]+=/ {
        split($1,a,"."); id=a[2]; key=a[3]; sub(/=$/,"",key); val=$2;
        if (key=="remarks") r[id]=val; else if (key=="type") t[id]=val;
        else if (key=="protocol") p[id]=val; else if (key=="group") g[id]=val;
        else if (key=="address") ad[id]=val; else if (key=="port") po[id]=val;
      }
      END { for (i in r) { if (t[i]!="" && ad[i]!="" && p[i]!="_urltest" && p[i]!="_shunt") printf "%s|%s|%s|%s|%s\n", i, t[i], r[i], g[i], po[i] } }
    ' > "$MF"
    oth="/tmp/pw_oth.$$"
    : > "$oth"
    while IFS='|' read -r sid stype srem sgrp sport; do
      [ -z "$sid" ] && continue
      case "$mem" in *" $sid "*) continue ;; esac
      hit=0
      for kw in $pat; do case "$srem" in *"$kw"*) hit=1 ;; esac; done
      [ "$hit" = "1" ] || continue
      case "$srem" in *TG*|*不通*|*交流群*) continue ;; esac
      case "$srem" in *×*) mv=${srem##*×}; mv=${mv%%[!0-9.]*}; [ -z "$mv" ] && mv=1 ;; *) mv=1 ;; esac
      ocnt=$((ocnt+1))
      echo "$sid|$stype|$srem|$sgrp|$sport|$mv" >> "$oth"
    done < "$MF"
    rm -f "$MF"
    if [ "$ocnt" -gt 0 ]; then
      echo "<details class=\"pools\"><summary>其它$rlabel节点（$ocnt 个，可直接绑定）</summary>"
      sort -t'|' -k3 "$oth" | while IFS='|' read -r sid stype srem sgrp sport smv; do
        read -r pts pms < "/tmp/pw_ping_$sid" 2>/dev/null || { pts=""; pms=""; }
        fr=""
        if [ -n "$pts" ]; then
          age=$(( NOW - pts ))
          if [ "$age" -lt 90 ]; then fr="刚测"; elif [ "$age" -lt 3600 ]; then fr="$((age/60)) 分钟前"; fi
        fi
        case "$pms" in ""|0) pms="" ;; esac
        sub="$(case "$sgrp" in nvenix) echo Nvenix;; sushi) echo 寿司云;; liangxin) echo 良心云;; *) echo "$sgrp";; esac) ×$smv"
        [ -n "$fr" ] && sub="$sub · $fr"
        tag=""; [ "$stype" = "Xray" ] && tag='<span class="tag">Xray</span>'
        echo "<div class=\"pickrow\"><a class=\"pick-main\" href=\"/cgi-bin/pwnodes?action=bind&amp;target=$target&amp;value=$sid\"><b>$srem$tag</b><small>$sub</small></a><a class=\"$(pillcls "$pms")\" href=\"/cgi-bin/pwnodes?tab=bind&amp;target=$target&amp;action=ping&amp;id=$sid\">$(pilltext "$pms")</a></div>"
      done
      echo '</details>'
    fi
    rm -f "$oth"
    echo '</div>'
    cat <<HTML
<p class="tip">$( [ -n "$curgrp" ] && echo "共 $cnt 个在组内 · 按延迟排序。" )点名字＝固定（重启约 20 秒），点毫秒＝只测它。Xray 节点只能单独绑定，不能进自动组。</p>
HTML
    if [ "$target" = "ai" ]; then
      echo '<p class="tip">AI 账号对出口 IP 敏感，建议长期固定同一个家宽节点；频繁换地区有风控风险。</p>'
    fi
  fi
;;
nodes)
  echo '<div class="sec"><h2>各组</h2><span>点毫秒测单个</span></div>'
  for g in UTFAST UTGOOGLE UTSTREAM UT10X UTDAILY; do
    grole=""
    [ "$(role_home default)" = "$g" ] && grole="$grole 日常"
    [ "$(role_home x)" = "$g" ] && grole="$grole X"
    [ "$(role_home google)" = "$g" ] && grole="$grole Google"
    [ "$(role_home stream)" = "$g" ] && grole="$grole 流媒体"
    gchips=""
    [ -n "$grole" ] && gchips="$(printf '<span class="chip acc">%s</span>' "$grole")"
    cat <<HTML
<div class="card"><div class="ghead"><b>$g</b><span>$gchips<a href="/cgi-bin/pwnodes?tab=nodes&amp;action=pinggroup&amp;group=$g">测全部</a></span></div>
HTML
    for nid in $(members "$g"); do
      nn=$(nname "$nid"); [ -z "$nn" ] && continue
      ms=$(raw_ms "$nid")
      fr=$(fresh "$nid")
      sub="$(nprov "$nid") ×$(nmult "$nid")"
      [ -n "$fr" ] && sub="$sub · $fr"
      echo "<div class=\"pickrow\"><div class=\"pick-main\"><b>$nn</b><small>$sub</small></div><a class=\"$(pillcls "$ms")\" href=\"/cgi-bin/pwnodes?tab=nodes&amp;action=ping&amp;id=$nid\">$(pilltext "$ms")</a></div>"
    done
    echo '</div>'
  done
  echo '<p class="tip">「测全部」逐台跑 TCP 握手，最长约 10 秒。只是入口连通性，不代表代理后的实际速度。</p>'
;;
settings)
  if [ "$def" = "UT10X" ]; then m_boost=" on"; m_norm=""; else m_norm=" on"; m_boost=""; fi
  cronl=$(crontab -l 2>/dev/null | grep pw-mode)
  cat <<HTML
<div class="sec"><h2>时段</h2><span>20:00 起切高峰</span></div>
<div class="card">
<div class="seg"><a class="$m_norm" href="/cgi-bin/pwnodes?action=mode&amp;value=normal">常态</a><a class="$m_boost" href="/cgi-bin/pwnodes?action=mode&amp;value=boost">高峰 10x</a></div>
<p class="tip">切换会重设默认组并重启，覆盖你在「日常」里单独固定的节点。</p>
</div>

<div class="sec"><h2>定时任务</h2></div>
<div class="card"><p class="tip" style="margin:0;font-family:ui-monospace,Menlo,monospace;font-size:12px;overflow-wrap:anywhere">${cronl:-未设置}</p></div>

<div class="sec"><h2>维护</h2></div>
<div class="card pad0">
<a class="lr" href="/cgi-bin/pwnodes?action=restart"><span><b>重启 PassWall</b><small>约 20 秒断网</small></span>$(chev)</a>
<a class="lr" href="/pw/"><span><b>旧版模式页</b><small>broad 模式入口</small></span>$(chev)</a>
</div>
<p class="tip">本页仅局域网可访问：192.168.2.1/cgi-bin/pwnodes</p>
HTML
;;
esac

echo '</main>'
echo '<nav class="tabbar">'
tablink overview 概览
tablink bind 代理
tablink nodes 节点
tablink settings 设置
echo '</nav></body></html>'
