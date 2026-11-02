pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import qs.core

// 矢量标通用渲染：把 SVG path 数据（可多条、各自配色）按视框缩放到控件尺寸
// 走 CurveRenderer 抗锯齿；宽度按设备像素吸附，小尺寸下边缘更干净
Item {
    id: root

    property real viewBoxWidth: 1024
    property real viewBoxHeight: 1024
    property color color: Theme.text            // 单色标的填充色（paths 里 fill 为空时生效）
    property var paths: []                      // [{ d: "path 数据", fill: "" }]
    property real markWidth: Metrics.brandMarkWidth   // 逻辑宽度；实际宽度按设备像素吸附

    // 真实设备像素比（分段缩放下 Screen.devicePixelRatio 只返回整数）
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1
    readonly property real markHeight: Metrics.snap(root.markWidth * root.viewBoxHeight / root.viewBoxWidth, root.dpr)

    implicitWidth: Metrics.snap(root.markWidth, root.dpr)
    implicitHeight: root.markHeight

    // 每条 path 叠一个 Shape（Shape 只接受静态 ShapePath 子项，不能用 Repeater 动态塞 path）
    Repeater {
        model: root.paths

        delegate: Shape {
            required property var modelData

            x: 0
            y: 0
            width: root.width
            height: root.height
            preferredRendererType: Shape.CurveRenderer
            // path 数据按官方视框坐标书写，这里缩放到控件尺寸
            transform: Scale {
                origin.x: 0
                origin.y: 0
                xScale: root.width / root.viewBoxWidth
                yScale: root.height / root.viewBoxHeight
            }

            ShapePath {
                fillColor: modelData.fill ? modelData.fill : root.color
                strokeColor: "transparent"

                PathSvg {
                    path: modelData.d
                }
            }
        }
    }
}
