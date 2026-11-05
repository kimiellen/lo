import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import qs.core

// 环形用量图标：外轨 + 进度弧（Shape/PathAngleArc）
// 抗锯齿走 CurveRenderer（Quickshell 的 surface 是 samples 0，几何渲染器得不到多重采样），
// 环径与线宽按设备像素吸附，避免分段缩放下落在半像素上发虚
Item {
    id: root

    property real value: 0              // 0..1
    property color color: Theme.cpu
    property color trackColor: Theme.ringTrack
    property real size: Metrics.ringSize
    property real thickness: Metrics.ringThickness
    property real startAngle: -90
    property bool showTrack: true
    property string centerText: ""      // 环心文字（字母/数字），空则不显示
    property string centerIconPath: ""  // 环心矢量图标（PathSvg path 数据，viewBox 1024），非空时优先于文字
    property real centerFontSize: Metrics.ringLetterSize
    property bool shrinkCenterText: true // false = 固定字号，不按字符数缩小

    // 环心文字字号：按内径几何求能放下的最大值（不让墨迹碰到环内壁），再受基准字号约束
    // 实测等宽字体墨迹：单字宽最宽约 0.72em（M）、大写/数字高约 0.72em（取宽松值留安全边）
    readonly property real centerTextSize: {
        if (!root.shrinkCenterText)
            return root.centerFontSize;
        const glyphs = Math.max(1, root.centerText.length);
        const innerDiameter = root.diameter - 2 * root.strokeWidth;
        const margin = 1.4                        // 文字与内壁留白（逻辑 px）
        const halfWidth = 0.36 * glyphs           // 半宽 / em
        const halfHeight = 0.36                   // 半高 / em
        const limit = (innerDiameter / 2 - margin) / Math.sqrt(halfWidth * halfWidth + halfHeight * halfHeight)
        return Math.min(root.centerFontSize, limit)
    }

    // 真实设备像素比：Window.window 为空时（入窗前）退回 1
    readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

    // 直径取偶数设备像素、线宽取整设备像素 → 内外边界都落在整像素上
    readonly property real diameter: Metrics.snapEven(size, dpr)
    readonly property real strokeWidth: Math.max(1 / dpr, Metrics.snap(thickness, dpr))
    readonly property real center: diameter / 2
    readonly property real radius: Math.max(0.5, (diameter - strokeWidth) / 2)
    readonly property real sweep: Format.clamp01(value) * 360

    implicitWidth: diameter
    implicitHeight: diameter

    Shape {
        anchors.fill: parent
        // 默认的 GeometryRenderer 只靠窗口多重采样抗锯齿；CurveRenderer 在 GPU 上直接求曲线并自带抗锯齿
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.showTrack ? root.trackColor : "transparent"
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.center
                centerY: root.center
                radiusX: root.radius
                radiusY: root.radius
                startAngle: 0
                sweepAngle: 359.9
            }
        }

        ShapePath {
            strokeColor: root.sweep > 0.5 ? root.color : "transparent"
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.center
                centerY: root.center
                radiusX: root.radius
                radiusY: root.radius
                startAngle: root.startAngle
                sweepAngle: root.sweep
            }
        }
    }

    // 环心文字走默认渲染（距离场），比原生渲染边缘更干净
    Text {
        anchors.centerIn: parent
        visible: root.centerText !== "" && root.centerIconPath === ""
        text: root.centerText
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.centerTextSize
        font.letterSpacing: 0.2
    }

    // 环心矢量图标：1024 视框等比缩放到内径的 72%（与文字互斥，文字端已按 icon 置空）
    Shape {
        anchors.centerIn: parent
        visible: root.centerIconPath !== ""
        width: 1024
        height: 1024
        readonly property real fit: Math.max(2, (root.diameter - 2 * root.strokeWidth) * 0.72)
        scale: fit / 1024
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: root.centerIconPath }
        }
    }
}
