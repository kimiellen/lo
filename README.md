<div align="center">
  <img src="assets/lo.svg" alt="lo logo" width="96" height="96">
  <h1>lo</h1>
  <p><strong>A ring-first Hyprland top bar — system, AI quota and network in one Quickshell process</strong></p>
  <p>
    <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a>
  </p>
  <p>
    <a href="https://github.com/kimiellen/lo/releases/latest">
      <img src="https://img.shields.io/github/v/release/kimiellen/lo?label=release&color=b4befe" alt="Latest release">
    </a>
    <img src="https://img.shields.io/badge/license-MIT-a6e3a1" alt="MIT License">
    <img src="https://img.shields.io/badge/Quickshell-0.3.2-89b4fa" alt="Quickshell 0.3.2">
    <img src="https://img.shields.io/badge/Qt-6.12-cba6f7" alt="Qt 6.12">
    <img src="https://img.shields.io/badge/Hyprland-0.57%2B-f9e2af" alt="Hyprland 0.57+">
    <img src="https://img.shields.io/badge/QML-only-f2cdcd" alt="QML only">
  </p>
</div>

![lo top bar](docs/assets/bar.png)

lo is a Hyprland top bar written entirely in QML on **Quickshell 0.3.2 / Qt 6.12**. It runs as one long-lived process, turns usage into rings, and keeps the things you actually glance at within reach:

1. **System at a glance** — workspaces, CPU / memory / disk, volume / brightness / battery, all as arcs that show their exact value in the ring or on hover
2. **AI quota on the bar** — Kimi Code 7-day and 5-hour windows with their own reset countdowns, plus your DeepSeek balance
3. **Network and proxy** — mihomo mode / node / TUN, iwd Wi-Fi and BlueZ in a single control panel
4. **Your theme, your language** — Catppuccin Mocha / Latte / auto and 中文 / English, switched live and persisted

Nothing on the bar is allowed to break the bar: a missing API key, a stopped mihomo, a failed `df` or an absent battery only greys out that one item.

## Features

### Left cluster — system at a glance

![Left cluster: workspaces, system rings, Kimi quota, DeepSeek balance](docs/assets/bar-left.png)

#### Workspaces

- One ring per workspace, at least five slots and more when you create higher workspace IDs
- The arc fills with the window count (`min(windows, 5) / 5`) and changes colour at four tiers: empty, 1–2, 3–4, 5+
- The focused workspace is outlined; left-click jumps to it through Hyprland's Lua API
- Workspaces appear and disappear with Hyprland events — no polling, no restart

#### CPU / memory / disk

- Three rings lettered `C`, `M`, `D`; hover for the exact percentage and, for memory and disk, `used / total` in GiB
- CPU is the delta of two `/proc/stat` samples every second; memory reads `MemAvailable` every two seconds; disk measures `/` every 30 seconds with the same accounting as `df`
- Clicking any ring opens the control panel; if a source disappears the ring turns grey and shows `--` instead of freezing on a stale value

#### Kimi Code quota

- Fetches `GET https://api.kimi.com/coding/v1/usages` every 60 seconds and renders the **windows the API actually returns** — no hard-coded window list
- Up to two rings, picked in a fixed order: **7-day first, then 5-hour**, with monthly / code windows as a fallback so a changed API never hides the quota
- Each ring carries its own reset countdown in the same colour: days for the weekly window (`1D`, `3D`), hours for the session window (`3H`)
- Hover shows the window name, percentage and reset time; 7-day uses sapphire, 5-hour uses flamingo
- The parser accepts the current `usages` shape, the older `usage` shape and `limits[]`, plus `used_ratio`, `used/limit` and `remaining/limit`
- Key comes from `KIMI_CODING_API_KEY` or `~/.config/vbc-io/secrets.json` (`600`, `400` also accepted); missing key, 401, timeout or garbage all degrade to a grey `--` ring and recover on the next poll

#### DeepSeek balance

- Fetches `GET https://api.deepseek.com/user/balance` every five minutes
- A balance has no denominator, so it is deliberately **not** a ring: the official DeepSeek vector mark plus the amount, with `¥` / `$` taken from the API currency
- `is_available: false` keeps the number but switches it to the warning colour; failures show `--`

### Center — clock

- One card pinned to the **exact horizontal centre** of the screen (`anchors.horizontalCenter`, not an equal-width approximation)
- Bilingual, with the date order and 12/24-hour clock following the language:
  - 中文: `11月1日 - 21:26 - 周一`
  - English: `1 Nov - 09:26 PM - Mon`
- Updates every second through `SystemClock`

### Right cluster — status card and status icons

![Right cluster: theme, microphone, volume, brightness, battery and the three status icons](docs/assets/bar-right.png)

**Status card**

- **Theme button** — cycles `dark → light → auto`; `auto` picks light between 06:00 and 18:00 and dark otherwise, and follows the clock while the bar runs
- **Microphone** — mutes / unmutes the default input; the glyph gains a slash and turns grey when muted
- **Volume** — self-drawn speaker with 1–3 sound waves matching the level; click the icon or ring to mute, scroll either one to change volume by 5%
- **Brightness** — sun glyph plus ring; scroll to change by 5%, with the value rounded to the same integer shown elsewhere
- **Battery** — glyph fills continuously and shows a bolt while charging; the arc and glyph are coloured by tier (`<20%` red, `20–60%` yellow, `≥60%` green, charging green); hover shows percent, remaining time and wattage
- Missing hardware hides the module instead of showing a broken one (no PipeWire → no volume module, no backlight → no brightness)

**Status icons**

- Proxy, Wi-Fi and Bluetooth, each opening the panel on its own tab
- Wi-Fi is green when connected, grey when off; Bluetooth accents only while a device is connected
- The proxy icon is **derived from the current mode**: globe plus a list badge for rule, a ring for global, an arrow for direct — and a plain grey globe when mihomo is unavailable

| Rule | Global | Direct |
|---|---|---|
| ![rule mode](docs/assets/mode-rule.png) | ![global mode](docs/assets/mode-global.png) | ![direct mode](docs/assets/mode-direct.png) |

## Control panel

The panel is a 400 px overlay anchored under the right edge of the bar, with three tabs. `Esc` or a click outside closes it, and it takes exclusive keyboard focus while open so the Wi-Fi password field can be typed into. Opening a tab refreshes that tab's data immediately.

### Proxy

![Proxy tab](docs/assets/panel-proxy.en.png)

- Shows mihomo's mode, the resolved node, its policy group and whether TUN is on
- Mode buttons call `PATCH /configs` with `{"mode": ...}`; mihomo 1.19.33 acknowledges `PUT` with 204 but does not apply it, so `PATCH` is used deliberately
- The current node is resolved recursively: `GLOBAL.now` in global mode, the largest policy group's `now` in rule mode, `DIRECT` in direct mode
- mihomo details are read from `/etc/mihomo/config.yaml` (`external-controller` and `secret`), falling back to `config.json`
- A dead controller, a missing secret and a bad secret each get their own message instead of a blank tab

### Network

![Network tab](docs/assets/panel-network.en.png)

- Wi-Fi power switch, connected network with IP and signal, and a scan button
- Saved or open networks connect directly; WPA networks open an inline password field — the panel keeps keyboard focus exactly for this
- Unsupported security types and failed connections report inline, without throwing
- A read-only link table (`ip -br addr`) lists every interface with state and addresses, refreshed every five seconds

### Bluetooth

![Bluetooth tab](docs/assets/panel-bluetooth.en.png)

- Adapter power switch, connected devices with battery percentage, and available / paired devices
- Search starts a 15-second discovery and stops automatically, because BlueZ has no manual refresh
- Connect and disconnect act on the device directly; the list re-sorts by name as states change

## Themes and languages

|  | Mocha (dark) | Latte (light) |
|---|---|---|
| Base | `#1e1e2e` | `#eff1f5` |
| Text | `#cdd6f4` | `#4c4f69` |
| Accent | lavender `#b4befe` | lavender `#7287fd` |
| Rings | blue / mauve / teal / green / yellow | same roles |

![Latte theme with the Chinese UI](docs/assets/panel-proxy.zh.png)

- Every visible string goes through `I18n`; every colour goes through `Theme` — there are no hard-coded labels or hex values in the bar
- Theme and language are written to `~/.config/vbc-io/config.json` and restored before the first frame, so rings never flash in the wrong palette on startup
- Both can also be driven from the shell with IPC (see below)

## Interactions

| Element | Left click | Scroll | Hover |
|---|---|---|---|
| Workspace ring | switch to that workspace | — | — |
| CPU / memory / disk ring | open the control panel | — | percentage, and `used / total` for M and D |
| Kimi quota ring / countdown | — | — | window, percentage, reset time |
| DeepSeek balance | — | — | amount or the failure reason |
| Theme button | dark → light → auto | — | current mode |
| Microphone | toggle input mute | — | muted / on |
| Volume icon or ring | toggle mute | ±5% | percentage, or `Muted` |
| Brightness icon or ring | — | ±5% | percentage |
| Battery icon or ring | — | — | percentage, remaining time, wattage |
| Status icon (proxy / Wi-Fi / Bluetooth) | open its panel tab | — | mode and node, SSID, connected device count |
| Clock | — | — | — |

## Requirements

| Requirement | Version | Notes |
|---|---|---|
| Hyprland | 0.57+ | Tested on 0.57.0; workspace switching goes through the Lua API |
| Quickshell | 0.3.2 | Arch package; Qt 6.12 |
| PipeWire | any | Volume and microphone modules; `pactl` not required |
| UPower | any | Battery module |
| BlueZ | any | Bluetooth tab |
| iwd | any | Wi-Fi tab — **NetworkManager is not used** |
| `brightnessctl` | any | Brightness module |
| `curl` | any | Kimi and DeepSeek requests |
| mihomo | 1.19+ | Optional; proxy tab and status icon |
| JetBrainsMono Nerd Font | any | Status glyphs; Noto Sans CJK for Chinese |

## Installation

> **Naming:** the project is `lo`, but the Quickshell config identifier stays `vbc-io` (`qs -c vbc-io`, `~/.config/vbc-io/`). Renaming it would break existing installs, so it is intentionally stable.

### 1. Dependencies

On Arch:

```bash
sudo pacman -S quickshell pipewire upower bluez bluez-utils iwd brightnessctl curl
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts-cjk
```

mihomo is optional. Install it only if you want the proxy tab and the derived proxy icon.

### 2. Clone into the Quickshell config directory

```bash
git clone https://github.com/kimiellen/lo.git ~/.config/quickshell/vbc-io
```

The directory name must be `vbc-io`: Quickshell derives the `qs.*` import namespace from it, and `qs -c vbc-io` looks there.

### 3. API keys

Create `~/.config/vbc-io/secrets.json`:

```json
{
  "kimi_api_key": "your-kimi-coding-key",
  "deepseek_api_key": "your-deepseek-key"
}
```

```bash
chmod 600 ~/.config/vbc-io/secrets.json
```

Only `600` and `400` are accepted; anything looser is refused and the quota modules stay grey. Environment variables `KIMI_CODING_API_KEY` and `DEEPSEEK_API_KEY` take precedence and are the better choice if you already export them.

### 4. Run it

```bash
qs -c vbc-io
```

The bar appears immediately; QML edits hot-reload while it runs. For autostart, add to `~/.config/hypr/hyprland.conf`:

```ini
exec-once = qs -c vbc-io
```

### Updating

```bash
cd ~/.config/quickshell/vbc-io
git pull
```

Quickshell picks up the new QML on the next reload; no build step exists.

## Configuration

`~/.config/vbc-io/config.json` is written whenever a setting changes. Every key is optional:

| Key | Default | Meaning |
|---|---|---|
| `theme` | `"mocha"` | `mocha`, `latte` or `auto` (`auto` = light 06:00–18:00) |
| `language` | `"zh"` | `"zh"` or `"en"` |
| `barHeight` | `38` | Card height, clamped to 28–64; the bar window adds margins on top |
| `mihomoConfigPath` | `/etc/mihomo/config.yaml` | Where to read `external-controller` and `secret` |
| `mihomoController` | `""` | Fallback controller URL when the config file is unreadable |
| `mihomoSecret` | `""` | Fallback secret; kept in memory only |
| `secretsPath` | `<config dir>/secrets.json` | Override the quota key file |

```json
{
  "theme": "auto",
  "language": "en",
  "barHeight": 38,
  "mihomoConfigPath": "/etc/mihomo/config.yaml",
  "mihomoController": "",
  "mihomoSecret": "",
  "secretsPath": ""
}
```

Set `VBCIO_CONFIG_DIR` to point the whole config directory somewhere else — useful for trying a theme or a language without touching your daily setup.

## IPC

```bash
qs ipc call theme toggle            # dark → light → auto
qs ipc call theme set latte         # mocha / latte / auto
qs ipc call language toggle         # zh ↔ en
qs ipc call language set en
qs ipc call workspaces focus 3      # jump to workspace 3
```

Handy for keybindings:

```ini
bind = SUPER, T, exec, qs ipc call theme toggle
bind = SUPER, L, exec, qs ipc call language toggle
```

## How it works

```text
lo/
├── shell.qml            # ShellRoot: one Bar + one Panel per screen, plus IPC
├── core/                # Theme, I18n, Config, Format, Metrics — no side effects
├── services/            # every external read/write: Hypr, SystemStats, Audio,
│                        #   Brightness, Power, Wifi, Link, BlueZ, Proxy,
│                        #   QuotaKimi, QuotaDeepSeek, Secrets
├── components/          # UsageRing, InfoRing, StatusGlyph, ProxyGlyph, Tooltip…
├── bar/                 # three-zone layout and its items
├── panels/              # Panel host and the proxy / network / bluetooth tabs
└── docs/specs/topbar/   # spec.md is the source of truth
```

Two rules keep the codebase honest:

- **UI never performs side effects.** Commands, file reads and HTTP live only in `services/`; the bar and panels only bind to properties.
- **No magic values in views.** Colours come from `Theme`, strings from `I18n`, sizes from `Metrics`, numbers from `Format`.

### Data sources

| Module | Source | Refresh | When unavailable |
|---|---|---|---|
| Workspaces | `Quickshell.Hyprland` | events | hidden |
| CPU | `/proc/stat` (two samples) | 1 s | `--` |
| Memory | `/proc/meminfo` (`MemAvailable`) | 2 s | `--` |
| Disk | `df -P /` | 30 s | `--` |
| Volume / mic | `Quickshell.Services.Pipewire` | events | hidden |
| Brightness | `brightnessctl -m` | 1 s | hidden |
| Battery | UPower `displayDevice` | events | hidden |
| Kimi quota | `api.kimi.com/coding/v1/usages` | 60 s | grey `--` |
| DeepSeek balance | `api.deepseek.com/user/balance` | 5 min | `--` |
| Proxy | mihomo `/configs`, `/proxies` | 5 s | grey icon |
| Wi-Fi | `iwctl` | 10 s + on open | offline icon |
| Links | `ip -br addr` | 5 s | empty table |
| Bluetooth | `Quickshell.Bluetooth` | events | hidden |

HTTP is always a `curl` child process with `--max-time 8`. Parsing failures are logged once and degrade the module; they never throw into the UI.

### Degradation, by design

- A missing key shows `--` and a grey ring, and the module recovers on the next poll once the key is back — no restart
- `secrets.json` with permissions wider than `600/400` is refused rather than read
- A dead mihomo controller, a wrong secret and a missing config each get a specific message
- Missing hardware hides the module; it does not render a zero
- The control panel's height follows its content, clamped between 140 and 640 px

## Visual system

Everything is Catppuccin, with semantic roles instead of raw colours:

| Role | Mocha | Latte | Used by |
|---|---|---|---|
| `cpu` | blue `#89b4fa` | blue `#1e66f5` | CPU ring |
| `memory` | mauve `#cba6f7` | mauve `#8839ef` | memory ring |
| `disk` | teal `#94e2d5` | teal `#179299` | disk ring |
| `volume` | green `#a6e3a1` | green `#40a02b` | volume ring |
| `brightness` | yellow `#f9e2af` | yellow `#df8e1d` | brightness ring |
| battery tier | red / yellow / green | same | battery ring and glyph |
| `kimiWeek` | sapphire `#74c7ec` | sapphire `#209fb5` | 7-day quota |
| `kimiSession` | flamingo `#f2cdcd` | flamingo `#dd7878` | 5-hour quota |
| `deepseekBrand` | `#4d6bfe` | `#4d6bfe` | DeepSeek mark |
| workspace tier | overlay / blue / yellow / red | same | workspace rings |

Geometry is a small, fixed vocabulary:

| Token | Value |
|---|---|
| Card | 38 px tall, radius 18, 10 px horizontal padding |
| Ring | 26 px outer diameter, 3 px stroke |
| Workspace | 26 px slot, 20 px ring |
| Text | 15 px everywhere; ring centre fixed at 15 px |
| Bar margins | 15 px left/right, 12 px top/bottom, 8 px between cards |
| Panel | 400 px wide, radius 12, 12 px padding, 30 px tabs |

At fractional scaling a 26 px ring lands on 41.6 device pixels, so the bar **snaps geometry to device pixels**: card height, margins, gaps, ring diameters and 1 px borders are all rounded to whole device pixels (`Metrics.snap` / `snapEven`). The result is a crisp 1 px outline at 1.6× instead of a blurred one.

## Docs

The authoritative, detailed specification lives in the repo:

- [Top bar spec](docs/specs/topbar/spec.md) — layout, visual rules, data contracts, risks
- [Milestone archive](docs/specs/topbar/tasks-archive.md) — what was built and how each milestone was verified

## Development

```bash
ln -sfn "$PWD" ~/.config/quickshell/vbc-io   # work from this checkout
qs -c vbc-io                                 # run in the foreground, read the logs
```

- No build step and no C++: QML reloads on save while the process runs
- `VBCIO_CONFIG_DIR=$PWD/.dev/config qs -c vbc-io` gives an isolated config, useful for testing themes and languages without touching `~/.config`
- Changes to the spec go through `docs/specs/topbar/spec.md` first, then the code

## Non-goals

Notification centre, media controls, temperature / GPU, OBS status, input-method indicator, auto-hide, per-monitor layouts and a TUN toggle are intentionally out of scope.

## License

[MIT](LICENSE) © 2026 kimiellen
