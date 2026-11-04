import QtQuick
import QtQuick.Shapes
import qs.core

// 时钟卡片的时间矢量图标：24×24 设计视框按 size 等比缩放
// 表环 + 12/3 指针 + 四方位刻度点 + 右上角箭头（源自 1024 viewBox 图标描摹）
Item {
    id: root

    property color color: Theme.clockTime
    property real size: Metrics.clockIconSize

    implicitWidth: root.size
    implicitHeight: root.size

    Shape {
        anchors.centerIn: parent
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        // 表环
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            PathAngleArc {
                centerX: 12
                centerY: 12
                radiusX: 9.6
                radiusY: 9.6
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        // 指针：指向 12 与 3（圆角描边）
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M12 12L12 7.3M12 12L16.3 12" }
        }

        // 四方位刻度点
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg {
                path: "M12 3.61m-0.59 0a0.59 0.59 0 1 0 1.18 0a0.59 0.59 0 1 0-1.18 0zM19.19 12m-0.59 0a0.59 0.59 0 1 0 1.18 0a0.59 0.59 0 1 0-1.18 0zM12 19.19m-0.59 0a0.59 0.59 0 1 0 1.18 0a0.59 0.59 0 1 0-1.18 0zM4.81 12m-0.59 0a0.59 0.59 0 1 0 1.18 0a0.59 0.59 0 1 0-1.18 0z"
            }
        }

        // 右上角旋转箭头
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg {
                path: "M20.29 6.07l-0.99-3.23c-0.17-0.55-0.89-0.68-1.23-0.22L15.68 5.77c-0.35 0.46-0.03 1.11 0.55 1.13l3.38 0.07c0.48 0.01 0.83-0.45 0.69-0.91z"
            }
        }
    }
}
