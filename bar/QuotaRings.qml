pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// Kimi 额度：矢量标 + 7 天环（跟天数）+ 5 小时环（跟小时数），每个环配自己的重置倒计时
// 环与资源环共用用量两档（<80% sky、≥80% peach），倒计时文字用正文色；所有子项同高，保证 Row 内上下居中对齐
Row {
    id: root

    spacing: 8

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
            color: Theme.usageColor(item.ratio),
            title: I18n.t(item.labelKey)
        }));
    }

    function resetOf(entry) {
        if (!root.ready || entry.resetAt <= 0)
            return "";
        const ms = entry.resetAt - QuotaKimi.now;
        // 7 天窗口按天看（2D），5 小时窗口按小时看（3H）
        return entry.id === "7d" ? Format.countdownDays(ms) : Format.countdown(ms);
    }

    Item {
        width: kimiMark.implicitWidth
        height: Metrics.ringSize

        KimiMark {
            id: kimiMark
            anchors.centerIn: parent
        }
    }

    Repeater {
        model: root.entries

        delegate: Row {
            id: group
            required property var modelData

            spacing: 4
            height: Metrics.ringSize

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
                height: Metrics.ringSize

                Text {
                    id: resetLabel
                    anchors.centerIn: parent
                    text: group.resetText
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Metrics.textSize
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: resetHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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
