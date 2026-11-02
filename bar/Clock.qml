import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// 中区时钟：SystemClock 每次变化按当前语言重排文案
Item {
    id: root

    implicitWidth: label.implicitWidth
    implicitHeight: Metrics.workspaceCell

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: label
        anchors.centerIn: parent

        text: I18n.formatClock(clock.date)
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Metrics.textSize
        font.letterSpacing: 0.3
        renderType: Text.NativeRendering
    }
}
