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

    // 这些事件可能改变窗口顺序、所属工作区或活动窗口；坐标只存在于 lastIpcObject，
    // 按 Quickshell API 要求主动刷新，UI 绑定会在对象更新后自动重算。
    readonly property var windowRefreshEvents: [
        "openwindow", "closewindow", "movewindow", "movewindowv2",
        "activewindow", "activewindowv2", "workspace", "workspacev2",
        "focusedmon", "changefloatingmode"
    ]

    function focusWorkspace(id) {
        if (!id || id < 1)
            return;
        // 0.57 的 Lua API 接受数字 id；字符串形式的 {workspace="x"} 会报 selector 错误
        Quickshell.execDetached(["hyprctl", "eval",
            "hl.get_active_monitor():set_workspace(" + id + ")"]);
    }

    // 返回按 scrolling 从左到右排序的窗口，以及该工作区应对齐 12 点的活动窗口索引。
    // 非当前工作区使用 Hyprland 的 lastwindow；启动后没有记录时退回 focusHistoryID。
    function workspaceModel(id) {
        const windows = [];
        const list = Hyprland.toplevels.values || [];
        for (let i = 0; i < list.length; ++i) {
            const toplevel = list[i];
            if (!toplevel || !toplevel.workspace || toplevel.workspace.id !== id)
                continue;
            const ipc = toplevel.lastIpcObject || {};
            const at = ipc.at || [0, 0];
            const focusHistory = Number(ipc.focusHistoryID);
            windows.push({
                address: toplevel.address || ipc.address || "",
                appKey: ipc.class || ipc.app_id || ipc.initialClass || "",
                x: Number(at[0]) || 0,
                y: Number(at[1]) || 0,
                activated: toplevel.activated,
                focusHistory: isFinite(focusHistory) ? focusHistory : 0x7fffffff
            });
        }

        windows.sort(function (a, b) {
            if (a.x !== b.x)
                return a.x - b.x;
            if (a.y !== b.y)
                return a.y - b.y;
            return a.address < b.address ? -1 : (a.address > b.address ? 1 : 0);
        });

        let activeIndex = -1;
        for (let i = 0; i < windows.length; ++i) {
            if (windows[i].activated) {
                activeIndex = i;
                break;
            }
        }

        let lastAddress = "";
        const workspaceList = Hyprland.workspaces.values || [];
        for (let i = 0; i < workspaceList.length; ++i) {
            const workspace = workspaceList[i];
            if (workspace && workspace.id === id) {
                const ipc = workspace.lastIpcObject || {};
                lastAddress = ipc.lastwindow || "";
                break;
            }
        }

        if (activeIndex < 0 && lastAddress !== "") {
            for (let i = 0; i < windows.length; ++i) {
                if (windows[i].address === lastAddress) {
                    activeIndex = i;
                    break;
                }
            }
        }

        // focusHistoryID 越小越近；没有可用历史时保持最左窗口在顶部。
        if (activeIndex < 0 && windows.length > 0) {
            activeIndex = 0;
            for (let i = 1; i < windows.length; ++i) {
                if (windows[i].focusHistory < windows[activeIndex].focusHistory)
                    activeIndex = i;
            }
        }

        return { windows: windows, activeIndex: Math.max(0, activeIndex) };
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (root.windowRefreshEvents.indexOf(event.name) < 0)
                return;
            Hyprland.refreshToplevels();
            Hyprland.refreshWorkspaces();
        }
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

    Component.onCompleted: {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
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
