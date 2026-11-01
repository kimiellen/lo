pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.core
import qs.services

// 工作区用量环：窗口数分档配色，左键切换
Row {
    id: root

    spacing: 7

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

            width: 20
            height: 20

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.text
                opacity: cell.focused ? 0.85 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            UsageRing {
                anchors.centerIn: parent
                size: 15
                thickness: 2
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
