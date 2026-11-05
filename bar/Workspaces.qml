pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.core
import qs.services

// 工作区五段 sky 色环：非当前工作区点击切换（当前工作区无操作）。
Row {
    id: root

    spacing: 8

    // 真实设备像素比：分段缩放下 Screen.devicePixelRatio 只返回整数
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

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

    Repeater {
        model: root.slotCount

        delegate: Item {
            id: cell
            required property int index
            readonly property int wsId: index + 1
            readonly property var workspaceData: Hypr.workspaceModel(wsId)
            readonly property int windows: workspaceData.windows.length
            readonly property bool focused: Hypr.focusedWorkspaceId === wsId

            width: Metrics.workspaceCell
            height: Metrics.workspaceCell

            // 选中工作区外圈：peach、直径 26、线宽 2，居中于 30px 槽位
            Rectangle {
                anchors.centerIn: parent
                width: Metrics.snap(Metrics.workspaceFocusRing, root.dpr)
                height: width
                radius: width / 2
                color: "transparent"
                border.width: Metrics.snap(Metrics.workspaceFocusRingThickness, root.dpr)
                border.color: Theme.workspaceFocus
                opacity: cell.focused ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            // 环小于普通环，在 30px 槽位内上下居中；槽位整体再由卡片垂直居中
            WorkspaceRing {
                anchors.centerIn: parent
                size: Metrics.workspaceRing
                thickness: Metrics.workspaceRingThickness
                windows: cell.workspaceData.windows
                activeIndex: cell.workspaceData.activeIndex
                trackColor: Theme.ringTrack
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: cell.focused ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (!cell.focused)
                        Hypr.focusWorkspace(cell.wsId);
                }
            }

            Tooltip {
                targetItem: cell
                visible: mouse.containsMouse
                title: I18n.t("tooltip.workspaces") + " " + cell.wsId
                detail: String(cell.windows)
            }
        }
    }
}
