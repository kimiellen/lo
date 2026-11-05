pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.core
import qs.services

// 系统三环：CPU / 内存 / 磁盘，hover 显示明细，左键打开控制面板，数据不可用时显示 --
Row {
    id: root

    signal panelRequested()

    spacing: 8

    readonly property string unavailable: I18n.t("common.na")

    InfoRing {
        value: SystemStats.cpuUsage
        color: SystemStats.cpuAvailable ? Theme.usageColor(SystemStats.cpuUsage) : Theme.overlay
        letter: SystemStats.cpuAvailable ? I18n.t("ring.cpu") : root.unavailable
        title: I18n.t("tooltip.cpu")
        detail: SystemStats.cpuAvailable ? Format.percent(SystemStats.cpuUsage) : root.unavailable
        interactive: true

        onClicked: root.panelRequested()
    }

    InfoRing {
        value: SystemStats.memoryUsage
        color: SystemStats.memoryAvailable ? Theme.usageColor(SystemStats.memoryUsage) : Theme.overlay
        letter: SystemStats.memoryAvailable ? I18n.t("ring.memory") : root.unavailable
        title: I18n.t("tooltip.memory")
        detail: SystemStats.memoryAvailable
            ? Format.percent(SystemStats.memoryUsage) + " · "
                + Format.size(SystemStats.memoryUsedKb) + " / " + Format.size(SystemStats.memoryTotalKb)
            : root.unavailable
        interactive: true

        onClicked: root.panelRequested()
    }

    InfoRing {
        value: SystemStats.diskUsage
        color: SystemStats.diskAvailable ? Theme.usageColor(SystemStats.diskUsage) : Theme.overlay
        letter: SystemStats.diskAvailable ? I18n.t("ring.disk") : root.unavailable
        title: I18n.t("tooltip.disk")
        detail: SystemStats.diskAvailable
            ? Format.percent(SystemStats.diskUsage) + " · "
                + Format.size(SystemStats.diskUsedKb) + " / " + Format.size(SystemStats.diskTotalKb)
            : root.unavailable
        interactive: true

        onClicked: root.panelRequested()
    }
}
