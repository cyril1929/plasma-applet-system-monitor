pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import "byteFormatter.js" as ByteFormatter
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

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
            graphModel.append({
                "read": read,
                "write": write
            });
            const overflow = graphModel.count - Plasmoid.configuration.diskWidth;
            if (overflow > 0) {
                graphModel.remove(0, overflow);
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

            Item {
                anchors.fill: parent
                anchors.margins: 1
                clip: true

                Repeater {
                    model: graphModel

                    Item {
                        id: delegateItem

                        required property int index
                        required property real read
                        required property real write

                        height: parent.height
                        width: 1
                        x: parent.width - graphModel.count + delegateItem.index

                        Rectangle {
                            color: Plasmoid.configuration.diskReadColor
                            height: parent.height * delegateItem.read / d.graphRange
                            width: 1
                            y: parent.height * (d.graphRange - delegateItem.read) / d.graphRange
                        }

                        Rectangle {
                            color: Plasmoid.configuration.diskWriteColor
                            height: parent.height * delegateItem.write / d.graphRange
                            width: 1
                            y: parent.height * (d.graphRange - delegateItem.read - delegateItem.write) / d.graphRange
                        }
                    }
                }
            }
        }
    }
}
