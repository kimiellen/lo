pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.components
import qs.core
import qs.services

// Workspace 应用颜色编辑：按稳定应用标识去重，右侧十二色单选下拉框即时保存。
Item {
    id: root

    property int workspaceId: 0

    readonly property var workspaceData: Hypr.workspaceModel(workspaceId)
    readonly property var apps: {
        const result = [];
        const seen = ({});
        const list = workspaceData.windows;
        for (let i = 0; i < list.length; ++i) {
            const key = list[i].appKey;
            if (!key || seen[key])
                continue;
            seen[key] = true;
            result.push({ key: key, label: key });
        }
        return result;
    }

    implicitHeight: body.height

    Column {
        id: body
        width: root.width
        spacing: 6

        Text {
            text: I18n.t("panel.workspace.colors") + " · " + root.workspaceId
            color: Theme.subtext
            font.family: Theme.fontFamily
            font.pixelSize: Metrics.panelTextSize
            renderType: Text.NativeRendering
        }

        EmptyState {
            visible: root.apps.length === 0
            width: parent.width
            title: I18n.t("panel.workspace.empty")
        }

        Repeater {
            model: root.apps

            delegate: Item {
                id: appRow
                required property var modelData

                width: body.width
                height: 34

                Text {
                    anchors {
                        left: parent.left
                        right: combo.left
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                    text: appRow.modelData.label
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Metrics.panelTitleSize
                    renderType: Text.NativeRendering
                }

                ComboBox {
                    id: combo
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 172
                    height: 30
                    leftPadding: 10
                    rightPadding: 26
                    topPadding: 0
                    bottomPadding: 0

                    readonly property string appKey: appRow.modelData.key
                    readonly property string selectedColor: Config.workspaceAppColorName(appKey)
                    readonly property int savedIndex: Config.workspaceSelectableColors.indexOf(selectedColor)

                    model: Config.workspaceSelectableColors
                    currentIndex: savedIndex
                    displayText: savedIndex >= 0 ? Config.workspaceSelectableColors[savedIndex]
                        : I18n.t("panel.workspace.default")

                    onActivated: function (index) {
                        Config.setWorkspaceAppColor(appKey, Config.workspaceSelectableColors[index]);
                    }

                    contentItem: Row {
                        width: combo.availableWidth
                        height: combo.availableHeight
                        spacing: 7

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 8
                            height: 8
                            radius: 4
                            color: Theme.p[combo.selectedColor] || Theme.p.blue
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 15
                            elide: Text.ElideRight
                            text: combo.displayText
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Metrics.panelTextSize
                            renderType: Text.NativeRendering
                        }
                    }

                    indicator: Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 9
                        anchors.verticalCenter: parent.verticalCenter
                        text: "▾"
                        color: Theme.subtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Metrics.panelTextSize
                        renderType: Text.NativeRendering
                    }

                    background: Rectangle {
                        radius: 6
                        color: combo.popup.visible ? Theme.track : Theme.trackDim
                        border.width: 1
                        border.color: combo.popup.visible ? Theme.accent : Theme.track
                    }

                    delegate: ItemDelegate {
                        id: option
                        required property string modelData
                        required property int index

                        width: combo.width
                        height: 30

                        contentItem: Row {
                            spacing: 7

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 8
                                height: 8
                                radius: 4
                                color: Theme.p[option.modelData]
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 34
                                elide: Text.ElideRight
                                text: option.modelData
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Metrics.panelTextSize
                                renderType: Text.NativeRendering
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: combo.currentIndex === option.index
                                text: "✓"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Metrics.panelTextSize
                                renderType: Text.NativeRendering
                            }
                        }

                        background: Rectangle {
                            radius: 4
                            color: option.highlighted ? Theme.track : "transparent"
                        }

                        // 自定义 Popup 不会自动接管选择：显式走 ComboBox 的 activated 流程。
                        onClicked: {
                            combo.activated(index);
                            combo.popup.close();
                        }
                    }

                    popup: Popup {
                        y: combo.height + 2
                        width: combo.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 300) + 8
                        padding: 4

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: combo.popup.visible ? combo.model : null
                            delegate: combo.delegate
                            currentIndex: combo.currentIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: 8
                            color: Theme.panel
                            border.width: 1
                            border.color: Theme.track
                        }
                    }
                }
            }
        }
    }
}
