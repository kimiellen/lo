import QtQuick
import QtQuick.Shapes
import qs.core

// 右区状态卡的自绘矢量图标：坐标系固定 20×20，不依赖字体 codepoint
// kind = mic / speaker / sun / battery；颜色、静音斜线、声波档位与电池填充由调用方驱动
Item {
    id: root

    property string kind: "mic"
    property color color: Theme.text
    property color cutColor: Theme.cardBg   // 静音斜线两侧的切口底色（卡片底色）
    property bool muted: false
    property int waves: 0                   // speaker：0–3 道声波
    property real level: 0                  // battery：0..1 填充
    property bool charging: false

    implicitWidth: Metrics.statusGlyphSize
    implicitHeight: Metrics.statusGlyphSize

    // ---------------- 麦克风 ----------------
    Shape {
        anchors.fill: parent
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

    // ---------------- 喇叭 ----------------
    Shape {
        anchors.fill: parent
        visible: root.kind === "speaker"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M4.8 8.2h3.4l3.6-3.6v10.8l-3.6-3.6H4.8z" }
        }

        // 三档声波：按 waves 逐道打开
        ShapePath {
            strokeColor: root.waves >= 1 ? root.color : "transparent"
            strokeWidth: 1.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 11.8
                centerY: 10
                radiusX: 2.6
                radiusY: 2.6
                startAngle: -55
                sweepAngle: 110
            }
        }

        ShapePath {
            strokeColor: root.waves >= 2 ? root.color : "transparent"
            strokeWidth: 1.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 11.8
                centerY: 10
                radiusX: 4.8
                radiusY: 4.8
                startAngle: -55
                sweepAngle: 110
            }
        }

        ShapePath {
            strokeColor: root.waves >= 3 ? root.color : "transparent"
            strokeWidth: 1.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 11.8
                centerY: 10
                radiusX: 7
                radiusY: 7
                startAngle: -55
                sweepAngle: 110
            }
        }

        // 静音斜线
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

    // ---------------- 太阳 ----------------
    Item {
        anchors.fill: parent
        visible: root.kind === "sun"

        // 四道贯穿线先画，中央圆盘盖住中段 → 视觉上是 8 条射线
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.color
                strokeWidth: 1.5
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathSvg { path: "M 2.4 10L 17.6 10" }
            }

            ShapePath {
                strokeColor: root.color
                strokeWidth: 1.5
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathSvg { path: "M 10 2.4L 10 17.6" }
            }

            ShapePath {
                strokeColor: root.color
                strokeWidth: 1.5
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathSvg { path: "M 4.6 4.6L 15.4 15.4" }
            }

            ShapePath {
                strokeColor: root.color
                strokeWidth: 1.5
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathSvg { path: "M 15.4 4.6L 4.6 15.4" }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 7.2
            height: 7.2
            radius: 3.6
            color: root.color
        }
    }

    // ---------------- 电池 ----------------
    Item {
        anchors.fill: parent
        visible: root.kind === "battery"

        // 充电：只显示闪电（与参考图一致）
        Shape {
            anchors.fill: parent
            visible: root.charging
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M11.6 2.4L5.2 11.4h3.9l-1 6.2 6.4-9h-3.9z" }
            }
        }

        // 非充电：外框 + 电极 + 连续填充
        Item {
            anchors.fill: parent
            visible: !root.charging

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: root.color
                    strokeWidth: 1.5
                    fillColor: "transparent"
                    PathSvg {
                        path: "M4.1 6.4h9.8a1.6 1.6 0 0 1 1.6 1.6v4a1.6 1.6 0 0 1-1.6 1.6H4.1a1.6 1.6 0 0 1-1.6-1.6v-4a1.6 1.6 0 0 1 1.6-1.6z"
                    }
                }

                ShapePath {
                    fillColor: root.color
                    strokeColor: "transparent"
                    PathSvg { path: "M16.2 8.4h0.9a0.7 0.7 0 0 1 0.7 0.7v1.8a0.7 0.7 0 0 1-0.7 0.7h-0.9z" }
                }
            }

            Rectangle {
                x: 4.4
                y: 7.5
                height: 5
                width: Math.max(0, 8.9 * Math.max(0, Math.min(1, root.level)))
                radius: 0.8
                color: root.color
                visible: width > 0.5
            }
        }
    }
}
