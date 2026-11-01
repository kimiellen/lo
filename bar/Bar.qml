import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core

// 顶栏窗口：top layer、独占高度、三区布局（中区绝对居中）
PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    color: Theme.bg
    implicitHeight: Config.barHeight
    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "vbc-io-bar"
    WlrLayershell.exclusiveZone: Config.barHeight
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // 左区：工作区 → 系统三环 → 额度
    Row {
        id: leftSection
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
        spacing: 14

        Workspaces {}
    }

    // 中区：日期 - 时间 - 星期
    Clock {
        anchors.centerIn: parent
    }

    // 右区：状态环 → 状态图标
    Row {
        id: rightSection
        anchors {
            right: parent.right
            rightMargin: 14
            verticalCenter: parent.verticalCenter
        }
        spacing: 14
    }

    // 与桌面内容的分隔线
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.trackDim
        opacity: 0.55
    }
}
