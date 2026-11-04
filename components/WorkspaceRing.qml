pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import qs.core

// Workspace 五段应用色环：活动段对齐 12 点，red 半径线标记当前可见序列起点。
Item {
    id: root

    property var windows: []
    property int activeIndex: 0
    property real size: Metrics.workspaceRing
    property real thickness: Metrics.workspaceRingThickness
    property real segmentGap: Metrics.workspaceSegmentGap
    property color trackColor: Theme.trackDim

    readonly property int count: windows.length
    readonly property int clampedActiveIndex: count > 0
        ? Math.max(0, Math.min(count - 1, activeIndex)) : 0
    // 非循环五槽视窗：前四次移动仍显示首组五个，之后每次隐藏最左一段。
    readonly property int visibleStart: count > 5 ? Math.max(0, clampedActiveIndex - 4) : 0
    readonly property real rotationAngle: -clampedActiveIndex * 72
    readonly property real arcSweep: 72 - segmentGap

    // 固定渲染五个逻辑槽位：有窗口用应用色，空槽用轨道色；段间空隙保持透明。
    readonly property var visibleSlots: {
        const result = [];
        for (let slot = 0; slot < 5; ++slot) {
            const logicalIndex = visibleStart + slot;
            const occupied = logicalIndex < count;
            const colorName = occupied ? Config.workspaceAppColorName(windows[logicalIndex].appKey) : "";
            result.push({
                logicalIndex: logicalIndex,
                color: occupied ? (Theme.p[colorName] || Theme.p.text) : root.trackColor
            });
        }
        return result;
    }

    // 真实设备像素比：分段缩放下 Screen.devicePixelRatio 只返回整数
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1
    readonly property real diameter: Metrics.snapEven(size, dpr)
    readonly property real strokeWidth: Math.max(1 / dpr, Metrics.snap(thickness, dpr))
    readonly property real center: diameter / 2
    readonly property real radius: Math.max(0.5, (diameter - strokeWidth) / 2)

    // 红线使用可见起点相对活动段的角度；第五个以后二者差恒为 -4，动画中也固定不动。
    readonly property real markerRotation: (visibleStart - clampedActiveIndex) * 72
    readonly property real markerAngle: -126 * Math.PI / 180
    readonly property real markerX: center + Math.cos(markerAngle) * diameter / 2
    readonly property real markerY: center + Math.sin(markerAngle) * diameter / 2

    implicitWidth: diameter
    implicitHeight: diameter

    Item {
        id: rotor
        anchors.fill: parent
        rotation: root.rotationAngle

        // 不归一化到 0–360°，保证跨整圈时仍按真实窗口方向旋转，不突然反向。
        Behavior on rotation {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: root.visibleSlots

            delegate: Shape {
                id: segment
                required property var modelData

                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeColor: segment.modelData.color
                    strokeWidth: root.strokeWidth
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        centerX: root.center
                        centerY: root.center
                        radiusX: root.radius
                        radiusY: root.radius
                        startAngle: -126 + segment.modelData.logicalIndex * 72 + root.segmentGap / 2
                        sweepAngle: root.arcSweep
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.count > 0
        rotation: root.markerRotation

        Behavior on rotation {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.p.red
                strokeWidth: Math.max(1 / root.dpr, Metrics.snap(1.5, root.dpr))
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap
                PathMove {
                    x: root.center
                    y: root.center
                }
                PathLine {
                    x: root.markerX
                    y: root.markerY
                }
            }
        }
    }
}
