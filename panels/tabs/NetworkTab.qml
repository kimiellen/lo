pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 网络 tab：Wi-Fi 列表 / 连接 / 密码输入 + 链路只读状态
Item {
    id: root

    signal closeRequested()

    property var pending: null          // 待输入密码的网络
    property string notice: ""          // 本地提示（不支持的加密方式等）

    implicitHeight: body.height

    function choose(network) {
        if (!network || Wifi.busy || !Wifi.ready || network.connected)
            return;
        notice = "";
        if (network.known || network.security === "open") {
            pending = null;
            Wifi.connect(network.ssid);
            return;
        }
        if (network.security === "psk") {
            pending = network;
            return;
        }
        notice = I18n.t("panel.wifi.unsupported");
    }

    function submit() {
        if (pending === null)
            return;
        const target = pending;
        pending = null;
        Wifi.connect(target.ssid, passwordInput.text);
    }

    function cancel() {
        pending = null;
        passwordInput.text = "";
    }

    onPendingChanged: {
        if (pending !== null) {
            passwordInput.text = "";
            Qt.callLater(function () {
                passwordInput.forceActiveFocus();
            });
        }
    }

    Column {
        id: body
        width: root.width
        spacing: 6

        // ---------------- Wi-Fi 开关 ----------------
        Item {
            visible: Wifi.available
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.wifi")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }

            ToggleSwitch {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: Wifi.powered
                onToggled: Wifi.setPowered(!Wifi.powered)
            }
        }

        EmptyState {
            visible: !Wifi.available
            width: parent.width
            title: I18n.t("panel.wifi.unavailable")
        }

        EmptyState {
            visible: Wifi.available && !Wifi.powered
            width: parent.width
            title: I18n.t("panel.wifi.off")
        }

        // ---------------- 当前连接 + 扫描 ----------------
        Item {
            visible: Wifi.ready
            width: parent.width
            height: 22

            Text {
                id: linkStatus
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - disconnectAction.width - 8
                elide: Text.ElideRight
                text: Wifi.connected
                    ? (Wifi.ssid + (Wifi.ipv4 !== "" ? " · " + Wifi.ipv4 : "")
                        + (Wifi.rssi < 0 ? " · " + Wifi.rssi + " dBm" : ""))
                    : I18n.t("panel.wifi.idle")
                color: Wifi.connected ? Theme.success : Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }

            Text {
                id: disconnectAction
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: Wifi.connected && !Wifi.busy
                text: I18n.t("panel.disconnect")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wifi.disconnect()
                }
            }
        }

        Item {
            visible: Wifi.ready
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Wifi.scanning ? I18n.t("panel.wifi.scanning")
                    : (Wifi.networks.length === 0 ? I18n.t("panel.wifi.empty") : "")
                color: Theme.overlay
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.scan")
                color: Wifi.scanning ? Theme.overlay : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wifi.scan()
                }
            }
        }

        Text {
            visible: Wifi.failed
            width: parent.width
            text: I18n.t("panel.wifi.failed")
            color: Theme.warning
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        Text {
            visible: root.notice !== ""
            width: parent.width
            text: root.notice
            color: Theme.warning
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        // ---------------- 密码输入 ----------------
        Rectangle {
            visible: root.pending !== null
            width: parent.width
            height: 90
            radius: 8
            color: Theme.trackDim

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: root.pending
                        ? I18n.t("panel.password") + " · " + root.pending.ssid
                        : ""
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    width: parent.width
                    height: 26
                    radius: 6
                    color: Theme.bg
                    border.width: 1
                    border.color: passwordInput.activeFocus ? Theme.accent : Theme.track

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: Theme.text
                        selectionColor: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        onAccepted: root.submit()
                        Keys.onEscapePressed: root.closeRequested()
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        verticalAlignment: Text.AlignVCenter
                        visible: passwordInput.text === ""
                        text: I18n.t("panel.password.placeholder")
                        color: Theme.overlay
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        renderType: Text.NativeRendering
                    }
                }

                Item {
                    width: parent.width
                    height: 16

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("panel.cancel")
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        renderType: Text.NativeRendering

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.cancel()
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("panel.connect")
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        renderType: Text.NativeRendering

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submit()
                        }
                    }
                }
            }
        }

        // ---------------- Wi-Fi 列表 ----------------
        Repeater {
            model: Wifi.ready ? Wifi.networks : []

            delegate: Item {
                id: networkRow
                required property var modelData

                width: root.width
                height: 22

                Text {
                    id: networkName
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - networkMeta.width - 8
                    elide: Text.ElideRight
                    text: networkRow.modelData.ssid
                    color: networkRow.modelData.connected ? Theme.success
                        : (networkRow.modelData.known ? Theme.text : Theme.subtext)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    renderType: Text.NativeRendering
                }

                Row {
                    id: networkMeta
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        visible: networkRow.modelData.connected
                        text: I18n.t("panel.connected")
                        color: Theme.success
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }

                    Text {
                        visible: networkRow.modelData.known && !networkRow.modelData.connected
                        text: I18n.t("panel.known")
                        color: Theme.overlay
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: I18n.securityLabel(networkRow.modelData.security)
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "*".repeat(networkRow.modelData.stars)
                        color: Theme.overlay
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        renderType: Text.NativeRendering
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.choose(networkRow.modelData)
                }
            }
        }

        // ---------------- 链路（只读） ----------------
        Rectangle {
            visible: Link.links.length > 0
            width: parent.width
            height: 1
            color: Theme.trackDim
        }

        Text {
            visible: Link.links.length > 0
            text: I18n.t("panel.link")
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        Repeater {
            model: Link.links

            delegate: Item {
                id: linkRow
                required property var modelData

                width: root.width
                height: 16

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 76
                    elide: Text.ElideRight
                    text: linkRow.modelData.name
                    color: Theme.subtext
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 84
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: linkRow.modelData.state
                        + (linkRow.modelData.addresses.length > 0
                            ? "  " + linkRow.modelData.addresses.join(" ") : "")
                    color: linkRow.modelData.state === "UP" ? Theme.success
                        : (linkRow.modelData.state === "DOWN" ? Theme.warning : Theme.overlay)
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    renderType: Text.NativeRendering
                }
            }
        }

        Text {
            visible: Link.available && Link.links.length === 0
            width: parent.width
            text: I18n.t("panel.link.empty")
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }
    }
}
