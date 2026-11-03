pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// DeepSeek 余额：官方矢量标 + 金额（只有金额没有分母，不画进度环）
Item {
    id: root

    readonly property bool ready: QuotaDeepSeek.available
    readonly property string amount: root.ready
        ? Format.money(QuotaDeepSeek.total, QuotaDeepSeek.currency) : "--"
    readonly property color amountColor: !root.ready
        ? Theme.overlay : (QuotaDeepSeek.sufficient ? Theme.text : Theme.warning)
    readonly property color markColor: !root.ready
        ? Theme.overlay : (QuotaDeepSeek.sufficient ? Theme.deepseekBrand : Theme.warning)

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

    implicitWidth: mark.implicitWidth + 6 + amountLabel.implicitWidth
    implicitHeight: Metrics.workspaceCell

    DeepSeekMark {
        id: mark
        anchors.verticalCenter: parent.verticalCenter
        color: root.markColor
    }

    Text {
        id: amountLabel
        anchors {
            left: mark.right
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
        cursorShape: QuotaDeepSeek.manualReady ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: QuotaDeepSeek.manualRefresh()
    }

    Tooltip {
        targetItem: root
        title: I18n.t("quota.deepseek")
        detail: root.detail
        visible: hover.containsMouse
    }
}
