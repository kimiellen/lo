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
            property int barHeight: 40
        }
    }

    readonly property string theme: data.theme === "latte" ? "latte" : "mocha"
    readonly property string language: data.language === "en" ? "en" : "zh"
    readonly property int barHeight: Math.max(28, Math.min(64, data.barHeight || 40))

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
