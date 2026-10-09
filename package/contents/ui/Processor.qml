pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts

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
            graphModel.insert(0, {
                "user": user,
                "system": system,
                "wait": wait
            });
            const overflow = graphModel.count - Plasmoid.configuration.processorWidth;
            if (overflow > 0) {
                graphModel.remove(graphModel.count - overflow, overflow);
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

            Charts.BarChart {
                id: chart

                anchors.fill: parent
                anchors.margins: 1
                direction: Charts.XYChart.ZeroAtEnd
                layer.enabled: Screen.devicePixelRatio % 1 !== 0
                layer.smooth: true
                layer.textureSize: {
                    const ceilScale = Math.ceil(Screen.devicePixelRatio);
                    return Qt.size(width * ceilScale, height * ceilScale);
                }
                spacing: 0
                stacked: true

                colorSource: Charts.ArraySource {
                    array: [Plasmoid.configuration.processorUserColor, Plasmoid.configuration.processorSystemColor, Plasmoid.configuration.processorWaitColor]
                }
                valueSources: [
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "user"
                    },
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "system"
                    },
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "wait"
                    }
                ]

                xRange {
                    automatic: false
                    from: 0
                    to: Plasmoid.configuration.processorWidth
                }

                yRange {
                    automatic: false
                    from: 0
                    to: 100
                }
            }
        }
    }
}
