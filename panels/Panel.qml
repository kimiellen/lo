pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.core
import qs.panels.tabs
import qs.services

// 控制面板：全屏 overlay 承载，面板锚定顶栏右下方；三 tab、Esc / 点击外部关闭
// 打开时独占键盘焦点（网络 tab 的密码框需要输入），关闭后归还
PanelWindow {
    id: root

    property bool open: false
    property string tab: "network"

    readonly property var tabs: [
        { key: "proxy", label: I18n.t("panel.proxy") },
        { key: "network", label: I18n.t("panel.network") },
        { key: "bluetooth", label: I18n.t("panel.bluetooth") }
    ]

    color: "transparent"
    visible: root.open

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "vbc-io-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function openPanel(name) {
        if (name !== "")
            tab = name;
        open = true;
    }

    function closePanel() {
        open = false;
    }

    function togglePanel(name) {
        if (open && tab === name)
            closePanel();
        else
            openPanel(name);
    }

    // 打开/切到某 tab 时取一次最新数据（面板内即时刷新）
    function activate() {
        if (tab === "proxy") {
            Proxy.refresh();
        } else if (tab === "network") {
            Wifi.refresh();
            Link.refresh();
        }
    }

    onOpenChanged: {
        if (open)
            activate();
    }

    onTabChanged: {
        if (open)
            activate();
    }

    Item {
        id: surface
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function (event) {
            root.closePanel();
            event.accepted = true;
        }

        // 点击面板外关闭
        MouseArea {
            anchors.fill: parent
            onClicked: root.closePanel()
        }

        Rectangle {
            id: frame

            readonly property real contentHeight: loader.item ? loader.item.implicitHeight : 0
            readonly property real maxHeight: Math.max(160, Math.min(560, surface.height - y - 16))

            x: surface.width - width - 14
            // 顶栏总高（与 Bar 共用同一套设备像素吸附公式）+ 一个 gaps_out；面板落在卡片下方
            y: Metrics.barWindowHeight(Config.barHeight, Hypr.gapsOut, root.devicePixelRatio) + Hypr.gapsOut
            width: 340
            height: Math.max(120, Math.min(maxHeight, 50 + contentHeight))
            radius: 10
            color: Theme.panel
            // 1px 描边按设备像素吸附，与顶栏卡片一致
            border.width: Metrics.snap(1, root.devicePixelRatio)
            border.color: Theme.trackDim

            // 吞掉面板内的点击，避免冒泡到"点击外部关闭"
            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: bodyArea
                anchors {
                    top: parent.top
                    topMargin: 8
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 8
                }

                Row {
                    id: tabBar
                    width: parent.width
                    height: 26
                    spacing: 6

                    Repeater {
                        model: root.tabs

                        delegate: Rectangle {
                            id: tabButton
                            required property var modelData

                            width: (tabBar.width - tabBar.spacing * (root.tabs.length - 1)) / root.tabs.length
                            height: tabBar.height
                            radius: 7
                            color: root.tab === tabButton.modelData.key ? Theme.track : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: tabButton.modelData.label
                                color: root.tab === tabButton.modelData.key ? Theme.text : Theme.subtext
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                renderType: Text.NativeRendering
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.tab = tabButton.modelData.key
                            }
                        }
                    }
                }

                Flickable {
                    id: flick
                    anchors {
                        top: tabBar.bottom
                        topMargin: 8
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    clip: true
                    contentWidth: width
                    contentHeight: loader.item ? loader.item.implicitHeight : 0
                    boundsBehavior: Flickable.StopAtBounds

                    Loader {
                        id: loader
                        width: flick.width
                        active: root.open
                        sourceComponent: root.tab === "network" ? networkTab
                            : (root.tab === "bluetooth" ? bluetoothTab : proxyTab)
                    }
                }
            }
        }
    }

    Component {
        id: networkTab

        NetworkTab {
            onCloseRequested: root.closePanel()
        }
    }

    Component {
        id: bluetoothTab

        BluetoothTab {
            onCloseRequested: root.closePanel()
        }
    }

    // 代理 tab 在 M5 接入
    Component {
        id: proxyTab

        ProxyTab {}
    }
}
