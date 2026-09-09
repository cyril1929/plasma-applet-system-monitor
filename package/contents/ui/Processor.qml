pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmaCore.ToolTipArea {
    id: root

    Layouts.Layout.fillHeight: true
    implicitHeight: mainLayout.implicitHeight
    implicitWidth: mainLayout.implicitWidth
    mainText: {
        if (!containsMouse) {
            return "";
        }
        const fastRefresh = Plasmoid.configuration.fastRefreshTooltips;
        const usage = fastRefresh ? (usageSensor.value || 0) : d.currentUsage;
        const usageStr = usage.toLocaleString(Qt.locale(), 'f', 0);
        return i18n("Processor") + "     " + usageStr + " %";
    }
    subText: {
        if (!containsMouse) {
            return "";
        }
        const fastRefresh = Plasmoid.configuration.fastRefreshTooltips;
        const coreCount = fastRefresh ? (coreCountSensor.value || 0) : d.currentCoreCount;
        const user = fastRefresh ? (userSensor.value || 0) : d.currentUser;
        const system = fastRefresh ? (systemSensor.value || 0) : d.currentSystem;
        const wait = fastRefresh ? (waitSensor.value || 0) : d.currentWait;
        const userCore = user * coreCount / 100;
        const systemCore = system * coreCount / 100;
        const waitCore = wait * coreCount / 100;
        const userCoreStr = userCore.toLocaleString(Qt.locale(), 'f', 2);
        const systemCoreStr = systemCore.toLocaleString(Qt.locale(), 'f', 2);
        const waitCoreStr = waitCore.toLocaleString(Qt.locale(), 'f', 2);
        return `<style>
                    td {
                        padding: 2px 8px;
                    }
                    .value {
                        text-align: right;
                    }
                </style>
                <table>
                    <tr>
                        <td>${i18n("user")}</td>
                        <td class='value'>${userCoreStr} ${i18n("cores")}</td>
                    </tr>
                    <tr>
                        <td>${i18n("system")}</td>
                        <td class='value'>${systemCoreStr} ${i18n("cores")}</td>
                    </tr>
                    <tr>
                        <td>${i18n("wait")}</td>
                        <td class='value'>${waitCoreStr} ${i18n("cores")}</td>
                    </tr>
                </table>`;
    }
    textFormat: Text.RichText

    QtObject {
        id: d

        property int currentCoreCount: 0
        property real currentSystem: 0
        property real currentUsage: 0
        property real currentUser: 0
        property real currentWait: 0

        function reset(): void {
            currentUser = 0;
            currentSystem = 0;
            currentWait = 0;
            currentCoreCount = 0;
            currentUsage = 0;
        }
    }

    ListModel {
        id: graphModel
    }

    AveragingSensor {
        id: userSensor

        enabled: Plasmoid.configuration.showProcessor
        sensorId: "cpu/all/user"
    }

    AveragingSensor {
        id: systemSensor

        enabled: Plasmoid.configuration.showProcessor
        sensorId: "cpu/all/system"
    }

    AveragingSensor {
        id: waitSensor

        enabled: Plasmoid.configuration.showProcessor
        sensorId: "cpu/all/wait"
    }

    Sensors.Sensor {
        id: coreCountSensor

        enabled: Plasmoid.configuration.showProcessor
        sensorId: "cpu/all/coreCount"
    }

    AveragingSensor {
        id: usageSensor

        enabled: Plasmoid.configuration.showProcessor
        sensorId: "cpu/all/usage"
    }

    Timer {
        id: refreshTimer

        interval: Plasmoid.configuration.processorInterval
        repeat: true
        running: Plasmoid.configuration.showProcessor

        onRunningChanged: {
            if (!running) {
                d.reset();
                graphModel.clear();
            }
        }
        onTriggered: {
            const user = userSensor.consume(d.currentUser);
            const system = systemSensor.consume(d.currentSystem);
            const wait = waitSensor.consume(d.currentWait);
            const coreCount = coreCountSensor.value || 0;
            const usage = usageSensor.consume(d.currentUsage);
            d.currentUser = user;
            d.currentSystem = system;
            d.currentWait = wait;
            d.currentCoreCount = coreCount;
            d.currentUsage = usage;
            graphModel.append({
                "user": user,
                "system": system,
                "wait": wait
            });
            const overflow = graphModel.count - Plasmoid.configuration.processorWidth;
            if (overflow > 0) {
                graphModel.remove(0, overflow);
            }
        }
    }

    Layouts.RowLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing * 0.25

        Controls.Label {
            font.family: Kirigami.Theme.smallFont.family
            font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.9
            font.weight: Kirigami.Theme.smallFont.weight
            text: i18n("processor")
            visible: Plasmoid.configuration.showLabels
        }

        Rectangle {
            Layouts.Layout.fillHeight: true
            Layouts.Layout.preferredWidth: Plasmoid.configuration.processorWidth + 2
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            color: Kirigami.Theme.backgroundColor

            Item {
                anchors.fill: parent
                anchors.margins: 1
                clip: true

                Repeater {
                    model: graphModel

                    Item {
                        id: delegateItem

                        required property int index
                        required property real system
                        required property real user
                        required property real wait

                        height: parent.height
                        width: 1
                        x: parent.width - graphModel.count + delegateItem.index

                        Rectangle {
                            color: Plasmoid.configuration.processorUserColor
                            height: parent.height * delegateItem.user / 100
                            width: 1
                            y: parent.height * (100 - delegateItem.user) / 100
                        }

                        Rectangle {
                            color: Plasmoid.configuration.processorSystemColor
                            height: parent.height * delegateItem.system / 100
                            width: 1
                            y: parent.height * (100 - delegateItem.user - delegateItem.system) / 100
                        }

                        Rectangle {
                            color: Plasmoid.configuration.processorWaitColor
                            height: parent.height * delegateItem.wait / 100
                            width: 1
                            y: parent.height * (100 - delegateItem.user - delegateItem.system - delegateItem.wait) / 100
                        }
                    }
                }
            }
        }
    }
}
