# vbc-Io

Hyprland 顶栏，纯 QML + Quickshell 0.3.2（Qt 6.12）。单进程常驻，Catppuccin 双主题、中英双语。

## 技术栈（已定，不轻易改）

- Quickshell 0.3.2（Arch 包），Qt 6.12，QML only，无 C++ 插件。
- 目标环境：Hyprland 0.57+、iwd（**无 NetworkManager**）、mihomo、PipeWire、UPower、bluez。
- HTTP 走 `curl` 子进程；系统采样走 `/proc`、`brightnessctl`；QML 内不发原生 HTTP。

## 运行与验证

```bash
# 部署目录是 ~/.config/lo（项目的运行副本），用 -p 直接指向它启动
qs -p ~/.config/lo      # 前台运行，看日志；改 QML 热重载
```

- **硬约束**：项目部署/运行目录是 `~/.config/lo`，应用配置目录是 `~/.config/vbc-io`（config.json / secrets.json）。
  **不要去 `~/.config/quickshell/` 下建软链或找配置**（已多次踩坑）。

- 验证以真机目视为准：启动无报错、顶栏出现、交互可用。
- 涉及数值的模块，必须与系统命令交叉核对（`top`、`free`、`df`、`pactl`、`brightnessctl`）。
- 提交前确认 `git status` 干净、无密钥/本地路径泄漏。

## 目录与职责

```
shell.qml      入口：ShellRoot，每屏一个 Bar + 面板宿主
core/          Theme（配色）、I18n（文案+日期格式）、Config（读写 config.json）、Format（数字/倒计时）
services/      所有外部数据与副作用，单例，无 UI 引用
components/    原子组件（UsageRing、StatusIcon…）
bar/           顶栏三区布局与 item
panels/        控制面板与各 tab
docs/specs/    spec.md 是事实源
```

## 代码风格红线

- `services/` 之外的任何文件不得执行命令、读文件、发请求；UI 只做绑定。
- 文案一律走 `I18n`，颜色一律走 `Theme`，禁止散落硬编码字符串与色值。
- 单例文件名与 `id` 用 PascalCase，属性 camelCase；QML 文件顶部写一行职责注释。
- 每个 QML 文件加 `pragma ComponentBehavior: Bound`（有 delegate 时必需）。
- 数值展示统一格式：百分比取整；货币保留 `total_balance` 原样；倒计时 `H`/`D` 缩写。
- 外部依赖失败时降级展示（`--`、灰环、隐藏），不允许抛错或阻塞 UI。

## 提交

- 一个里程碑一个 commit，message 用 `feat(scope): ...` / `fix(scope): ...`。
- spec 变更单独说明并先改 `docs/specs/topbar/spec.md`。
