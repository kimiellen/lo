import QtQuick
import Quickshell
import Quickshell.Io
import qs.bar
import qs.core
import qs.services

// 入口：每块屏幕一个顶栏，并通过 IPC 暴露主题/语言/工作区操作
ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Bar {}
    }

    IpcHandler {
        target: "theme"
        function toggle(): void {
            Config.toggleTheme();
        }
        function set(name: string): void {
            Config.setTheme(name);
        }
    }

    IpcHandler {
        target: "language"
        function toggle(): void {
            Config.toggleLanguage();
        }
        function set(name: string): void {
            Config.setLanguage(name);
        }
    }

    IpcHandler {
        target: "workspaces"
        function focus(id: string): void {
            Hypr.focusWorkspace(parseInt(id));
        }
    }
}
