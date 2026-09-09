import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        icon: "configure"
        name: i18n("General")
        source: "config/configGeneral.qml"
    }

    ConfigCategory {
        icon: "cpu"
        name: i18n("Processor")
        source: "config/configProcessor.qml"
    }

    ConfigCategory {
        icon: "memory"
        name: i18n("Memory")
        source: "config/configMemory.qml"
    }

    ConfigCategory {
        icon: "memory"
        name: i18n("Swap")
        source: "config/configSwap.qml"
    }

    ConfigCategory {
        icon: "network-wired"
        name: i18n("Network")
        source: "config/configNetwork.qml"
    }

    ConfigCategory {
        icon: "drive-harddisk"
        name: i18n("Disk")
        source: "config/configDisk.qml"
    }
}
