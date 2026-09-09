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
    mainText: i18n("Network")
    subText: {
        if (!containsMouse) {
            return "";
        }
        const fastRefresh = Plasmoid.configuration.fastRefreshTooltips;
        const download = fastRefresh ? (downloadSensor.value || 0) : d.currentDownload;
        const upload = fastRefresh ? (uploadSensor.value || 0) : d.currentUpload;
        const downloadFormatted = ByteFormatter.formatBytes(download, 1);
        const uploadFormatted = ByteFormatter.formatBytes(upload, 1);
        const downloadStr = downloadFormatted.value + " " + downloadFormatted.unit + i18n("/s");
        const uploadStr = uploadFormatted.value + " " + uploadFormatted.unit + i18n("/s");
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
                        <td>${i18n("download")}</td>
                        <td class='value'>${downloadStr}</td>
                    </tr>
                    <tr>
                        <td>${i18n("upload")}</td>
                        <td class='value'>${uploadStr}</td>
                    </tr>
                </table>`;
    }
    textFormat: Text.RichText

    QtObject {
        id: d

        property real currentDownload: 0
        property real currentUpload: 0
        property real graphRange: minimumGraphRange
        readonly property real minimumGraphRange: 64 * 1024 // 64 Kio/s

        function reset(): void {
            currentDownload = 0;
            currentUpload = 0;
            graphRange = minimumGraphRange;
        }
    }

    ListModel {
        id: graphModel
    }

    AveragingSensor {
        id: downloadSensor

        enabled: Plasmoid.configuration.showNetwork
        sensorId: "network/all/download"
    }

    AveragingSensor {
        id: uploadSensor

        enabled: Plasmoid.configuration.showNetwork
        sensorId: "network/all/upload"
    }

    Timer {
        id: refreshTimer

        interval: Plasmoid.configuration.networkInterval
        repeat: true
        running: Plasmoid.configuration.showNetwork

        onRunningChanged: {
            if (!running) {
                d.reset();
                graphModel.clear();
            }
        }
        onTriggered: {
            const download = downloadSensor.consume(d.currentDownload);
            const upload = uploadSensor.consume(d.currentUpload);
            d.currentDownload = download;
            d.currentUpload = upload;
            graphModel.append({
                "download": download,
                "upload": upload
            });
            const overflow = graphModel.count - Plasmoid.configuration.networkWidth;
            if (overflow > 0) {
                graphModel.remove(0, overflow);
            }
            let max = 0;
            for (let i = 0; i < graphModel.count; ++i) {
                let item = graphModel.get(i);
                max = Math.max(max, item.download + item.upload);
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
            text: i18n("network")
            visible: Plasmoid.configuration.showLabels
        }

        Rectangle {
            Layouts.Layout.fillHeight: true
            Layouts.Layout.preferredWidth: Plasmoid.configuration.networkWidth + 2
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

                        required property real download
                        required property int index
                        required property real upload

                        height: parent.height
                        width: 1
                        x: parent.width - graphModel.count + delegateItem.index

                        Rectangle {
                            color: Plasmoid.configuration.networkDownloadColor
                            height: parent.height * delegateItem.download / d.graphRange
                            width: 1
                            y: parent.height * (d.graphRange - delegateItem.download) / d.graphRange
                        }

                        Rectangle {
                            color: Plasmoid.configuration.networkUploadColor
                            height: parent.height * delegateItem.upload / d.graphRange
                            width: 1
                            y: parent.height * (d.graphRange - delegateItem.download - delegateItem.upload) / d.graphRange
                        }
                    }
                }
            }
        }
    }
}
