pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Hyprland 状态与动作。0.56+ 移除了字符串 dispatch，统一走 Lua eval。
Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces
    readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0

    // Hyprland 窗口外间隙：顶栏用它推算底部补偿（屏边距 − gaps_out），读不到时回退 10
    property int gapsOut: 10

    function focusWorkspace(id) {
        if (!id || id < 1)
            return;
        // 0.57 的 Lua API 接受数字 id；字符串形式的 {workspace="x"} 会报 selector 错误
        Quickshell.execDetached(["hyprctl", "eval",
            "hl.get_active_monitor():set_workspace(" + id + ")"]);
    }

    // general:gaps_out -j 返回 {"css": "10 10 10 10", ...}，css 顺序为上右下左
    Process {
        id: gapsProcess
        command: ["hyprctl", "getoption", "general:gaps_out", "-j"]
        stdout: StdioCollector {
            id: gapsOutput
            waitForEnd: true
            onStreamFinished: root.applyGaps(gapsOutput.text)
        }
    }

    // hyprctl reload 后间隙可能变化：30s 复查一次，值不变则不会触发重排
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!gapsProcess.running)
                gapsProcess.running = true;
        }
    }

    function applyGaps(text) {
        try {
            const parts = (JSON.parse(text).css || "").trim().split(/\s+/);
            // 1 个值=四边相同，2 个值=上下/左右，4 个值=上右下左
            const left = parseInt(parts[3] !== undefined ? parts[3]
                : (parts[1] !== undefined ? parts[1] : parts[0]), 10);
            if (isFinite(left) && left >= 0)
                root.gapsOut = left;
        } catch (e) {
            // 保持回退值：取不到 gap 不应让顶栏失效
        }
    }
}
