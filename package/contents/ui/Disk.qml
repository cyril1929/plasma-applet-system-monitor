pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import "byteFormatter.js" as ByteFormatter
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts

PlasmaCore.ToolTipArea {
    id: root

    Layouts.Layout.fillHeight: true
    implicitHeight: mainLayout.implicitHeight
    implicitWidth: mainLayout.implicitWidth
    mainText: i18n("Disk")
    subText: {
        if (!containsMouse) {
            return "";
        }
        const fastRefresh = Plasmoid.configuration.fastRefreshTooltips;
        const read = fastRefresh ? (readSensor.value || 0) : d.currentRead;
        const write = fastRefresh ? (writeSensor.value || 0) : d.currentWrite;
        const readFormatted = ByteFormatter.formatBytes(read, 1);
        const writeFormatted = ByteFormatter.formatBytes(write, 1);
        const readStr = readFormatted.value + " " + readFormatted.unit + i18n("/s");
        const writeStr = writeFormatted.value + " " + writeFormatted.unit + i18n("/s");
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
                        <td>${i18n("read")}</td>
                        <td class='value'>${readStr}</td>
                    </tr>
                    <tr>
                        <td>${i18n("write")}</td>
                        <td class='value'>${writeStr}</td>
                    </tr>
                </table>`;
    }
    textFormat: Text.RichText

    QtObject {
        id: d

        property real currentRead: 0
        property real currentWrite: 0
        property real graphRange: minimumGraphRange
        readonly property real minimumGraphRange: 1024 * 1024 // 1 Mio/s

        function reset(): void {
            currentRead = 0;
            currentWrite = 0;
            graphRange = minimumGraphRange;
        }
    }

    ListModel {
        id: graphModel
    }

    AveragingSensor {
        id: readSensor

        enabled: Plasmoid.configuration.showDisk
        sensorId: "disk/all/read"
    }

    AveragingSensor {
        id: writeSensor

        enabled: Plasmoid.configuration.showDisk
        sensorId: "disk/all/write"
    }

    Timer {
        id: refreshTimer

        interval: Plasmoid.configuration.diskInterval
        repeat: true
        running: Plasmoid.configuration.showDisk

        onRunningChanged: {
            if (!running) {
                d.reset();
                graphModel.clear();
            }
        }
        onTriggered: {
            const read = readSensor.consume(d.currentRead);
            const write = writeSensor.consume(d.currentWrite);
            d.currentRead = read;
            d.currentWrite = write;
            graphModel.insert(0, {
                "read": read,
                "write": write
            });
            const overflow = graphModel.count - Plasmoid.configuration.diskWidth;
            if (overflow > 0) {
                graphModel.remove(graphModel.count - overflow, overflow);
            }
            let max = 0;
            for (let i = 0; i < graphModel.count; ++i) {
                let item = graphModel.get(i);
                max = Math.max(max, item.read + item.write);
            }
            let graphRange = d.minimumGraphRange;
            while (max >= graphRange) {
                graphRange *= 2;
            }
            d.graphRange = graphRange;
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
            text: i18n("disk")
            visible: Plasmoid.configuration.showLabels
        }

        Rectangle {
            Layouts.Layout.fillHeight: true
            Layouts.Layout.preferredWidth: Plasmoid.configuration.diskWidth + 2
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
                    array: [Plasmoid.configuration.diskReadColor, Plasmoid.configuration.diskWriteColor]
                }
                valueSources: [
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "read"
                    },
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "write"
                    }
                ]

                xRange {
                    automatic: false
                    from: 0
                    to: Plasmoid.configuration.diskWidth
                }

                yRange {
                    automatic: false
                    from: 0
                    to: d.graphRange
                }
            }
        }
    }
}
