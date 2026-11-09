import QtQuick
import QtQuick.Shapes
import qs.core

// 白噪音矢量图标：绘制视框固定 1024×1024，按 size 等比缩放
// kind = button（状态卡按钮，用户提供的波形圆圈）| birds | stream | wind | night | fire | boat | cafe | none
Item {
    id: root

    property string kind: "button"
    property color color: Theme.subtext
    property real size: 18

    readonly property real viewBox: 1024

    implicitWidth: size
    implicitHeight: size

    // ---------------- 按钮：波形圆圈（用户提供 path，填充） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "button"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M806.2976 547.6864c0-14.7456-14.7456-29.4912-29.4912-29.4912-17.69472 0-29.4912 14.7456-29.4912 29.4912 0 20.64384-5.89824 79.616-32.44032 109.09696-14.7456 14.7456-32.44032 20.64384-56.02304 20.64384-41.27744 0-70.76864-112.05632-94.3616-191.66208-29.4912-114.9952-58.97216-221.184-135.63904-221.184-109.09696 0-159.232 168.07936-191.66208 277.17632-5.89824 23.552-11.79648 44.22656-17.69472 56.02304-5.89824 14.7456 2.94912 32.44032 17.69472 38.33856s32.44032-2.94912 38.33856-17.69472 11.79648-35.3792 20.64384-61.92128C316.8256 476.91776 364.00128 323.584 428.87168 323.584c32.44032 0 61.92128 106.14784 82.56512 176.92672 32.44032 114.9952 64.8704 235.88864 150.38464 235.88864 38.32832 0 70.76864-11.79648 94.3616-38.32832 53.07392-56.02304 50.176-147.456 50.176-150.38464z m0 0" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M512 972.11392a471.72608 471.72608 0 0 1-183.57248-906.1376 471.72608 471.72608 0 0 1 367.14496 869.0688A468.6848 468.6848 0 0 1 512 972.11392z m0-904.30464c-238.592 0-432.6912 194.10944-432.6912 432.6912S273.408 933.20192 512 933.20192s432.6912-194.0992 432.6912-432.6912S750.592 67.81952 512 67.81952z" }
        }
    }

    // ---------------- 林间鸟鸣：展翅飞鸟（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "birds"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 64
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M160 660C290 490 420 480 512 630C604 480 734 490 864 660" }
        }
    }

    // ---------------- 溪流潺潺：三排波浪（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "stream"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 48
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M134 380q90 -76 180 0t180 0t180 0t180 0M134 530q90 -76 180 0t180 0t180 0t180 0M134 680q90 -76 180 0t180 0t180 0t180 0" }
        }
    }

    // ---------------- 原野风声：三缕风线（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "wind"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 56
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M140 360H560C650 360 700 315 700 250C700 195 655 155 595 155M140 540H690C795 540 840 595 840 660C840 720 795 760 730 760M140 720H470" }
        }
    }

    // ---------------- 夏夜虫鸣：弯月（填充，奇偶裁剪出月牙） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "night"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            fillRule: ShapePath.OddEvenFill
            // 大圆减右上的圆 = 开口朝右的月牙（圆用四段三次贝塞尔近似）
            PathSvg { path: "M40 512C40 313 213 140 400 140C587 140 760 313 760 512C760 711 587 884 400 884C213 884 40 711 40 512ZM310 470C310 304 444 170 610 170C776 170 910 304 910 470C910 636 776 770 610 770C444 770 310 636 310 470Z" }
        }
    }

    // ---------------- 夜晚壁炉：火焰剪影（填充） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "fire"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M512 128C540 240 704 320 704 548C704 680 620 796 512 796C404 796 320 680 320 548C320 448 356 408 392 328C408 400 448 432 448 432C428 300 460 200 512 128z" }
        }
    }

    // ---------------- 远航船舱：帆船（填充 + 桅杆描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "boat"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M536 240L536 600L770 600z" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M488 300L488 600L270 600z" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 36
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M512 200L512 648" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: "M220 664L804 664L730 800L294 800z" }
        }
    }

    // ---------------- 安静咖啡馆：咖啡杯 + 热气（填充 + 描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "cafe"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M270 440h380v120a130 130 0 0 1-130 130h-120a130 130 0 0 1-130-130z" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 40
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 678
                centerY: 545
                radiusX: 62
                radiusY: 62
                startAngle: -90
                sweepAngle: 180
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 36
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M430 370c-34 -36 34 -64 0 -100M540 370c-34 -36 34 -64 0 -100" }
        }
    }

    // ---------------- 安静：圆圈斜杠（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "none"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 56
            fillColor: "transparent"
            PathAngleArc {
                centerX: 512
                centerY: 512
                radiusX: 290
                radiusY: 290
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 56
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M352 672L672 352" }
        }
    }
}
