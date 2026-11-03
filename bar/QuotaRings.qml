pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// Kimi 额度：矢量标 + 7 天环（跟天数）+ 5 小时环（跟小时数），每个环配自己的重置倒计时
// 根是 Item 而非 Row：整卡点击 MouseArea 铺满外层，布局在内部 Row 做
Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    readonly property bool ready: QuotaKimi.available && QuotaKimi.windows.length > 0

    readonly property string unavailableText: {
        if (!QuotaKimi.configured)
            return QuotaKimi.error === "insecure" ? I18n.t("quota.insecure") : I18n.t("quota.noKey");
        if (QuotaKimi.error === "auth")
            return I18n.t("quota.auth");
        if (QuotaKimi.error === "unreachable")
            return I18n.t("quota.offline");
        if (QuotaKimi.error === "parse")
            return I18n.t("quota.parse");
        return I18n.t("quota.loading");
    }

    // 只依赖窗口集合，不依赖 now，避免倒计时每 30s 重建 delegate（环会闪）
    readonly property var entries: {
        if (!root.ready) {
            return [{
                id: "none",
                letter: "--",
                ratio: 0,
                resetAt: 0,
                color: Theme.overlay,
                title: I18n.t("quota.kimi")
            }];
        }
        const picked = [];
        // 先按 7d → 5h 固定顺序取，再用其他窗口（月度/代码）补齐，保证月窗口不被丢弃
        const order = ["7d", "5h"];
        for (const id of order) {
            for (const item of QuotaKimi.windows) {
                if (picked.length < 2 && item.id === id) {
                    picked.push(item);
                    break;
                }
            }
        }
        for (const item of QuotaKimi.windows) {
            if (picked.length >= 2)
                break;
            if (picked.indexOf(item) < 0)
                picked.push(item);
        }
        return picked.map(item => ({
            id: item.id,
            letter: item.letter,
            ratio: item.ratio,
            resetAt: item.resetAt,
            color: root.windowColor(item.id),
            title: I18n.t(item.labelKey)
        }));
    }

    function windowColor(id) {
        if (id === "7d")
            return Theme.kimiWeek;
        if (id === "5h")
            return Theme.kimiSession;
        return Theme.kimi;
    }

    function resetOf(entry) {
        if (!root.ready || entry.resetAt <= 0)
            return "";
        const ms = entry.resetAt - QuotaKimi.now;
        // 7 天窗口按天看（2D），5 小时窗口按小时看（3H）
        return entry.id === "7d" ? Format.countdownDays(ms) : Format.countdown(ms);
    }

    // 点击整卡刷新（冷却 3min，冷却内忽略）；content 里的 hover MouseArea 不消费点击事件，
    // 点击会落到这层
    MouseArea {
        anchors.fill: parent
        cursorShape: QuotaKimi.manualReady ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: QuotaKimi.manualRefresh()
    }

    Row {
        id: content

        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        KimiMark {
            anchors.verticalCenter: parent.verticalCenter
        }

        Repeater {
            model: root.entries

            delegate: Row {
                id: group
                required property var modelData

                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                readonly property string resetText: root.resetOf(modelData)

                InfoRing {
                    value: group.modelData.ratio
                    color: group.modelData.color
                    letter: group.modelData.letter
                    title: group.modelData.title
                    detail: {
                        if (!root.ready)
                            return root.unavailableText;
                        let text = Format.percent(group.modelData.ratio);
                        const reset = root.resetOf(group.modelData);
                        if (reset !== "")
                            text += " · " + I18n.resetIn(reset);
                        return text;
                    }
                }

                Item {
                    id: resetItem

                    visible: group.resetText !== ""
                    width: resetLabel.implicitWidth
                    height: Metrics.workspaceCell

                    Text {
                        id: resetLabel
                        anchors.centerIn: parent
                        text: group.resetText
                        color: group.modelData.color
                        font.family: Theme.fontFamily
                        font.pixelSize: Metrics.textSize
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: resetHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton   // 纯 hover 区，点击冒泡到整卡刷新
                        cursorShape: QuotaKimi.manualReady ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    Tooltip {
                        targetItem: resetItem
                        title: group.modelData.title
                        detail: {
                            if (!root.ready)
                                return root.unavailableText;
                            return Format.percent(group.modelData.ratio) + " · " + I18n.resetIn(group.resetText);
                        }
                        visible: resetHover.containsMouse && group.resetText !== ""
                    }
                }
            }
        }
    }
}
