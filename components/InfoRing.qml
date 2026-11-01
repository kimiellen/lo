pragma ComponentBehavior: Bound
import QtQuick
import qs.core

// 环形指标 + 悬浮明细：系统三环与状态环共用的原子组件
Item {
    id: root

    property real value: 0
    property color color: Theme.cpu
    property string letter: ""          // 环心字母，空则不显示
    property string title: ""           // hover 明细标题
    property string detail: ""          // hover 明细数值

    implicitWidth: ring.size
    implicitHeight: ring.size

    UsageRing {
        id: ring
        anchors.centerIn: parent
        value: root.value
        color: root.color
        centerText: root.letter
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Tooltip {
        targetItem: root
        title: root.title
        detail: root.detail
        visible: hover.containsMouse
    }
}
