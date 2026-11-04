import QtQuick
import QtQuick.Shapes
import qs.core

// 白噪音矢量图标：绘制视框固定 1024×1024，按 size 等比缩放
// kind = button（状态卡按钮，用户提供的波形圆圈）| stars | rain | sea | forest | fire | voyage | cafe | none
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

    // ---------------- 星空音乐：三枚四角星（填充） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "stars"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M400 240Q434 396 590 430Q434 464 400 620Q366 464 210 430Q366 396 400 240z" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M730 205Q748 282 825 300Q748 318 730 395Q712 318 635 300Q712 282 730 205z" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M700 595Q713 647 765 660Q713 673 700 725Q687 673 635 660Q687 647 700 595z" }
        }
    }

    // ---------------- 雨天图书馆：云 + 三条雨滴（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "rain"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 48
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: "M280 600C200 600 170 520 220 470C240 380 340 340 420 370C460 280 600 260 660 340C760 320 830 400 800 490C850 520 820 600 740 600z" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 44
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M340 668L304 748M512 668L476 748M684 668L648 748" }
        }
    }

    // ---------------- 清晨海岸：两排波浪（描边） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "sea"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 52
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M114 440q90 -80 180 0t180 0t180 0t180 0" }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 52
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M204 624q90 -80 180 0t180 0t180 0t180 0" }
        }
    }

    // ---------------- 林间早晨：松树剪影（填充） ----------------
    Shape {
        anchors.centerIn: parent
        width: root.viewBox
        height: root.viewBox
        scale: root.size / root.viewBox
        transformOrigin: Item.Center
        visible: root.kind === "forest"
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: "M512 160L680 420L600 420L740 620L640 620L800 800L224 800L384 620L284 620L424 420L344 420z" }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M482 800h60v104h-60z" }
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
        visible: root.kind === "voyage"
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
