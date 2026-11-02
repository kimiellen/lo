import QtQuick
import qs.core

// 空状态：模块不可用 / 列表为空时的居中提示
Item {
    id: root

    property string title: ""
    property string detail: ""

    implicitHeight: 96

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelTitleSize
            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.detail !== ""
            text: root.detail
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelTextSize
            renderType: Text.NativeRendering
        }
    }
}
