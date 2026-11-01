import QtQuick
import qs.core

// 开关：面板内 Wi-Fi / 蓝牙电源切换
Item {
    id: root

    property bool checked: false

    signal toggled()

    implicitWidth: 32
    implicitHeight: 18

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Theme.track

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Rectangle {
        y: 2
        width: 14
        height: 14
        radius: 7
        x: root.checked ? root.width - width - 2 : 2
        color: root.checked ? Theme.bg : Theme.overlay

        Behavior on x {
            NumberAnimation { duration: 120 }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
