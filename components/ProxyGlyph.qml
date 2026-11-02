import QtQuick
import QtQuick.Shapes
import qs.core

// 代理状态图标：地球底形 + 模式徽标（24×24 设计坐标，按 size 缩放）
// mode = rule（列表线）/ global（圆环）/ direct（斜向箭头）；为空或未知时只画地球
Item {
    id: root

    property string mode: ""
    property color color: Theme.accent
    property color cutColor: Theme.cardBg
    property real size: Metrics.iconGlyphSize

    implicitWidth: root.size
    implicitHeight: root.size

    readonly property bool rule: root.mode === "rule"
    readonly property bool global: root.mode === "global"
    readonly property bool direct: root.mode === "direct"

    Shape {
        width: 24
        height: 24
        anchors.centerIn: parent
        transform: Scale {
            origin.x: 12
            origin.y: 12
            xScale: root.size / 24
            yScale: root.size / 24
        }
        preferredRendererType: Shape.CurveRenderer

        // ---------------- 全局：右下角圆环徽标 ----------------
        ShapePath {
            fillColor: root.global ? root.cutColor : "transparent"
            strokeColor: "transparent"
            PathAngleArc {
                centerX: 19.8
                centerY: 19.8
                radiusX: 3.4
                radiusY: 3.4
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        ShapePath {
            strokeColor: root.global ? root.color : "transparent"
            strokeWidth: 1.3
            fillColor: "transparent"
            PathAngleArc {
                centerX: 19.8
                centerY: 19.8
                radiusX: 2.5
                radiusY: 2.5
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        // ---------------- 地球底形 ----------------
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.5
            fillColor: "transparent"
            PathAngleArc {
                centerX: 11.2
                centerY: 11.2
                radiusX: 8.2
                radiusY: 8.2
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.5
            fillColor: "transparent"
            PathSvg { path: "M3 11.2L19.4 11.2" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.5
            fillColor: "transparent"
            PathAngleArc {
                centerX: 11.2
                centerY: 11.2
                radiusX: 3.6
                radiusY: 8.2
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        // ---------------- 规则：右下角列表线 ----------------
        ShapePath {
            fillColor: root.rule ? root.cutColor : "transparent"
            strokeColor: "transparent"
            PathAngleArc {
                centerX: 19.8
                centerY: 19.8
                radiusX: 3.3
                radiusY: 3.3
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        ShapePath {
            strokeColor: root.rule ? root.color : "transparent"
            strokeWidth: 1.3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M17.2 18.1L22.6 18.1M18.1 19.8L22.6 19.8M17.2 21.5L22.6 21.5" }
        }

        // ---------------- 直连：右下角斜向箭头 ----------------
        ShapePath {
            strokeColor: root.direct ? root.cutColor : "transparent"
            strokeWidth: 3.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M15.2 21.8L22.2 14.8M18.4 14.8L22.2 14.8L22.2 18.6" }
        }

        ShapePath {
            strokeColor: root.direct ? root.color : "transparent"
            strokeWidth: 1.5
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M15.2 21.8L22.2 14.8M18.4 14.8L22.2 14.8L22.2 18.6" }
        }
    }
}
