pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.core
import qs.services

// 工作区五段应用色环：非当前工作区点击切换，当前工作区点击打开应用颜色编辑。
Row {
    id: root

    signal panelRequested()

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

            WorkspaceRing {
                anchors.centerIn: parent
                size: Metrics.workspaceRing
                thickness: Metrics.workspaceRingThickness
                windows: cell.workspaceData.windows
                activeIndex: cell.workspaceData.activeIndex
                trackColor: Theme.track
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (cell.focused)
                        root.panelRequested();
                    else
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
