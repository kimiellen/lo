pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 代理 tab：mihomo 的规则/全局/直连切换、当前节点与 TUN 状态
Item {
    id: root

    implicitHeight: body.height

    readonly property string errorTitle: {
        if (!Proxy.configured)
            return I18n.t("panel.proxy.noConfig");
        if (Proxy.error === "auth")
            return I18n.t("panel.proxy.auth");
        return I18n.t("panel.proxy.unavailable");
    }

    readonly property string errorDetail: {
        if (!Proxy.configured)
            return I18n.t("panel.proxy.noConfig.hint");
        if (Proxy.error === "auth")
            return I18n.t("panel.proxy.auth.hint");
        return I18n.t("panel.proxy.unavailable.hint");
    }

    Column {
        id: body
        width: root.width
        spacing: 8

        EmptyState {
            visible: !Proxy.available
            width: parent.width
            title: root.errorTitle
            detail: root.errorDetail
        }

        // ---------------- 模式切换 ----------------
        Column {
            visible: Proxy.available
            width: parent.width
            spacing: 4

            Text {
                text: I18n.t("panel.proxy.mode")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Row {
                id: modeRow
                width: parent.width
                spacing: 6

                Repeater {
                    model: ["rule", "global", "direct"]

                    delegate: Rectangle {
                        id: modeButton
                        required property string modelData

                        width: (modeRow.width - modeRow.spacing * 2) / 3
                        height: 24
                        radius: 6
                        color: Proxy.mode === modeButton.modelData ? Theme.track : "transparent"
                        border.width: 1
                        border.color: Proxy.mode === modeButton.modelData ? Theme.accent : Theme.trackDim
                        opacity: Proxy.busy ? 0.55 : 1

                        Text {
                            anchors.centerIn: parent
                            text: I18n.proxyMode(modeButton.modelData)
                            color: Proxy.mode === modeButton.modelData ? Theme.text : Theme.subtext
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Proxy.busy ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: Proxy.setMode(modeButton.modelData)
                        }
                    }
                }
            }
        }

        Text {
            visible: Proxy.busy
            text: I18n.t("panel.proxy.switching")
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        Text {
            visible: Proxy.failed && !Proxy.busy
            text: I18n.t("panel.proxy.failed")
            color: Theme.warning
            font.family: Theme.fontFamily
            font.pixelSize: 10
            renderType: Text.NativeRendering
        }

        // ---------------- 当前节点 ----------------
        Item {
            visible: Proxy.available
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.proxy.node")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 84
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                text: Proxy.node !== "" ? Proxy.node : I18n.t("common.na")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }
        }

        Text {
            visible: Proxy.available && Proxy.nodeGroup !== ""
            width: parent.width
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: I18n.t("panel.proxy.group") + " · " + Proxy.nodeGroup
            color: Theme.overlay
            font.family: Theme.fontFamily
            font.pixelSize: 9
            renderType: Text.NativeRendering
        }

        // ---------------- TUN ----------------
        Item {
            visible: Proxy.available
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.proxy.tun")
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Proxy.tun ? I18n.t("panel.proxy.tun.on") : I18n.t("panel.proxy.tun.off")
                color: Proxy.tun ? Theme.success : Theme.overlay
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering
            }
        }

        // ---------------- 手动刷新 ----------------
        Item {
            width: parent.width
            height: 18

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("panel.proxy.refresh")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                renderType: Text.NativeRendering

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Proxy.refresh()
                }
            }
        }
    }
}
