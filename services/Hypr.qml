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

    function focusWorkspace(id) {
        if (!id || id < 1)
            return;
        // 0.57 的 Lua API 接受数字 id；字符串形式的 {workspace="x"} 会报 selector 错误
        Quickshell.execDetached(["hyprctl", "eval",
            "hl.get_active_monitor():set_workspace(" + id + ")"]);
    }
}
