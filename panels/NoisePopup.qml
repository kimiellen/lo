pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.core
import qs.services

// 白噪音弹层：全屏 overlay 承载，面板锚定状态卡下方右侧；8 项声音列表 + 底部音量滑条，Esc / 点击外部关闭
PanelWindow {
    id: root

    property bool open: false

    color: "transparent"
    visible: root.open

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "vbc-io-noise"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function togglePopup() {
        open = !open;
    }

    function closePopup() {
        open = false;
    }

    Item {
        id: surface
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function (event) {
            root.closePopup();
            event.accepted = true;
        }

        // 点击弹层外关闭
        MouseArea {
            anchors.fill: parent
            onClicked: root.closePopup()
        }

        Rectangle {
            id: frame

            // 与顶栏右区状态卡右边对齐（外边距跟随 gaps_out），落在卡片下方一个 gaps_out
            x: surface.width - width - Metrics.snap(Metrics.outerMarginXFor(Hypr.gapsOut), root.devicePixelRatio)
            y: Metrics.barWindowHeight(Config.barHeight, Hypr.gapsOut, root.devicePixelRatio) + Hypr.gapsOut
            width: 260
            height: body.implicitHeight + Metrics.panelPadding * 2
            radius: Metrics.panelRadius
            color: Theme.panel
            border.width: Metrics.snap(1, root.devicePixelRatio)
            border.color: Theme.trackDim

            // 吞掉弹层内的点击，避免冒泡到"点击外部关闭"
            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: body
                anchors {
                    top: parent.top
                    topMargin: Metrics.panelPadding
                    left: parent.left
                    leftMargin: Metrics.panelPadding
                    right: parent.right
                    rightMargin: Metrics.panelPadding
                }
                spacing: 2

                Repeater {
                    model: WhiteNoise.trackKeys

                    delegate: Rectangle {
                        id: trackRow

                        required property string modelData
                        readonly property bool selected: WhiteNoise.track === trackRow.modelData

                        width: body.width
                        height: 40
                        radius: 8
                        color: trackRow.selected ? "transparent"
                            : (trackHover.containsMouse ? Theme.trackDim : "transparent")
                        border.width: trackRow.selected ? Metrics.snap(1, root.devicePixelRatio) : 0
                        border.color: Theme.noise

                        NoiseGlyph {
                            id: trackGlyph
                            anchors {
                                left: parent.left
                                leftMargin: 11
                                verticalCenter: parent.verticalCenter
                            }
                            kind: trackRow.modelData
                            size: 18
                            color: trackRow.selected ? Theme.noise : Theme.subtext
                        }

                        Text {
                            anchors {
                                left: trackGlyph.right
                                leftMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                            text: I18n.t("noise." + trackRow.modelData)
                            color: trackRow.selected ? Theme.noise : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Metrics.panelTitleSize
                            renderType: Text.NativeRendering
                        }

                        // 选中对勾（sky，右侧）
                        Shape {
                            anchors {
                                right: parent.right
                                rightMargin: 14
                                verticalCenter: parent.verticalCenter
                            }
                            width: 12
                            height: 12
                            visible: trackRow.selected
                            preferredRendererType: Shape.CurveRenderer

                            ShapePath {
                                strokeColor: Theme.noise
                                strokeWidth: 2
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                joinStyle: ShapePath.RoundJoin
                                PathSvg { path: "M1.5 6.5L4.8 9.8L10.5 2.5" }
                            }
                        }

                        MouseArea {
                            id: trackHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: WhiteNoise.select(trackRow.modelData)
                        }
                    }
                }

                // ---------------- 音量滑条（只调白噪音，不动系统音量） ----------------
                Column {
                    width: body.width
                    spacing: 6
                    topPadding: 10

                    Text {
                        text: I18n.t("noise.volume")
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Metrics.panelMetaSize
                        renderType: Text.NativeRendering
                    }

                    Item {
                        id: slider
                        width: parent.width
                        height: 20

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: slider.width
                            height: 4
                            radius: 2
                            color: Theme.track
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: handle.x + handle.width / 2
                            height: 4
                            radius: 2
                            color: Theme.noise
                        }

                        Rectangle {
                            id: handle
                            anchors.verticalCenter: parent.verticalCenter
                            x: WhiteNoise.volume * (slider.width - width)
                            width: 12
                            height: 12
                            radius: 6
                            color: Theme.noise
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            function update(mouse) {
                                WhiteNoise.previewVolume(Math.max(0, Math.min(1, mouse.x / slider.width)));
                            }

                            onPressed: function (mouse) {
                                update(mouse);
                            }
                            onPositionChanged: function (mouse) {
                                update(mouse);
                            }
                            onReleased: function (mouse) {
                                WhiteNoise.commitVolume(Math.max(0, Math.min(1, mouse.x / slider.width)));
                            }
                        }
                    }
                }
            }
        }
    }
}
