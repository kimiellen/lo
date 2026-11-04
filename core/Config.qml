pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// 应用配置：~/.config/vbc-io/config.json（可用 VBCIO_CONFIG_DIR 覆盖目录）
Singleton {
    id: root

    readonly property string configDir: Quickshell.env("VBCIO_CONFIG_DIR") || (Quickshell.env("HOME") + "/.config/vbc-io")
    readonly property string configPath: configDir + "/config.json"

    // 首次启动目录可能不存在，先建好再让 FileView 落盘
    Process {
        command: ["mkdir", "-p", root.configDir]
        running: true
    }

    FileView {
        id: file
        path: root.configPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        adapter: JsonAdapter {
            id: data
            property string theme: "mocha"
            property string language: "zh"
            property int barHeight: 35
            // mihomo 配置读取失败时的回退；secret 只供 Proxy 内存使用，不写日志
            property string mihomoConfigPath: ""
            property string mihomoController: ""
            property string mihomoSecret: ""
            // 额度密钥文件；留空则用配置目录下的 secrets.json
            property string secretsPath: ""
            // Hyprland class/app_id → Catppuccin 颜色名；只保存显式选择，缺省即 blue
            property var workspaceAppColors: ({})
        }
    }

    // 首次构造时同步等待配置读完：主题/语言必须在第一帧前就是最终值，
    // 否则环等 Shape 元素会以默认 Mocha 绘制且不随启动后的主题变化重绘。
    Component.onCompleted: file.waitForJob()

    readonly property string language: data.language === "en" ? "en" : "zh"

    // 主题三态：mocha(dark) / latte(light) / auto；auto 在 06:00–18:00 用 light
    property int hour: new Date().getHours()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.hour = new Date().getHours()
    }

    readonly property string themeMode: data.theme === "latte" ? "latte"
        : (data.theme === "auto" ? "auto" : "mocha")
    readonly property string themeName: themeMode === "mocha" ? "dark"
        : (themeMode === "latte" ? "light" : "auto")
    readonly property string effectiveTheme: themeMode === "auto"
        ? (hour >= 6 && hour < 18 ? "latte" : "mocha")
        : themeMode

    // 卡片高度；顶栏窗口总高 = 上下边距 + barHeight + 底部补偿（见 Bar.qml）
    readonly property int barHeight: Math.max(28, Math.min(64, data.barHeight || 35))
    readonly property string mihomoConfigPath: data.mihomoConfigPath !== ""
        ? data.mihomoConfigPath : "/etc/mihomo/config.yaml"
    readonly property string mihomoController: data.mihomoController
    readonly property string mihomoSecret: data.mihomoSecret

    // secrets.json 只用于额度 key；默认与 config.json 同目录，便于 VBCIO_CONFIG_DIR 隔离测试
    readonly property string secretsPath: data.secretsPath !== ""
        ? data.secretsPath : (configDir + "/secrets.json")

    // blue 是未配置窗口的默认色，red 专用于可见起点半径线，因此都不出现在编辑选项中。
    readonly property var workspaceSelectableColors: [
        "rosewater", "flamingo", "pink", "mauve", "maroon", "peach",
        "yellow", "green", "teal", "sky", "sapphire", "lavender"
    ]

    function workspaceAppColorName(appKey) {
        if (!appKey)
            return "blue";
        const colors = data.workspaceAppColors || ({});
        const name = colors[appKey];
        return workspaceSelectableColors.indexOf(name) >= 0 ? name : "blue";
    }

    function setWorkspaceAppColor(appKey, name) {
        if (!appKey || workspaceSelectableColors.indexOf(name) < 0)
            return;
        const colors = data.workspaceAppColors || ({});
        if (colors[appKey] === name)
            return;
        // 整体替换以触发 JsonAdapter/QML 绑定更新；FileView 负责立即落盘。
        const next = Object.assign({}, colors);
        next[appKey] = name;
        data.workspaceAppColors = next;
        file.writeAdapter();
    }

    function setTheme(name) {
        data.theme = (name === "latte" || name === "light") ? "latte"
            : (name === "auto" ? "auto" : "mocha")
        file.writeAdapter()
    }

    // 主题按钮：dark → light → auto → dark
    function cycleTheme() {
        const order = ["mocha", "latte", "auto"]
        setTheme(order[(order.indexOf(themeMode) + 1) % order.length])
    }

    // IPC toggle 沿用旧名字，语义改为三态循环
    function toggleTheme() {
        cycleTheme()
    }

    function setLanguage(name) {
        data.language = name === "en" ? "en" : "zh"
        file.writeAdapter()
    }

    function toggleLanguage() {
        setLanguage(language === "zh" ? "en" : "zh")
    }
}
