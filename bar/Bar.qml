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

    readonly property int cardHeight: Config.barHeight
    readonly property int outerMarginX: Metrics.outerMarginX
    readonly property int outerMarginY: Metrics.outerMarginY
    readonly property int cardGap: Metrics.cardGap
    // 底部补偿：Hyprland 在独占区边界会再补一次 gaps_out，减掉后卡片底到窗口顶才等于上下边距
    readonly property int bottomPad: Math.max(0, Metrics.outerMarginY - Hypr.gapsOut)
    readonly property int windowHeight: bar.outerMarginY + bar.cardHeight + bar.bottomPad

    color: "transparent"
    implicitHeight: bar.windowHeight
    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "vbc-io-bar"
    WlrLayershell.exclusiveZone: bar.windowHeight
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

    // 右区：状态三环 → 状态图标
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

            StatusRings {
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
