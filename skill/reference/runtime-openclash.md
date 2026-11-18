# OpenClash（mihomo）运行时

本固件是 **apk** 包管理（25.12-SNAPSHOT），防火墙为 firewall4。

> **当前运行时：OpenClash（mihomo）**，2026-11 起启用。
> PassWall 保留在机器上（已停用、关自启），随时可切回；两套面板分别对应，见下表。

| 运行时 | 状态 | 面板 | 切换 |
|---|---|---|---|
| OpenClash | ✅ 当前使用 | `pwnodes.uc` | `runtime-switch.sh openclash` |
| PassWall | 备选（未启用） | `pwnodes-passwall.sh` | `runtime-switch.sh passwall` |

## 为什么切

| | PassWall（sing-box） | OpenClash（mihomo） |
|---|---|---|
| 当前选中节点 | 内核不暴露，只能靠 `netstat` 连接推断 | Clash API `now` 字段直接读 |
| 节点延迟 | 只能测路由器到入口的 TCP 握手（2–5ms，假象） | `/proxies/{name}/delay` 经节点发 HTTP，端到端 |
| 切换节点 | 改 uci + 重启 PassWall（断网 20s） | `PUT /proxies/{group}`，即时生效 |
| 组测速 | 自己串行跑 | `/group/{name}/delay` 内核并发 |

## 安装

```sh
# 依赖（大部分固件已带）
apk add bash dnsmasq-full curl ca-bundle ip-full ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base

# 官方包（GitHub Releases 的 *.apk）
apk add -q --force-overwrite --clean-protected --allow-untrusted /tmp/luci-app-openclash-<ver>.apk
```

**注意**：`downloads.openwrt.org` 的包文件在国内经常拉不动（索引能取、文件 404/超时）。可改用 SJTU 镜像同路径补包，再本地安装：

```sh
B=https://mirror.sjtu.edu.cn/openwrt/releases/25.12-SNAPSHOT/packages/aarch64_cortex-a53/packages
curl -O $B/ruby-3.4.9-r1.apk   # 逐个下载后用 apk add 本地安装
```

## 订阅落地

订阅域名通常被墙，OpenClash 自带的下载会失败，需要经代理拉一次：

```sh
curl -H 'User-Agent: clash.meta' -o /etc/openclash/config/<name>.yaml '<订阅URL>'
/etc/openclash/core/clash_meta -t -d /etc/openclash -f /etc/openclash/config/<name>.yaml
uci set openclash.config.config_path='/etc/openclash/config/<name>.yaml'
uci commit openclash
```

OpenClash 启动时会生成同名运行配置 `/etc/openclash/<name>.yaml`（其中含 `secret` 与 `external-controller`）。

## API 只监听 LAN

默认生成 `external-controller: 0.0.0.0:9090`。改为只绑 LAN 地址：

```sh
# 备份后打补丁（升级 OpenClash 会被覆盖，需重打）
sed -i "s/'0.0.0.0:' + controller_port/'192.168.2.1:' + controller_port/" \
  /usr/share/openclash/yml_change.sh
sed -i 's/^external-controller: .*/external-controller: 192.168.2.1:9090/' \
  /etc/openclash/<name>.yaml
```

`secret` 由 OpenClash 自动生成，面板在运行时从运行配置里读取，不落盘到代码。

改完必须**真正重启内核**：`/etc/init.d/openclash restart` 有时不重建进程，稳妥做法是 `stop` → `pkill -f /etc/openclash/clash` → `start`。

## 手机面板

- 路径：`/www/cgi-bin/pwnodes`（ucode CGI，源码见 `scripts/pwnodes.uc`）
- 页签：概览 / 代理 / 节点 / 设置
- 数据源：`/proxies`、`/proxies/{name}/delay`、`/group/{name}/delay`、`PUT /proxies/{group}`
- 实测：58 节点一轮「测全部」约 3 秒；节点切换即时生效
- 延迟胶囊：≤0 显示「超时」，<200ms 绿、<500ms 黄、其余红


## 两套运行时并存

PassWall 与 OpenClash 可以同时装着，只启其中一个：

```sh
scripts/runtime-switch.sh openclash    # 停 PassWall、启 OpenClash，验证出口，失败回滚
scripts/runtime-switch.sh passwall     # 反向切换
```

面板也有两版，按当前运行时选一个装到 `/www/cgi-bin/pwnodes`：

| 运行时 | 面板源码 | 数据来源 |
|---|---|---|
| OpenClash | `scripts/pwnodes.uc`（ucode） | Clash API `/proxies`、`/group/{g}/delay`、`PUT /proxies/{g}` |
| PassWall | `scripts/pwnodes-passwall.sh`（shell） | PassWall 的 uci 与 sing-box；“当前节点”靠 netstat 推断，延迟为入口 TCP 握手 |

```sh
cp scripts/pwnodes.uc /www/cgi-bin/pwnodes && chmod 755 /www/cgi-bin/pwnodes          # OpenClash
cp scripts/pwnodes-passwall.sh /www/cgi-bin/pwnodes && chmod 755 /www/cgi-bin/pwnodes # PassWall
```

PassWall 版的局限（也是切到 OpenClash 的原因）：拿不到内核当前选中的节点，延迟数字只是端口握手，看着 2ms 实际可能只有 3~4 Mbps。

## 换订阅

```sh
/root/pw-sub-swap.sh '<新订阅URL>' [配置名]
```

流程：备份 → 经代理下载 → `mihomo -t` 校验 → 替换 → 重启 → 测出口 IP；失败自动回滚。

## 切回 PassWall

```sh
/etc/init.d/openclash stop && /etc/init.d/openclash disable
/etc/init.d/passwall start && /etc/init.d/passwall enable
```

## 踩过的坑

1. `uci set passwall.X.urltest_node="a b c"` 会把列表写成单个带空格的字符串，PassWall 的 Lua 生成器随后崩（`ut_node_id` nil）。要用 `uci add_list` 逐个加。
2. **Xray 类型节点不能放进 sing-box 的 `_urltest` 组**，会让生成器崩；只能单独绑定（走 nodesocks）。
3. apk 固件的内核是厂商自定义构建（`6.12.116~<hash>`），官方快照里的 `kmod-*` ABI 不匹配，Nikki 依赖的 `kmod-dummy` 装不上——这也是当时选 OpenClash 的原因。
4. `/etc/init.d/openclash stop` 会把 `openclash.config.enable` 置 0，之后 `start` 提示 “Now Disabled”；启动前先 `uci set openclash.config.enable='1'`。
5. 面板是 CGI，**必须自己输出 `Content-Type` 头**，否则 uhttpd 直接 502。
