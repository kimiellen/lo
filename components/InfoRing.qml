pragma ComponentBehavior: Bound
import QtQuick
import qs.core

// 环形指标 + 悬浮明细：系统三环与状态环共用的原子组件
Item {
    id: root

    property real value: 0
    property color color: Theme.cpu
    property string letter: ""          // 环心字母/数字，空则不显示
    property real letterSize: Metrics.ringLetterSize
    property real size: Metrics.ringSize
    property real thickness: Metrics.ringThickness
    property string title: ""           // hover 明细标题
    property string detail: ""          // hover 明细数值
    property bool interactive: false    // 左键可点击（手型指针）
    property bool wheelEnabled: false   // 滚轮可调节

    signal clicked()
    signal wheeled(int direction)       // +1 上滚 / -1 下滚

    implicitWidth: root.size
    implicitHeight: root.size

    UsageRing {
        id: ring
        anchors.centerIn: parent
        size: root.size
        thickness: root.thickness
        value: root.value
        color: root.color
        centerText: root.letter
        centerFontSize: root.letterSize
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: function () {
            if (root.interactive)
                root.clicked();
        }

        onWheel: function (wheel) {
            if (!root.wheelEnabled || wheel.angleDelta.y === 0)
                return;
            root.wheeled(wheel.angleDelta.y > 0 ? 1 : -1);
            wheel.accepted = true;
        }
    }

    Tooltip {
        targetItem: root
        title: root.title
        detail: root.detail
        visible: hover.containsMouse
    }
}
