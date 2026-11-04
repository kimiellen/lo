import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.core
import qs.services

// 顶栏窗口：top layer，独占「上下边距 + 卡片高 + 底部补偿」，三区卡片布局（中区绝对居中）
PanelWindow {
    id: bar

    // 打开控制面板（由系统环 / 状态图标发出）
    signal panelRequested(string tab)

    // 设备像素比：分段缩放下只有窗口能给出真实值（Screen.devicePixelRatio 只返回整数）
    readonly property real dpr: bar.devicePixelRatio
    // 卡片高 / 上边距按设备像素吸附，卡片上下边落在整像素上，1px 描边才均匀
    readonly property real cardHeight: Metrics.barCardHeight(Config.barHeight, bar.dpr)
    // 外边距跟随 gaps_out 伸缩（最小值 15/12），换显示器/改 gaps 无需手调
    readonly property real outerMarginX: Metrics.snap(Metrics.outerMarginXFor(Hypr.gapsOut), bar.dpr)
    readonly property real outerMarginY: Metrics.barMarginY(Hypr.gapsOut, bar.dpr)
    // 卡片间隙同样吸附：卡片左边 = 已有卡片宽度 + 间隙之和，逐项吸附后整条卡片链都落在像素网格上
    readonly property real cardGap: Metrics.snap(Metrics.cardGap, bar.dpr)
    // 底部补偿：Hyprland 在独占区边界会再补一次 gaps_out，减掉后卡片底到窗口顶才等于上下边距
    readonly property real bottomPad: Math.max(0, Metrics.snap(bar.outerMarginY - Hypr.gapsOut, bar.dpr))
    readonly property real windowHeight: bar.outerMarginY + bar.cardHeight + bar.bottomPad

    color: "transparent"
    implicitHeight: bar.windowHeight
    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "vbc-io-bar"
    WlrLayershell.exclusiveZone: Math.ceil(bar.windowHeight)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // 左区：工作区 → 系统三环 → 额度 → 余额
    Row {
        id: leftSection
        spacing: bar.cardGap
        anchors {
            left: parent.left
            leftMargin: bar.outerMarginX
            top: parent.top
            topMargin: bar.outerMarginY
        }

        BarCard {
            id: workspaceCard
            height: bar.cardHeight

            Workspaces {
                anchors.centerIn: parent
                onPanelRequested: bar.panelRequested("workspace")
            }
        }

        BarCard {
            id: systemCard
            height: bar.cardHeight

            SystemRings {
                anchors.centerIn: parent
                onPanelRequested: bar.panelRequested("network")
            }
        }

        BarCard {
            id: quotaCard
            height: bar.cardHeight

            QuotaRings {
                anchors.centerIn: parent
            }
        }

        BarCard {
            id: balanceCard
            height: bar.cardHeight

            BalanceTag {
                anchors.centerIn: parent
            }
        }
    }

    // 中区：日期 - 时间 - 星期（卡片中心严格对齐屏幕水平中心）
    BarCard {
        id: clockCard
        height: bar.cardHeight
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: bar.outerMarginY
        }

        Clock {
            anchors.centerIn: parent
        }
    }

    // 右区：状态卡（主题/麦克风/音量/亮度/电池）→ 状态图标
    Row {
        id: rightSection
        spacing: bar.cardGap
        anchors {
            right: parent.right
            rightMargin: bar.outerMarginX
            top: parent.top
            topMargin: bar.outerMarginY
        }

        BarCard {
            id: statusCard
            height: bar.cardHeight

            StatusControls {
                anchors.centerIn: parent
            }
        }

        BarCard {
            id: iconCard
            height: bar.cardHeight

            StatusIcons {
                anchors.centerIn: parent
                onPanelRequested: function (tab) {
                    bar.panelRequested(tab);
                }
            }
        }
    }
}
