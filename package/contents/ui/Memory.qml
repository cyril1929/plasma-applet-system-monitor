pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import "byteFormatter.js" as ByteFormatter
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
        const used = fastRefresh ? (usedSensor.value || 0) : d.currentUsed;
        const total = fastRefresh ? (totalSensor.value || 0) : d.currentTotal;
        const unitIndex = ByteFormatter.getBestUnitIndex([used, total]);
        const usedStr = ByteFormatter.formatBytesWithUnit(used, unitIndex, 1);
        const totalStr = ByteFormatter.formatBytesWithUnit(total, unitIndex, 1);
        const unitStr = ByteFormatter.getUnitSymbol(unitIndex);
        return i18n("Memory") + "     " + usedStr + " / " + totalStr + " " + unitStr;
    }
    subText: {
        if (!containsMouse) {
            return "";
        }
        const fastRefresh = Plasmoid.configuration.fastRefreshTooltips;
        const used = fastRefresh ? (usedSensor.value || 0) : d.currentUsed;
        const buffer = fastRefresh ? (bufferSensor.value || 0) : d.currentBuffer;
        const cache = fastRefresh ? (cacheSensor.value || 0) : d.currentCache;
        const total = fastRefresh ? (totalSensor.value || 0) : d.currentTotal;
        const usageUsed = total ? used / total * 100 : 0;
        const usageBuffer = total ? buffer / total * 100 : 0;
        const usageCache = total ? cache / total * 100 : 0;
        const usageUsedStr = usageUsed.toLocaleString(Qt.locale(), 'f', 1);
        const usageBufferStr = usageBuffer.toLocaleString(Qt.locale(), 'f', 1);
        const usageCacheStr = usageCache.toLocaleString(Qt.locale(), 'f', 1);
        const usedFormatted = ByteFormatter.formatBytes(used, 1);
        const bufferFormatted = ByteFormatter.formatBytes(buffer, 1);
        const cacheFormatted = ByteFormatter.formatBytes(cache, 1);
        const usedStr = usedFormatted.value + " " + usedFormatted.unit;
        const bufferStr = bufferFormatted.value + " " + bufferFormatted.unit;
        const cacheStr = cacheFormatted.value + " " + cacheFormatted.unit;
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
                        <td>${i18n("used")}</td>
                        <td class='value'>${usageUsedStr} %</td>
                        <td class='value'>${usedStr}</td>
                    </tr>
                    <tr>
                        <td>${i18n("buffer")}</td>
                        <td class='value'>${usageBufferStr} %</td>
                        <td class='value'>${bufferStr}</td>
                    </tr>
                    <tr>
                        <td>${i18n("cache")}</td>
                        <td class='value'>${usageCacheStr} %</td>
                        <td class='value'>${cacheStr}</td>
                    </tr>
                </table>`;
    }
    textFormat: Text.RichText

    QtObject {
        id: d

        property real currentBuffer: 0
        property real currentCache: 0
        property real currentTotal: 0
        property real currentUsed: 0

        function reset(): void {
            currentBuffer = 0;
            currentCache = 0;
            currentTotal = 0;
            currentUsed = 0;
        }
    }

    ListModel {
        id: graphModel
    }

    AveragingSensor {
        id: usedSensor

        enabled: Plasmoid.configuration.showMemory
        sensorId: "memory/physical/used"
    }

    AveragingSensor {
        id: cacheSensor

        enabled: Plasmoid.configuration.showMemory
        sensorId: "memory/physical/cache"
    }

    AveragingSensor {
        id: bufferSensor

        enabled: Plasmoid.configuration.showMemory
        sensorId: "memory/physical/buffer"
    }

    Sensors.Sensor {
        id: totalSensor

        enabled: Plasmoid.configuration.showMemory
        sensorId: "memory/physical/total"
    }

    Timer {
        id: refreshTimer

        interval: Plasmoid.configuration.memoryInterval
        repeat: true
        running: Plasmoid.configuration.showMemory

        onRunningChanged: {
            if (!running) {
                d.reset();
                graphModel.clear();
            }
        }
        onTriggered: {
            const used = usedSensor.consume(d.currentUsed);
            const buffer = bufferSensor.consume(d.currentBuffer);
            const cache = cacheSensor.consume(d.currentCache);
            const total = totalSensor.value || 0;
            d.currentUsed = used;
            d.currentBuffer = buffer;
            d.currentCache = cache;
            d.currentTotal = total;
            if (total <= 0) {
                return;
            }
            graphModel.append({
                "used": used,
                "buffer": buffer,
                "cache": cache,
                "total": total
            });
            const overflow = graphModel.count - Plasmoid.configuration.memoryWidth;
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
            text: i18n("memory")
            visible: Plasmoid.configuration.showLabels
        }

        Rectangle {
            Layouts.Layout.fillHeight: true
            Layouts.Layout.preferredWidth: Plasmoid.configuration.memoryWidth + 2
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

                        required property real buffer
                        required property real cache
                        required property int index
                        required property real total
                        required property real used

                        height: parent.height
                        width: 1
                        x: parent.width - graphModel.count + delegateItem.index

                        Rectangle {
                            color: Plasmoid.configuration.memoryUsedColor
                            height: parent.height * delegateItem.used / delegateItem.total
                            width: 1
                            y: parent.height * (delegateItem.total - delegateItem.used) / delegateItem.total
                        }

                        Rectangle {
                            color: Plasmoid.configuration.memoryBufferColor
                            height: parent.height * delegateItem.buffer / delegateItem.total
                            width: 1
                            y: parent.height * (delegateItem.total - delegateItem.used - delegateItem.buffer) / delegateItem.total
                        }

                        Rectangle {
                            color: Plasmoid.configuration.memoryCacheColor
                            height: parent.height * delegateItem.cache / delegateItem.total
                            width: 1
                            y: parent.height * (delegateItem.total - delegateItem.used - delegateItem.buffer - delegateItem.cache) / delegateItem.total
                        }
                    }
                }
            }
        }
    }
}
