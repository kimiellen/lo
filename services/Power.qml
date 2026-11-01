pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// 电池状态：UPower displayDevice（事件驱动，无轮询）
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool available: device !== null && device.ready && device.isPresent
    readonly property real percentage: device ? clamp01(device.percentage) : 0   // UPower 给 0..1
    readonly property int state: device ? device.state : UPowerDeviceState.Unknown
    readonly property bool charging: state === UPowerDeviceState.Charging
        || state === UPowerDeviceState.PendingCharge
    readonly property bool full: state === UPowerDeviceState.FullyCharged
    readonly property real timeToEmpty: device ? device.timeToEmpty : 0          // 秒
    readonly property real timeToFull: device ? device.timeToFull : 0            // 秒
    readonly property real changeRate: device ? device.changeRate : 0            // W，符号随充放电

    function clamp01(v) {
        if (!isFinite(v))
            return 0;
        return Math.max(0, Math.min(1, v));
    }
}
