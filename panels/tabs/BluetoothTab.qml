pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 蓝牙 tab：适配器开关、限时扫描、已连/可用设备
Item {
    id: root

    signal closeRequested()

    implicitHeight: body.height

    Column {
        id: body
        width: root.width
        spacing: 6

        EmptyState {
            visible: !BlueZ.available
            width: parent.width
            title: I18n.t("panel.bt.unavailable")
        }

        // ---------------- 适配器 + 电源 ----------------
        Item {
            visible: BlueZ.available
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 80
                elide: Text.ElideRight
                text: BlueZ.adapter ? BlueZ.adapter.name : I18n.t("panel.bluetooth")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }

            ToggleSwitch {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: BlueZ.powered
                onToggled: BlueZ.setPowered(!BlueZ.powered)
            }
        }

        EmptyState {
            visible: BlueZ.available && !BlueZ.powered
            width: parent.width
            title: I18n.t("panel.bt.off")
        }

        // ---------------- 扫描 ----------------
        Item {
            visible: BlueZ.powered
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: BlueZ.discovering ? I18n.t("panel.bt.discovering") : ""
                color: Theme.overlay
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.bt.search")
                color: BlueZ.discovering ? Theme.overlay : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BlueZ.startDiscovery()
                }
            }
        }

        // ---------------- 已连设备 ----------------
        Text {
            visible: BlueZ.powered && BlueZ.connectedDevices.length > 0
            text: I18n.t("panel.connected")
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        Repeater {
            model: BlueZ.powered ? BlueZ.connectedDevices : []
            delegate: DeviceRow {}
        }

        // ---------------- 可用设备 ----------------
        Text {
            visible: BlueZ.powered && BlueZ.availableDevices.length > 0
            text: I18n.t("panel.bt.available")
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        Repeater {
            model: BlueZ.powered ? BlueZ.availableDevices : []
            delegate: DeviceRow {}
        }

        EmptyState {
            visible: BlueZ.powered && BlueZ.connectedDevices.length === 0
                && BlueZ.availableDevices.length === 0
            width: parent.width
            title: I18n.t("panel.bt.empty")
        }
    }
}
