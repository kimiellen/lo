pragma Singleton
import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// 蓝牙状态：BlueZ（Quickshell.Bluetooth）封装，事件驱动无轮询
// 命名避开 Quickshell.Bluetooth 模块里的 Bluetooth 单例，防止导入类型冲突
Singleton {
    id: root

    // 设备 connected/paired 变化不会有模型级信号，靠每个设备的 Connections 递增 revision 触发重算
    property int revision: 0

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool powered: available && adapter.enabled
    readonly property bool discovering: powered && adapter.discovering

    readonly property var devices: available ? adapter.devices.values : []
    // 已连 / 未连 两组设备；未连组包含已配对与本次扫描发现的设备
    readonly property var connectedDevices: root.collectDevices(true)
    readonly property var availableDevices: root.collectDevices(false)

    Instantiator {
        model: root.devices

        delegate: Connections {
            required property var modelData

            target: modelData

            function onConnectedChanged() {
                root.revision++;
            }
            function onPairedChanged() {
                root.revision++;
            }
        }
    }

    Timer {
        id: discoveryTimer
        interval: 15000
        onTriggered: root.stopDiscovery()
    }

    function collectDevices(connected) {
        // 读取 revision 建立依赖：设备连接/配对状态变化时重建分组
        void root.revision;
        const out = [];
        const list = root.devices;
        for (let i = 0; i < list.length; ++i) {
            const device = list[i];
            if (!device || !!device.connected !== connected)
                continue;
            out.push(device);
        }
        out.sort(function (a, b) {
            const an = a.name || a.deviceName || a.address || "";
            const bn = b.name || b.deviceName || b.address || "";
            return an.localeCompare(bn);
        });
        return out;
    }

    function setPowered(on) {
        if (!available)
            return;
        adapter.enabled = on;
    }

    // 刷新 = 开启一次限时扫描；BlueZ 没有手动刷新接口
    function startDiscovery() {
        if (!powered)
            return;
        adapter.discovering = true;
        discoveryTimer.restart();
    }

    function stopDiscovery() {
        discoveryTimer.stop();
        if (available)
            adapter.discovering = false;
    }

    function toggleDevice(device) {
        if (!device)
            return;
        if (device.connected)
            disconnectDevice(device);
        else
            connectDevice(device);
    }

    // BlueZ 对 BLE HID 等设备保持 auto-connect（控制器 accept list），
    // 断开后设备回连会被立即接受（实测 80ms 内），用户主动断开时必须阻止
    function disconnectDevice(device) {
        device.disconnect();
        device.blocked = true;
    }

    // 必须先解除阻止，否则 Connect 会被 BlueZ 拒绝
    function connectDevice(device) {
        device.blocked = false;
        device.connect();
    }
}
