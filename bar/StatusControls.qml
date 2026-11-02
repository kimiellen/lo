pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import qs.components
import qs.core
import qs.services

// 右区状态卡内容：主题切换｜麦克风｜音量｜亮度｜电池，一张卡内横向排列
Row {
    id: root

    spacing: Metrics.statusModuleGap

    readonly property color batteryColor: Theme.batteryColor(Power.percentage, Power.charging)
    // 音量图标三档：静音/0 → 无；<1/3 → 1 道；<2/3 → 2 道；其余 3 道
    readonly property int volumeWaves: Audio.muted || Audio.volume <= 0 ? 0
        : (Audio.volume < 1 / 3 ? 1 : (Audio.volume < 2 / 3 ? 2 : 3))
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
    Row {
        id: volumeModule

        visible: Audio.available
        spacing: Metrics.statusIconGap

        Item {
            id: volumeIconCell

            width: Metrics.statusGlyphSize
            height: Metrics.ringSize

            StatusGlyph {
                anchors.centerIn: parent
                kind: "speaker"
                waves: root.volumeWaves
                muted: Audio.muted
                color: Audio.muted ? Theme.overlay : Theme.volume
            }

            MouseArea {
                id: volumeIconHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute()
                onWheel: function (wheel) {
                    if (wheel.angleDelta.y === 0)
                        return;
                    Audio.adjustVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05);
                    wheel.accepted = true;
                }
            }

            Tooltip {
                targetItem: volumeIconCell
                title: I18n.t("tooltip.volume")
                detail: root.volumeDetail
                visible: volumeIconHover.containsMouse
            }
        }

        InfoRing {
            value: Audio.volume
            color: Audio.muted ? Theme.overlay : Theme.volume
            letter: Format.ringValue(Audio.volume)
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
    }

    // ---------------- 亮度 ----------------
    Row {
        id: brightnessModule

        visible: Brightness.available
        spacing: Metrics.statusIconGap

        Item {
            id: brightnessIconCell

            width: Metrics.statusGlyphSize
            height: Metrics.ringSize

            StatusGlyph {
                anchors.centerIn: parent
                kind: "sun"
                color: Theme.brightness
            }

            MouseArea {
                id: brightnessHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onWheel: function (wheel) {
                    if (wheel.angleDelta.y === 0)
                        return;
                    Brightness.adjust(wheel.angleDelta.y > 0 ? 0.05 : -0.05);
                    wheel.accepted = true;
                }
            }

            Tooltip {
                targetItem: brightnessIconCell
                title: I18n.t("tooltip.brightness")
                detail: Format.percent(Brightness.level)
                visible: brightnessHover.containsMouse
            }
        }

        InfoRing {
            value: Brightness.level
            color: Theme.brightness
            letter: Format.ringValue(Brightness.level)
            shrinkLetter: false
            title: I18n.t("tooltip.brightness")
            detail: Format.percent(Brightness.level)
            wheelEnabled: true

            onWheeled: function (direction) {
                Brightness.adjust(direction * 0.05);
            }
        }
    }

    // ---------------- 电池 ----------------
    Row {
        id: batteryModule

        visible: Power.available
        spacing: Metrics.statusIconGap

        Item {
            id: batteryIconCell

            width: Metrics.statusGlyphSize
            height: Metrics.ringSize

            StatusGlyph {
                anchors.centerIn: parent
                kind: "battery"
                level: Power.percentage
                charging: Power.charging
                color: root.batteryColor
            }

            MouseArea {
                id: batteryHover
                anchors.fill: parent
                hoverEnabled: true
            }

            Tooltip {
                targetItem: batteryIconCell
                title: I18n.t("tooltip.battery")
                detail: root.batteryDetail
                visible: batteryHover.containsMouse
            }
        }

        InfoRing {
            value: Power.percentage
            color: root.batteryColor
            letter: Format.ringValue(Power.percentage)
            shrinkLetter: false
            title: I18n.t("tooltip.battery")
            detail: root.batteryDetail
        }
    }
}
