import QtQuick
import Quickshell
import Quickshell.Io
import qs.bar
import qs.core
import qs.panels
import qs.services

// 入口：每块屏幕一个顶栏 + 一个控制面板宿主，并通过 IPC 暴露主题/语言/工作区操作
ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Item {
            id: screenRoot
            required property var modelData

            Bar {
                screen: screenRoot.modelData
                onPanelRequested: function (tab) {
                    panel.openPanel(tab);
                }
                onNoiseRequested: noisePopup.togglePopup()
            }

            Panel {
                id: panel
                screen: screenRoot.modelData
            }

            NoisePopup {
                id: noisePopup
                screen: screenRoot.modelData
            }
        }
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
