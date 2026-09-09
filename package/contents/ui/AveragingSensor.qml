pragma ComponentBehavior: Bound
import QtQuick
import org.kde.ksysguard.sensors as Sensors

Sensors.Sensor {
    id: root

    property int _count: 0
    property bool _hasReceivedInit: false
    property real _sum: 0

    function _reset(): void {
        _sum = 0;
        _count = 0;
    }

    function consume(previous: real): real {
        if (_count === 0) {
            return previous;
        }
        const avg = _sum / _count;
        _reset();
        return avg;
    }

    onEnabledChanged: {
        if (!enabled) {
            _reset();
        }
    }
    onValueChanged: {
        if (status !== Sensors.Sensor.Ready) {
            return;
        }
        if (!_hasReceivedInit) {
            _hasReceivedInit = true;
            return;
        }
        _sum += value;
        _count++;
    }
}
