import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.components
import qs.core

// 左区时钟卡片：日历+日期 → 时钟+时间 → 周数徽标+星期（SystemClock 每秒驱动）
Row {
    id: root

    spacing: Metrics.clockGroupGap

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // 组内所有子项统一为药丸高度（Row 在交叉轴不自动居中，高度一致才能纵向对齐）；
    // 文字在 22px 盒内 AlignVCenter，避免行框比字形高导致视觉上偏上
    component ContentGroup: Row {
        spacing: Metrics.clockIconTextGap
    }

    component GroupText: Text {
        height: Metrics.modeButtonHeight
        verticalAlignment: Text.AlignVCenter
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Metrics.textSize
        font.letterSpacing: 0.3
        renderType: Text.NativeRendering
    }

    // 日期组
    ContentGroup {
        CalendarGlyph {
        }
        GroupText {
            text: I18n.formatClockDate(clock.date)
        }
    }

    // 时间组
    ContentGroup {
        ClockGlyph {
        }
        GroupText {
            text: I18n.formatClockTime(clock.date)
        }
    }

    // 周数 + 星期组：subtext 描边矩形内为 ISO 8601 周数（透明底，实底药丸在毛玻璃上突兀）
    ContentGroup {
        Rectangle {
            readonly property real dpr: Window.window ? Window.window.devicePixelRatio : 1

            width: weekText.implicitWidth + Metrics.modeButtonPadding * 2
            height: Metrics.modeButtonHeight
            radius: Metrics.modeButtonRadius
            color: "transparent"
            border.width: Metrics.snap(1, dpr)
            border.color: Theme.weekBadge

            Text {
                id: weekText
                anchors.centerIn: parent
                text: I18n.isoWeek(clock.date)
                color: Theme.weekBadgeText
                font.family: Theme.fontFamily
                font.pixelSize: Metrics.textSize
                renderType: Text.NativeRendering
            }
        }
        GroupText {
            text: I18n.formatClockWeekday(clock.date)
        }
    }
}
