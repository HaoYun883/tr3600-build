#!/usr/bin/ucode
// TR3600 panel for OpenClash (mihomo) — reads the local Clash API
let fs = require("fs");

const API = "http://192.168.2.1:9090";
const CFG_UCI = "/etc/config/openclash";
const CACHE = "/tmp/pn_delay.json";
const EGRESS = "/tmp/pn_egress";

/* ---------- helpers ---------- */
function shq(s) {
	let out = "";
	for (let i = 0; i < length(s); i++) {
		let c = substr(s, i, 1);
		out += (c == "'") ? "'\\''" : c;
	}
	return "'" + out + "'";
}

function enc(s) {
	let safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
	let out = "";
	for (let i = 0; i < length(s); i++) {
		let c = substr(s, i, 1);
		out += (index(safe, c) >= 0) ? c : sprintf("%%%02X", ord(c));
	}
	return out;
}

function dec(s) {
	let out = "", i = 0, L = length(s);
	while (i < L) {
		let c = substr(s, i, 1);
		if (c == "%" && i + 2 < L) {
			out += chr(int(substr(s, i + 1, 2), 16));
			i += 3;
		} else if (c == "+") {
			out += " "; i++;
		} else {
			out += c; i++;
		}
	}
	return out;
}

function esc(s) {
	s = replace(s ?? "", "&", "&amp;");
	s = replace(s, "<", "&lt;");
	s = replace(s, ">", "&gt;");
	s = replace(s, "\"", "&quot;");
	return s;
}

function qs() {
	let raw = getenv("QUERY_STRING") ?? "";
	let o = {};
	for (let pair in split(raw, "&")) {
		if (!pair) continue;
		let p = index(pair, "=");
		if (p < 0) o[dec(pair)] = "";
		else o[dec(substr(pair, 0, p))] = dec(substr(pair, p + 1));
	}
	return o;
}

function ocpath() {
	let txt = fs.readfile(CFG_UCI) ?? "";
	let m = match(txt, /option config_path \x27([^\x27]+)\x27/);
	if (m) return m[1];
	return "/etc/openclash/config.yaml";
}

function runcfg() {
	let h = fs.popen("ps w | grep '/etc/openclash/clash' | grep -v grep | head -1");
	let line = trim(h.read("all") ?? "");
	h.close();
	let m = match(line, /-f ([^ ]+)/);
	return m ? m[1] : ocpath();
}

function secret() {
	let txt = fs.readfile(runcfg()) ?? "";
	for (let line in split(txt, "\n")) {
		if (match(line, /^secret:/)) {
			let v = trim(substr(line, 7));
			v = replace(v, "'", "");
			v = replace(v, "\"", "");
			return v;
		}
	}
	return "";
}

function api(path, method, body) {
	let cmd = sprintf("curl -s -m 8 -X %s -H %s %s",
		method, shq("Authorization: Bearer " + secret()), shq(API + path));
	if (body != null) cmd += " -d " + shq(body);
	let h = fs.popen(cmd);
	let out = h.read("all");
	h.close();
	return out;
}

function load_cache() {
	let d = json(fs.readfile(CACHE) ?? "{}");
	return (type(d) == "object" && d) ? d : {};
}

function save_cache(c) {
	fs.writefile(CACHE, sprintf("%J", c));
}

function pills(ms) {
	if (ms == null) return [ "pill", "测" ];
	if (ms <= 0) return [ "pill bad", "超时" ];
	if (ms < 200) return [ "pill ok", ms + "ms" ];
	if (ms < 500) return [ "pill mid", ms + "ms" ];
	return [ "pill bad", ms + "ms" ];
}

function hist_delay(p) {
	let h = p.history;
	if (type(h) != "array" || length(h) == 0) return null;
	let last = h[length(h) - 1];
	return (type(last) == "object" && last.delay) ? last.delay : null;
}

function groups(d) {
	let out = [];
	for (let k, v in d.proxies) {
		if (v.type == "Selector" || v.type == "URLTest" || v.type == "Fallback")
			push(out, { name: k, type: v.type, now: v.now, all: v.all ?? [] });
	}
	return out;
}

function getgrp(d, name) {
	for (let g in groups(d)) if (g.name == name) return g;
	return null;
}

/* ---------- page pieces ---------- */
function css() {
	print(`<style>
:root{--bg:#0b0c0f;--surface:#14161a;--surface2:#191c21;--line:rgba(255,255,255,.07);--line2:rgba(255,255,255,.13);--text:#f3f4f6;--text2:#9aa0aa;--text3:#6b7280;--accent:#5b9dff;--accent-d:#2f6fd0;--ok:#3ecf8e;--bad:#ff6b6b;--ease-out:cubic-bezier(.23,1,.32,1)}
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
.chip{display:inline-block;padding:3px 8px;border-radius:999px;background:rgba(255,255,255,.055);border:1px solid var(--line);color:var(--text2);font-size:11px;margin:0 5px 5px 0;user-select:none;-webkit-user-select:none}
.chip.acc{color:#bcd4ff;background:rgba(91,157,255,.12);border-color:rgba(91,157,255,.22)}
.btn{display:block;width:100%;border:0;appearance:none;font-family:inherit;color:#07121f;background:var(--accent);border-radius:13px;padding:14px;margin-top:10px;font-size:15px;font-weight:600;text-align:center;touch-action:manipulation;user-select:none;-webkit-user-select:none;transition:transform .16s var(--ease-out),background .16s ease}
.btn:active{transform:scale(.98);background:var(--accent-d)}
.btn.ghost{background:var(--surface2);color:var(--text);border:1px solid var(--line2);font-weight:500}
.lr{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:13px 0;border-bottom:1px solid var(--line);color:var(--text)}
.lr:last-child{border-bottom:0}
.lr b{font-size:14.5px;font-weight:500}
.lr small{display:block;color:var(--text3);font-size:12px;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.lr svg{width:15px;height:15px;flex:0 0 auto;stroke:var(--text3);fill:none;stroke-width:1.9;stroke-linecap:round;stroke-linejoin:round}
.lr:active b{opacity:.6}
.pickrow{display:flex;align-items:center;gap:10px;padding:11px 0;border-bottom:1px solid var(--line)}
.pickrow:last-child{border-bottom:0}
.pick-main{flex:1;min-width:0;color:var(--text);display:block}
.pick-main b{display:block;font-size:14px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pick-main small{display:block;color:var(--text3);font-size:11.5px;margin-top:2px}
.pick-main:active b{opacity:.6}
.pill{flex:0 0 auto;min-width:58px;text-align:center;padding:7px 9px;border-radius:9px;font-size:12px;font-weight:600;font-variant-numeric:tabular-nums;background:rgba(255,255,255,.055);color:var(--text2);border:1px solid var(--line);touch-action:manipulation;transition:transform .15s var(--ease-out),background .15s ease}
.pill:active{transform:scale(.95);background:rgba(255,255,255,.1)}
.pill.ok{color:#8ff0bc;background:rgba(62,207,142,.12);border-color:rgba(62,207,142,.22)}
.pill.mid{color:#ffd79a;background:rgba(245,177,76,.12);border-color:rgba(245,177,76,.22)}
.pill.bad{color:#ffb3b3;background:rgba(255,107,107,.12);border-color:rgba(255,107,107,.22)}
.pill.auto{color:#bcd4ff;background:rgba(91,157,255,.12);border-color:rgba(91,157,255,.22)}
.curmark{display:inline-block;margin-left:6px;padding:1px 6px;border-radius:6px;background:rgba(91,157,255,.16);color:#bcd4ff;font-size:10.5px;font-weight:600;vertical-align:1px}
.tabbar{position:fixed;left:0;right:0;bottom:0;z-index:20;display:flex;padding:5px 8px calc(5px + env(safe-area-inset-bottom,0px));background:rgba(11,12,15,.9);backdrop-filter:blur(20px) saturate(1.7);-webkit-backdrop-filter:blur(20px) saturate(1.7);border-top:1px solid var(--line)}
.tabbar a{flex:1;display:flex;flex-direction:column;align-items:center;gap:3px;padding:7px 0 4px;color:var(--text3);font-size:10.5px;border-radius:12px;touch-action:manipulation;user-select:none;-webkit-user-select:none}
.tabbar a .ic{width:22px;height:22px;stroke:currentColor;fill:none;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round}
.tabbar a.on{color:var(--accent)}
.tabbar a:active .ic{transform:scale(.92)}
.tip{color:var(--text3);font-size:12px;line-height:1.6;margin:10px 2px 0}
.mono2{font-family:ui-monospace,Menlo,monospace;font-size:12px;overflow-wrap:anywhere}
.wrap{max-width:560px;margin:0 auto}
.prog{height:3px;border-radius:2px;background:rgba(255,255,255,.08);overflow:hidden;margin-top:16px}
.prog i{display:block;height:100%;width:0;background:var(--accent);animation:fill 20s linear forwards}
@keyframes fill{to{width:100%}}
@media (prefers-reduced-motion:reduce){*{animation-duration:.01ms!important;transition-duration:.01ms!important}}
</style>`);
}

function icon(n) {
	const s = {
		overview: '<rect x="3.6" y="3.6" width="6.8" height="6.8" rx="2"/><rect x="13.6" y="3.6" width="6.8" height="6.8" rx="2"/><rect x="3.6" y="13.6" width="6.8" height="6.8" rx="2"/><rect x="13.6" y="13.6" width="6.8" height="6.8" rx="2"/>',
		groups: '<path d="M12 3.4l8 4.3-8 4.3-8-4.3 8-4.3z"/><path d="M4 11.7l8 4.3 8-4.3"/><path d="M4 16l8 4.3 8-4.3"/>',
		nodes: '<path d="M4 6.5h16M4 12h16M4 17.5h16"/><circle cx="7.2" cy="6.5" r="1.5" fill="currentColor" stroke="none"/><circle cx="7.2" cy="17.5" r="1.5" fill="currentColor" stroke="none"/>',
		settings: '<path d="M4 7.2h9.4M17.4 7.2H20M4 16.8h2.6M10.6 16.8H20"/><circle cx="15.4" cy="7.2" r="2.1"/><circle cx="8.6" cy="16.8" r="2.1"/>',
	};
	return '<svg class="ic" viewBox="0 0 24 24">' + (s[n] ?? "") + '</svg>';
}

function nav() {
	let items = [ [ "overview", "概览" ], [ "groups", "代理" ], [ "nodes", "节点" ], [ "settings", "设置" ] ];
	let out = '<nav class="tabbar">';
	for (let it in items) {
		let cls = (it[0] == tab) ? " on" : "";
		out += sprintf('<a class="t%s" href="/cgi-bin/pwnodes?tab=%s">%s<span>%s</span></a>', cls, it[0], icon(it[0]), it[1]);
	}
	return out + "</nav>";
}

function chev() {
	return '<svg viewBox="0 0 24 24"><path d="M9 6l6 6-6 6"/></svg>';
}

function head(sub) {
	print("Content-Type: text/html; charset=utf-8\r\n\r\n");
	print('<!doctype html><html lang="zh"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover,interactive-widget=resizes-content"><meta name="theme-color" content="#0b0c0f"><meta name="color-scheme" content="dark"><title>TR3600</title>');
	css();
	print('</head><body>');
	print(sprintf('<div class="hd"><div class="hd-in"><h1>TR3600</h1><p>%s</p></div></div><main class="wrap">', esc(sub)));
}

function foot() {
	print("</main>" + nav() + "</body></html>");
}

function redirect(to) {
	print("Status: 303 See Other\r\n");
	print("Location: " + to + "\r\n\r\n");
	exit(0);
}

function egress() {
	let now = time();
	try {
		let st = fs.stat(EGRESS);
		if (st && now - st.mtime < 90) return trim(fs.readfile(EGRESS) ?? "");
	} catch (e) { }
	let h = fs.popen("curl -s -m 6 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -E '^(ip|loc)=' | tr '\\n' ' '");
	let out = trim(h.read("all") ?? "");
	h.close();
	if (out) fs.writefile(EGRESS, out);
	return out;
}

/* ---------- state ---------- */
let q = qs();
let tab = q.tab ?? "overview";
let action = q.action ?? "";
let d = json(api("/proxies", "GET") ?? "{}");
let cache = load_cache();

if (type(d) != "object" || !d.proxies) {
	head("内核 API 无响应");
	print('<div class="card"><div class="row"><span class="k">状态</span><span class="v"><span class="dot bad"></span>读不到 Clash API</span></div><p class="tip">OpenClash 可能没启动。用「设置 → 重启 OpenClash」或 SSH 看 <span class="mono2">/tmp/openclash.log</span>。</p></div>');
	foot();
	exit(0);
}

let glist = groups(d);

/* ---------- actions ---------- */
if (action == "select") {
	let g = q.group ?? "", n = q.node ?? "";
	if (g && n) {
		let body = sprintf('{"name":"%s"}', replace(replace(n, "\\\\", "\\\\\\\\"), "\"", "\\\""));
		api("/proxies/" + enc(g), "PUT", body);
	}
	redirect(q.back ?? ("/cgi-bin/pwnodes?tab=groups"));
}

if (action == "delay") {
	let n = q.node ?? "";
	if (n) {
		let r = json(api(sprintf("/proxies/%s/delay?timeout=3000&url=%s", enc(n), enc("https://www.gstatic.com/generate_204")), "GET") ?? "{}");
		let ms = (type(r) == "object" && r.delay != null) ? r.delay : 0;
		cache[n] = [ ms, time() ];
		save_cache(cache);
	}
	redirect(q.back ?? ("/cgi-bin/pwnodes?tab=nodes"));
}

if (action == "delaygroup") {
	let g = q.group ?? "";
	if (g) {
		let r = json(api(sprintf("/group/%s/delay?timeout=3000&url=%s", enc(g), enc("https://www.gstatic.com/generate_204")), "GET") ?? "{}");
		if (type(r) == "object") {
			for (let k, v in r) cache[k] = [ v, time() ];
			save_cache(cache);
		}
	}
	redirect(q.back ?? ("/cgi-bin/pwnodes?tab=groups"));
}

if (action == "restart") {
	fs.popen("/etc/init.d/openclash restart >/tmp/oc-restart.log 2>&1 &");
	head("正在重启 OpenClash");
	print('<div class="prog"><i></i></div><p class="tip">约 15~25 秒，代理会短暂中断。<a href="/cgi-bin/pwnodes?tab=overview">返回</a></p>');
	foot();
	print('<meta http-equiv="refresh" content="25;url=/cgi-bin/pwnodes?tab=overview">');
	exit(0);
}

/* ---------- render ---------- */
let sub = {
	overview: "OpenClash · mihomo",
	groups: "代理组与当前选择",
	nodes: "节点测速（真延迟）",
	settings: "内核与维护",
}[tab] ?? "";

head(sub);

if (tab == "overview") {
	let eg = egress();
	let m = match(eg, /ip=([^ ]+)/), l = match(eg, /loc=([^ ]+)/);
	let ver = json(api("/version", "GET") ?? "{}");
	let mem = "";
	let mi = fs.readfile("/proc/meminfo") ?? "";
	let mt = match(mi, /MemTotal:\s*(\d+)/), mf = match(mi, /MemAvailable:\s*(\d+)/);
	if (mt && mf) mem = sprintf("%d / %d MB", (int(mt[1]) - int(mf[1])) / 1024, int(mt[1]) / 1024);
	let core = "";
	let proc = fs.popen("ps w | grep '/etc/openclash/clash' | grep -v grep | head -1");
	if (length(trim(proc.read("all") ?? ""))) core = "运行中";
	proc.close();

	print('<div class="sec"><h2>状态</h2><span>OpenClash</span></div><div class="card">');
	print(sprintf('<div class="row"><span class="k">出口 IP</span><span class="v mono">%s</span></div>', esc(m ? m[1] : "未取到")));
	print(sprintf('<div class="row"><span class="k">出口地区</span><span class="v">%s</span></div>', esc(l ? l[1] : "?")));
	print(sprintf('<div class="row"><span class="k">内核</span><span class="v">%s %s</span></div>', esc(ver.version ?? "?"), esc(core)));
	print(sprintf('<div class="row"><span class="k">内存</span><span class="v mono">%s</span></div>', esc(mem)));
	print('</div>');

	print('<div class="sec"><h2>代理组</h2><span>点一行切换</span></div><div class="card pad0">');
	for (let g in glist) {
		if (g.name == "GLOBAL") continue;
		print(sprintf('<a class="lr" href="/cgi-bin/pwnodes?tab=group&name=%s"><span><b>%s</b><small>%s</small></span>%s</a>',
			esc(enc(g.name)), esc(g.name), esc(g.now ?? "未选择"), chev()));
	}
	print('</div>');

	print('<div class="sec"><h2>快捷</h2></div><div class="card pad0">');
	print(sprintf('<a class="lr" href="/cgi-bin/pwnodes?tab=nodes"><span><b>节点测速</b><small>%d 个节点</small></span>%s</a>', length(glist[0] ? glist[0].all : []), chev()));
	print(sprintf('<a class="lr" href="http://192.168.2.1/cgi-bin/luci/admin/services/openclash" target="_blank"><span><b>OpenClash 设置</b><small>LuCI 管理页</small></span>%s</a>', chev()));
	print('</div>');
}

if (tab == "groups") {
	print('<div class="sec"><h2>代理组</h2><span>点击进入选择</span></div><div class="card pad0">');
	for (let g in glist) {
		print(sprintf('<a class="lr" href="/cgi-bin/pwnodes?tab=group&name=%s"><span><b>%s</b><small>%s · %d 个成员</small></span>%s</a>',
			esc(enc(g.name)), esc(g.name), esc(g.now ?? "未选择"), length(g.all), chev()));
	}
	print('</div>');
}

if (tab == "group") {
	let name = q.name ?? "";
	let g = getgrp(d, name);
	if (!g) { print('<p class="tip">找不到这个组。</p>'); foot(); exit(0); }
	let members = [];
	for (let m in g.all) if (d.proxies[m]) push(members, d.proxies[m]);
	// sort: known delay asc, then unknown by name
	sort(members, (a, b) => {
		let da = cache[a.name] ? cache[a.name][0] : (hist_delay(a) ?? 99999);
		let db = cache[b.name] ? cache[b.name][0] : (hist_delay(b) ?? 99999);
		if (da != db) return da - db;
		return a.name < b.name ? -1 : 1;
	});
	let back = enc("/cgi-bin/pwnodes?tab=group&name=" + enc(g.name));
	print(sprintf('<div class="sec"><h2>%s</h2><span><a href="/cgi-bin/pwnodes?tab=group&name=%s&action=delaygroup&group=%s&back=%s">测全部</a> · <a href="/cgi-bin/pwnodes?tab=groups">返回</a></span></div>',
		esc(g.name), esc(enc(g.name)), esc(enc(g.name)), back));
	print('<div class="card">');
	print(sprintf('<div class="pickrow"><div class="pick-main"><b>当前</b><small>%s</small></div><span class="pill auto">%s</span></div>', esc(g.now ?? "-"), esc(g.type)));
	for (let m in members) {
		let ms = cache[m.name] ? cache[m.name][0] : hist_delay(m);
		let p = pills(ms);
		let mark = (m.name == g.now) ? '<span class="curmark">使用中</span>' : "";
		print(sprintf('<div class="pickrow"><a class="pick-main" href="/cgi-bin/pwnodes?action=select&group=%s&node=%s&back=%s"><b>%s%s</b><small>%s</small></a><a class="%s" href="/cgi-bin/pwnodes?action=delay&node=%s&back=%s">%s</a></div>',
			esc(enc(g.name)), esc(enc(m.name)), back, esc(m.name), mark, esc(m.type), p[0], esc(enc(m.name)), back, p[1]));
	}
	print('</div><p class="tip">点名字＝切到这个节点（立即生效，不重启）；点毫秒＝只测这一个。延迟是经节点发 HTTP 请求的真实往返。</p>');
}

if (tab == "nodes") {
	let gname = "自动选择";
	if (!getgrp(d, gname)) gname = glist[0] ? glist[0].name : "";
	let g = getgrp(d, gname);
	let members = [];
	if (g) for (let m in g.all) if (d.proxies[m]) push(members, d.proxies[m]);
	sort(members, (a, b) => {
		let da = cache[a.name] ? cache[a.name][0] : (hist_delay(a) ?? 99999);
		let db = cache[b.name] ? cache[b.name][0] : (hist_delay(b) ?? 99999);
		if (da != db) return da - db;
		return a.name < b.name ? -1 : 1;
	});
	let back = enc("/cgi-bin/pwnodes?tab=nodes");
	print(sprintf('<div class="sec"><h2>%s</h2><span><a href="/cgi-bin/pwnodes?tab=nodes&action=delaygroup&group=%s&back=%s">测全部</a></span></div>',
		esc(gname), esc(enc(gname)), back));
	print('<div class="card">');
	for (let m in members) {
		let ms = cache[m.name] ? cache[m.name][0] : hist_delay(m);
		let p = pills(ms);
		print(sprintf('<div class="pickrow"><div class="pick-main"><b>%s</b><small>%s</small></div><a class="%s" href="/cgi-bin/pwnodes?action=delay&node=%s&back=%s">%s</a></div>',
			esc(m.name), esc(m.type), p[0], esc(enc(m.name)), back, p[1]));
	}
	print(sprintf('</div><p class="tip">共 %d 个节点。「测全部」由内核并发测，几秒完成。</p>', length(members)));
}

if (tab == "settings") {
	print('<div class="sec"><h2>内核</h2></div><div class="card">');
	print(sprintf('<div class="row"><span class="k">API</span><span class="v mono">192.168.2.1:9090</span></div>'));
	print(sprintf('<div class="row"><span class="k">配置</span><span class="v mono2">%s</span></div>', esc(ocpath())));
	print('</div>');
	print('<div class="sec"><h2>维护</h2></div><div class="card pad0">');
	print(sprintf('<a class="lr" href="/cgi-bin/pwnodes?action=restart"><span><b>重启 OpenClash</b><small>约 20 秒断网</small></span>%s</a>', chev()));
	print(sprintf('<a class="lr" href="http://192.168.2.1/cgi-bin/luci/admin/services/openclash" target="_blank"><span><b>OpenClash 设置</b><small>订阅、规则、日志</small></span>%s</a>', chev()));
	print('</div>');
	print('<p class="tip">订阅更新要经代理下载，直连失败时找我手动拉。PassWall 已停用但保留，可随时切回。</p>');
}

foot();
