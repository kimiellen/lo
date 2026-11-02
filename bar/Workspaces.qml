pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.core
import qs.services

// 工作区用量环：窗口数分档配色，左键切换
Row {
    id: root

    spacing: 8

    // 真实设备像素比：分段缩放下 Screen.devicePixelRatio 只返回整数
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

    readonly property var toplevels: Hyprland.toplevels.values || []

    // 至少 5 个槽位；存在更靠后的工作区时按最大 id 扩展
    readonly property int slotCount: {
        let maxId = 5;
        const list = Hyprland.workspaces.values || [];
        for (let i = 0; i < list.length; ++i) {
            const w = list[i];
            if (w && w.id > maxId)
                maxId = w.id;
        }
        return maxId;
    }

    function windowsFor(id) {
        let count = 0;
        for (let i = 0; i < toplevels.length; ++i) {
            const t = toplevels[i];
            if (t && t.workspace && t.workspace.id === id)
                ++count;
        }
        return count;
    }

    Repeater {
        model: root.slotCount

        delegate: Item {
            id: cell
            required property int index
            readonly property int wsId: index + 1
            readonly property int windows: root.windowsFor(wsId)
            readonly property bool focused: Hypr.focusedWorkspaceId === wsId

            width: Metrics.workspaceCell
            height: Metrics.workspaceCell

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                // 1px 描边按设备像素吸附，1.6 缩放下才是 2 设备像素的均匀细线
                border.width: Metrics.snap(1, root.dpr)
                border.color: Theme.text
                opacity: cell.focused ? 0.85 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            UsageRing {
                anchors.centerIn: parent
                size: Metrics.workspaceRing
                thickness: Metrics.ringThickness
                value: Format.ratio(cell.windows, 5)
                color: Theme.workspaceColor(cell.windows)
                trackColor: Theme.track
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hypr.focusWorkspace(cell.wsId)
            }
        }
    }
}
