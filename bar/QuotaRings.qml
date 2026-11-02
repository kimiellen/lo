pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// Kimi 额度：最多两个窗口环（5h/7d 优先，月窗口回退）+ 最早到期的重置倒计时
Row {
    id: root

    spacing: 7

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
                title: I18n.t("quota.kimi"),
                detail: root.unavailableText
            }];
        }
        const list = [];
        const count = Math.min(2, QuotaKimi.windows.length);
        for (let i = 0; i < count; ++i) {
            const item = QuotaKimi.windows[i];
            list.push({
                id: item.id,
                letter: item.letter,
                ratio: item.ratio,
                resetAt: item.resetAt,
                color: Theme.kimi,
                title: I18n.t(item.labelKey),
                detail: ""
            });
        }
        return list;
    }

    // 两个窗口中最早到期的重置
    readonly property double nextResetAt: {
        let best = 0;
        const count = Math.min(2, QuotaKimi.windows.length);
        for (let i = 0; i < count; ++i) {
            const at = QuotaKimi.windows[i].resetAt;
            if (at > QuotaKimi.now && (best === 0 || at < best))
                best = at;
        }
        return best;
    }

    readonly property string resetText: root.ready
        ? Format.countdown(root.nextResetAt - QuotaKimi.now) : ""

    readonly property string resetDetail: {
        const parts = [];
        const count = Math.min(2, QuotaKimi.windows.length);
        for (let i = 0; i < count; ++i) {
            const item = QuotaKimi.windows[i];
            const reset = Format.countdown(item.resetAt - QuotaKimi.now);
            let text = root.shortLabel(item.id) + " " + Format.percent(item.ratio);
            if (reset !== "")
                text += " · " + I18n.resetIn(reset);
            parts.push(text);
        }
        return parts.join(" · ");
    }

    function shortLabel(id) {
        if (id === "5h" || id === "7d" || id === "month" || id === "code")
            return I18n.t("quota.kimi." + id + ".short");
        return I18n.t("quota.kimi");
    }

    Repeater {
        model: root.entries

        delegate: InfoRing {
            id: ringItem
            required property var modelData

            value: ringItem.modelData.ratio
            color: ringItem.modelData.color
            letter: ringItem.modelData.letter
            title: ringItem.modelData.title
            detail: {
                if (!root.ready)
                    return root.unavailableText;
                let text = Format.percent(ringItem.modelData.ratio);
                const reset = Format.countdown(ringItem.modelData.resetAt - QuotaKimi.now);
                if (reset !== "")
                    text += " · " + I18n.resetIn(reset);
                return text;
            }
        }
    }

    Item {
        id: resetItem

        readonly property bool shown: root.resetText !== ""

        visible: shown
        width: resetLabel.implicitWidth
        height: 18

        Text {
            id: resetLabel
            anchors.centerIn: parent
            text: root.resetText
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: 10
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
            title: I18n.t("quota.kimi")
            detail: root.resetDetail
            visible: resetHover.containsMouse
        }
    }
}
