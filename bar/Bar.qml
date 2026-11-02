import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.core
import qs.services

// 顶栏窗口：top layer，独占「gap + 卡片高」，三区卡片布局（中区绝对居中）
PanelWindow {
    id: bar

    // 打开控制面板（由系统环 / 状态图标发出）
    signal panelRequested(string tab)

    // 屏幕顶/左/右与卡片间隙统一取 Hyprland 窗口外间隙，避免比桌面窗口更松或更紧
    readonly property int gap: Hypr.gapsOut
    readonly property int cardHeight: Config.barHeight
    // 窗口高 = 顶部间隙 + 卡片；卡片贴住底边，底部间隙交给 Hyprland 的 gaps_out
    readonly property int windowHeight: bar.gap + bar.cardHeight

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

    // 卡片区域的背景模糊：ext-background-effect-v1（Hyprland 0.57 原生支持，无需 layerrule）
    BackgroundEffect.blurRegion: Region {
        Region { item: workspaceCard; radius: Metrics.cardRadius }
        Region { item: systemCard; radius: Metrics.cardRadius }
        Region { item: quotaCard; radius: Metrics.cardRadius }
        Region { item: balanceCard; radius: Metrics.cardRadius }
        Region { item: clockCard; radius: Metrics.cardRadius }
        Region { item: statusCard; radius: Metrics.cardRadius }
        Region { item: iconCard; radius: Metrics.cardRadius }
    }

    // 左区：工作区 → 系统三环 → 额度 → 余额
    Row {
        id: leftSection
        spacing: bar.gap
        anchors {
            left: parent.left
            leftMargin: bar.gap
            top: parent.top
            topMargin: bar.gap
        }

        GlassCard {
            id: workspaceCard
            height: bar.cardHeight

            Workspaces {
                anchors.centerIn: parent
            }
        }

        GlassCard {
            id: systemCard
            height: bar.cardHeight

            SystemRings {
                anchors.centerIn: parent
                onPanelRequested: bar.panelRequested("network")
            }
        }

        GlassCard {
            id: quotaCard
            height: bar.cardHeight

            QuotaRings {
                anchors.centerIn: parent
            }
        }

        GlassCard {
            id: balanceCard
            height: bar.cardHeight

            BalanceTag {
                anchors.centerIn: parent
            }
        }
    }

    // 中区：日期 - 时间 - 星期（卡片中心严格对齐屏幕水平中心）
    GlassCard {
        id: clockCard
        height: bar.cardHeight
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: bar.gap
        }

        Clock {
            anchors.centerIn: parent
        }
    }

    // 右区：状态三环 → 状态图标
    Row {
        id: rightSection
        spacing: bar.gap
        anchors {
            right: parent.right
            rightMargin: bar.gap
            top: parent.top
            topMargin: bar.gap
        }

        GlassCard {
            id: statusCard
            height: bar.cardHeight

            StatusRings {
                anchors.centerIn: parent
            }
        }

        GlassCard {
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
