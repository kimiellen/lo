pragma ComponentBehavior: Bound
import QtQuick
import qs.core
import qs.services

// 蓝牙设备行：名称 + 电量/配对标记 + 连接/断开动作
Item {
    id: root

    required property var modelData      // BluetoothDevice（由 Repeater 注入）
    readonly property var device: modelData
    readonly property string label: device ? (device.name || device.deviceName || device.address || "") : ""

    width: parent ? parent.width : 0
    height: 28

    Text {
        id: deviceName
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - meta.width - 10
        elide: Text.ElideRight
        text: root.label
        color: root.device && root.device.connected ? Theme.success : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Metrics.panelTitleSize
        renderType: Text.NativeRendering
    }

    Row {
        id: meta
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            // BlueZ 对部分设备报告 0（未知），不显示
            visible: root.device && root.device.batteryAvailable && root.device.battery > 0
            text: root.device && root.device.batteryAvailable && root.device.battery > 0
                ? I18n.t("panel.bt.battery") + " " + Math.round(root.device.battery * 100) + "%"
                : ""
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelMetaSize
            renderType: Text.NativeRendering
        }

        Text {
            visible: root.device && !root.device.connected && root.device.paired
            text: I18n.t("panel.bt.paired")
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelMetaSize
            renderType: Text.NativeRendering
        }

        Text {
            text: root.device && root.device.connected
                ? I18n.t("panel.disconnect") : I18n.t("panel.connect")
            color: root.device && root.device.connected ? Theme.subtext : Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelTextSize
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: BlueZ.toggleDevice(root.device)
    }
}
