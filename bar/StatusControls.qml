pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import qs.components
import qs.core
import qs.services

// 右区状态卡内容：主题切换｜麦克风｜音量｜亮度｜电池，一张卡内横向排列
Row {
    id: root

    // 请求开关白噪音弹层（由 shell.qml 的 NoisePopup 宿主处理）
    signal noiseRequested

    spacing: Metrics.statusModuleGap

    readonly property color batteryColor: Theme.batteryColor(Power.percentage)
    // 电池插电时环心闪电（viewBox 1024 填充矢量，颜色跟随环的分档色）
    readonly property string boltPath: "M771.328 465.8176L256 1024l150.1184-450.304A7.9872 7.9872 0 0 0 398.4896 563.2H252.9792c-46.4896 0-77.4656-48.128-58.2656-90.5216l197.7856-435.2A64.1536 64.1536 0 0 1 450.816 0H870.4l-197.888 346.4192A8.0384 8.0384 0 0 0 679.424 358.4h44.8c55.808 0 84.8896 66.4064 47.104 107.4176z"
    readonly property string themeLabel: I18n.t("theme." + Config.themeName)
    readonly property string themeDetail: root.themeLabel
        + (Config.themeName === "auto"
            ? " · " + I18n.t("theme." + (Config.effectiveTheme === "latte" ? "light" : "dark"))
            : "")

    readonly property string volumeDetail: {
        const value = Format.percent(Audio.volume);
        return Audio.muted ? I18n.t("tooltip.muted") + " · " + value : value;
    }

    readonly property string batteryDetail: {
        if (!Power.available)
            return I18n.t("common.na");
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

    // ---------------- 主题切换 ----------------
    Item {
        id: themeCell

        width: themeButton.width
        height: Metrics.ringSize

        Rectangle {
            id: themeButton

            readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

            anchors.centerIn: parent
            width: Metrics.snap(themeText.implicitWidth + Metrics.modeButtonPadding * 2, dpr)
            height: Metrics.snap(Metrics.modeButtonHeight, dpr)
            radius: Metrics.modeButtonRadius
            color: "transparent"
            border.width: Metrics.snap(1, dpr)
            border.color: themeHover.containsMouse ? Theme.text : Theme.subtext

            Text {
                id: themeText
                anchors.centerIn: parent
                text: root.themeLabel
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Metrics.textSize
            }
        }

        MouseArea {
            id: themeHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Config.cycleTheme()
        }

        Tooltip {
            targetItem: themeCell
            title: I18n.t("tooltip.theme")
            detail: root.themeDetail
            visible: themeHover.containsMouse
        }
    }

    // ---------------- 白噪音 ----------------
    Item {
        id: noiseCell

        width: Metrics.ringSize
        height: Metrics.ringSize

        NoiseGlyph {
            anchors.centerIn: parent
            kind: "button"
            size: Metrics.statusGlyphSize
            color: WhiteNoise.track !== "none" ? Theme.noise : Theme.subtext
        }

        MouseArea {
            id: noiseHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.noiseRequested()
        }

        Tooltip {
            targetItem: noiseCell
            title: I18n.t("tooltip.noise")
            detail: I18n.t("noise." + WhiteNoise.track)
            visible: noiseHover.containsMouse
        }
    }

    // ---------------- 麦克风静音 ----------------
    Item {
        id: micCell

        visible: Audio.sourceAvailable
        width: Metrics.ringSize
        height: Metrics.ringSize

        StatusGlyph {
            anchors.centerIn: parent
            kind: "mic"
            muted: Audio.sourceMuted
            color: Audio.sourceMuted ? Theme.overlay : Theme.text
        }

        MouseArea {
            id: micHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleSourceMute()
        }

        Tooltip {
            targetItem: micCell
            title: I18n.t("tooltip.mic")
            detail: Audio.sourceMuted ? I18n.t("tooltip.mic.muted") : I18n.t("tooltip.mic.on")
            visible: micHover.containsMouse
        }
    }

    // ---------------- 音量 ----------------
    InfoRing {
        id: volumeModule

        visible: Audio.available
        value: Audio.volume
        color: Audio.muted ? Theme.overlay : Theme.volume
        letter: "V"
        shrinkLetter: false
        title: I18n.t("tooltip.volume")
        detail: root.volumeDetail
        interactive: true
        wheelEnabled: true

        onClicked: Audio.toggleMute()
        onWheeled: function (direction) {
            Audio.adjustVolume(direction * 0.05);
        }
    }

    // ---------------- 亮度 ----------------
    InfoRing {
        id: brightnessModule

        visible: Brightness.available
        value: Brightness.level
        color: Theme.brightness
        letter: "L"
        shrinkLetter: false
        title: I18n.t("tooltip.brightness")
        detail: Format.percent(Brightness.level)
        wheelEnabled: true

        onWheeled: function (direction) {
            Brightness.adjust(direction * 0.05);
        }
    }

    // ---------------- 电池 ----------------
    InfoRing {
        id: batteryModule

        visible: Power.available
        value: Power.percentage
        color: root.batteryColor
        letter: Power.pluggedIn ? "" : "B"
        iconPath: Power.pluggedIn ? root.boltPath : ""
        shrinkLetter: false
        title: I18n.t("tooltip.battery")
        detail: root.batteryDetail
    }
}
