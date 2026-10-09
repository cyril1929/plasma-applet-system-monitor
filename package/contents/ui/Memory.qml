pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import "byteFormatter.js" as ByteFormatter
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
            graphModel.insert(0, {
                "used": used,
                "buffer": buffer,
                "cache": cache
            });
            const overflow = graphModel.count - Plasmoid.configuration.memoryWidth;
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
            text: i18n("memory")
            visible: Plasmoid.configuration.showLabels
        }

        Rectangle {
            Layouts.Layout.fillHeight: true
            Layouts.Layout.preferredWidth: Plasmoid.configuration.memoryWidth + 2
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
                    array: [Plasmoid.configuration.memoryUsedColor, Plasmoid.configuration.memoryBufferColor, Plasmoid.configuration.memoryCacheColor]
                }
                valueSources: [
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "used"
                    },
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "buffer"
                    },
                    Charts.ModelSource {
                        model: graphModel.count > 0 ? graphModel : null
                        roleName: "cache"
                    }
                ]

                xRange {
                    automatic: false
                    from: 0
                    to: Plasmoid.configuration.memoryWidth
                }

                yRange {
                    automatic: false
                    from: 0
                    to: d.currentTotal > 0 ? d.currentTotal : 1024 * 1024
                }
            }
        }
    }
}
