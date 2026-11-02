import QtQuick
import QtQuick.Shapes
import qs.core

// 环形用量图标：外轨 + 进度弧（Shape/PathAngleArc，缩放安全）
Item {
    id: root

    property real value: 0              // 0..1
    property color color: Theme.cpu
    property color trackColor: Theme.trackDim
    property real size: Metrics.ringSize
    property real thickness: Metrics.ringThickness
    property real startAngle: -90
    property bool showTrack: true
    property string centerText: ""      // 环心文字（字母/数字），空则不显示
    property real centerFontSize: Metrics.ringLetterSize

    implicitWidth: size
    implicitHeight: size

    readonly property real _center: size / 2
    readonly property real _radius: Math.max(0.5, (size - thickness) / 2)
    readonly property real _sweep: Format.clamp01(value) * 360

    Shape {
        anchors.fill: parent
        asynchronous: false

        ShapePath {
            strokeColor: root.showTrack ? root.trackColor : "transparent"
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root._center
                centerY: root._center
                radiusX: root._radius
                radiusY: root._radius
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        ShapePath {
            strokeColor: root._sweep > 0.5 ? root.color : "transparent"
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root._center
                centerY: root._center
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root.startAngle
                sweepAngle: root._sweep
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.centerText !== ""
        text: root.centerText
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.centerFontSize
        font.letterSpacing: 0.2
        renderType: Text.NativeRendering
    }
}
