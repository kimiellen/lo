pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 状态三环：音量/亮度/电池，设备缺失自动隐藏；音量静音+滚轮、亮度滚轮
Row {
    id: root

    spacing: 8

    readonly property string unavailable: I18n.t("common.na")
    readonly property color batteryColor: Power.charging ? Theme.charging
        : (Power.percentage < 0.2 ? Theme.warning : Theme.battery)

    readonly property string batteryDetail: {
        if (!Power.available)
            return root.unavailable;
        const parts = [Format.percent(Power.percentage)];
        if (Power.full) {
            parts.push(I18n.t("tooltip.full"));
        } else if (Power.charging) {
            const remaining = Format.duration(Power.timeToFull);
            parts.push(remaining !== "" ? remaining : I18n.t("tooltip.charging"));
        } else {
            const remaining = Format.duration(Power.timeToEmpty);
            if (remaining !== "")
                parts.push(remaining);
        }
        const power = Format.watts(Power.changeRate);
        if (power !== "")
            parts.push(power);
        return parts.join(" · ");
    }

    InfoRing {
        visible: Audio.available
        value: Audio.volume
        color: Audio.muted ? Theme.overlay : Theme.volume
        letter: Audio.muted ? I18n.t("ring.muted") : I18n.t("ring.volume")
        title: I18n.t("tooltip.volume")
        detail: Audio.muted
            ? I18n.t("tooltip.muted") + " · " + Format.percent(Audio.volume)
            : Format.percent(Audio.volume)
        interactive: true
        wheelEnabled: true

        onClicked: Audio.toggleMute()
        onWheeled: function (direction) {
            Audio.adjustVolume(direction * 0.05);
        }
    }

    InfoRing {
        visible: Brightness.available
        value: Brightness.level
        color: Theme.brightness
        letter: I18n.t("ring.brightness")
        title: I18n.t("tooltip.brightness")
        detail: Format.percent(Brightness.level)
        wheelEnabled: true

        onWheeled: function (direction) {
            Brightness.adjust(direction * 0.05);
        }
    }

    InfoRing {
        visible: Power.available
        value: Power.percentage
        color: root.batteryColor
        letter: "" + Math.round(Power.percentage * 100)
        title: I18n.t("tooltip.battery")
        detail: root.batteryDetail
    }
}
