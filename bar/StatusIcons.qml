pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 状态图标：代理 / 网络 / 蓝牙三枚，不可用时变灰，点击打开对应面板 tab
Row {
    id: root

    signal panelRequested(string tab)

    spacing: 9

    readonly property var icons: [
        { key: "proxy", glyph: "\uF0AC" },
        { key: "network", glyph: "\uF1EB" },
        { key: "bluetooth", glyph: "\uF294" }
    ]

    function colorFor(key) {
        if (key === "proxy")
            return Proxy.configured && Proxy.available ? Theme.proxy : Theme.overlay;
        if (key === "network") {
            if (!Wifi.available || !Wifi.powered)
                return Theme.overlay;
            return Wifi.connected ? Theme.network : Theme.subtext;
        }
        if (key === "bluetooth") {
            if (!BlueZ.available || !BlueZ.powered)
                return Theme.overlay;
            return BlueZ.connectedDevices.length > 0 ? Theme.bluetooth : Theme.subtext;
        }
        return Theme.subtext;
    }

    function detailFor(key) {
        if (key === "proxy") {
            if (!Proxy.configured || !Proxy.available)
                return I18n.t("status.unavailable");
            if (Proxy.busy)
                return I18n.t("panel.proxy.switching");
            const parts = [I18n.proxyMode(Proxy.mode)];
            if (Proxy.node !== "")
                parts.push(Proxy.node);
            return parts.join(" · ");
        }
        if (key === "network") {
            if (!Wifi.available)
                return I18n.t("status.unavailable");
            if (!Wifi.powered)
                return I18n.t("panel.wifi.off");
            return Wifi.connected ? Wifi.ssid : I18n.t("panel.wifi.idle");
        }
        if (key === "bluetooth") {
            if (!BlueZ.available)
                return I18n.t("status.unavailable");
            if (!BlueZ.powered)
                return I18n.t("panel.bt.off");
            const count = BlueZ.connectedDevices.length;
            return count > 0 ? count + " " + I18n.t("status.connected") : I18n.t("status.on");
        }
        return "";
    }

    Repeater {
        model: root.icons

        delegate: Item {
            id: cell
            required property var modelData

            readonly property bool shown: cell.modelData.key !== "bluetooth" || BlueZ.available

            visible: shown
            width: Metrics.iconSize
            height: Metrics.iconSize

            Text {
                anchors.centerIn: parent
                visible: cell.modelData.key !== "proxy"
                text: cell.modelData.glyph
                color: root.colorFor(cell.modelData.key)
                font.family: Theme.fontFamily
                font.pixelSize: Metrics.iconGlyphSize
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }

            // 代理：地球底形 + 当前模式的派生徽标（规则/全局/直连）
            ProxyGlyph {
                anchors.centerIn: parent
                visible: cell.modelData.key === "proxy"
                mode: Proxy.available ? Proxy.mode : ""
                color: root.colorFor("proxy")
                cutColor: Theme.cardBg

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.panelRequested(cell.modelData.key)
            }

            Tooltip {
                targetItem: cell
                title: I18n.t("tooltip." + cell.modelData.key)
                detail: root.detailFor(cell.modelData.key)
                visible: hover.containsMouse
            }
        }
    }
}
