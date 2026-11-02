pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// DeepSeek 余额：圆角方块图标 + 金额（只有金额没有分母，不画进度环）
Item {
    id: root

    readonly property bool ready: QuotaDeepSeek.available
    readonly property string amount: root.ready
        ? Format.money(QuotaDeepSeek.total, QuotaDeepSeek.currency) : "--"
    readonly property color amountColor: !root.ready
        ? Theme.overlay : (QuotaDeepSeek.sufficient ? Theme.text : Theme.warning)
    readonly property color badgeColor: !root.ready
        ? Theme.overlay : (QuotaDeepSeek.sufficient ? Theme.deepseek : Theme.warning)

    readonly property string detail: {
        if (!QuotaDeepSeek.configured)
            return QuotaDeepSeek.error === "insecure" ? I18n.t("quota.insecure") : I18n.t("quota.noKey");
        if (QuotaDeepSeek.error === "auth")
            return I18n.t("quota.auth");
        if (QuotaDeepSeek.error === "unreachable")
            return I18n.t("quota.offline");
        if (QuotaDeepSeek.error === "parse")
            return I18n.t("quota.parse");
        if (!root.ready)
            return I18n.t("quota.loading");
        return root.amount + (QuotaDeepSeek.sufficient ? "" : " · " + I18n.t("quota.deepseek.low"));
    }

    implicitWidth: badge.width + 6 + amountLabel.implicitWidth
    implicitHeight: Metrics.workspaceCell

    Rectangle {
        id: badge
        width: 16
        height: 16
        radius: 5
        anchors.verticalCenter: parent.verticalCenter
        color: root.badgeColor

        Text {
            anchors.centerIn: parent
            text: "D"
            color: Theme.bg
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.textSizeSmall
            font.bold: true
            renderType: Text.NativeRendering
        }
    }

    Text {
        id: amountLabel
        anchors {
            left: badge.right
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        text: root.amount
        color: root.amountColor
        font.family: Theme.fontFamily
        font.pixelSize: Metrics.textSize
        renderType: Text.NativeRendering

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Tooltip {
        targetItem: root
        title: I18n.t("quota.deepseek")
        detail: root.detail
        visible: hover.containsMouse
    }
}
