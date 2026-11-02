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
            property int barHeight: 44
            // mihomo 配置读取失败时的回退；secret 只供 Proxy 内存使用，不写日志
            property string mihomoConfigPath: ""
            property string mihomoController: ""
            property string mihomoSecret: ""
            // 额度密钥文件；留空则用配置目录下的 secrets.json
            property string secretsPath: ""
        }
    }

    // 首次构造时同步等待配置读完：主题/语言必须在第一帧前就是最终值，
    // 否则环等 Shape 元素会以默认 Mocha 绘制且不随启动后的主题变化重绘。
    Component.onCompleted: file.waitForJob()

    readonly property string theme: data.theme === "latte" ? "latte" : "mocha"
    readonly property string language: data.language === "en" ? "en" : "zh"
    // 卡片高度；顶栏窗口总高 = Hypr.gapsOut + barHeight（顶部间隙 + 卡片）
    readonly property int barHeight: Math.max(28, Math.min(64, data.barHeight || 44))
    readonly property string mihomoConfigPath: data.mihomoConfigPath !== ""
        ? data.mihomoConfigPath : "/etc/mihomo/config.yaml"
    readonly property string mihomoController: data.mihomoController
    readonly property string mihomoSecret: data.mihomoSecret

    // secrets.json 只用于额度 key；默认与 config.json 同目录，便于 VBCIO_CONFIG_DIR 隔离测试
    readonly property string secretsPath: data.secretsPath !== ""
        ? data.secretsPath : (configDir + "/secrets.json")

    function setTheme(name) {
        data.theme = name === "latte" ? "latte" : "mocha"
        file.writeAdapter()
    }

    function toggleTheme() {
        setTheme(theme === "mocha" ? "latte" : "mocha")
    }

    function setLanguage(name) {
        data.language = name === "en" ? "en" : "zh"
        file.writeAdapter()
    }

    function toggleLanguage() {
        setLanguage(language === "zh" ? "en" : "zh")
    }
}
