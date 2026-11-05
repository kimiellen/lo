import QtQuick
import QtQuick.Shapes
import qs.core

// 右区状态卡的自绘矢量图标：绘制视框固定 20×20，按控件尺寸等比缩放，不依赖字体 codepoint
// kind = mic；颜色、静音斜线由调用方驱动
Item {
    id: root

    property string kind: "mic"
    property color color: Theme.text
    property color cutColor: Theme.cardCut   // 静音斜线两侧的切口底色（必须不透明）
    property bool muted: false
    property real size: Metrics.statusGlyphSize

    readonly property real viewBox: 20

    implicitWidth: size
    implicitHeight: size

    // ---------------- 麦克风 ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "mic"
        preferredRendererType: Shape.CurveRenderer

        // 支架：下半圆
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 10
                centerY: 9.4
                radiusX: 5
                radiusY: 5
                startAngle: 0
                sweepAngle: 180
            }
        }

        // 立杆与底座
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M 10 14.4L 10 17.2" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M 6.8 17.2L 13.2 17.2" }
        }

        // 拾音头
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M7.2 5.6a2.8 2.8 0 0 1 5.6 0v2.8a2.8 2.8 0 0 1-5.6 0z" }
        }

        // 静音：先切一道底色，再画斜线
        ShapePath {
            strokeColor: root.muted ? root.cutColor : "transparent"
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M 3.6 3.6L 16.4 16.4" }
        }

        ShapePath {
            strokeColor: root.muted ? root.color : "transparent"
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M 3.6 3.6L 16.4 16.4" }
        }
    }
}
