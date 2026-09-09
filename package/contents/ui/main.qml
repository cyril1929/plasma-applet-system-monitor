pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts as Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    fullRepresentation: Layouts.RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Processor {
            visible: Plasmoid.configuration.showProcessor
        }

        Memory {
            visible: Plasmoid.configuration.showMemory
        }

        Swap {
            visible: Plasmoid.configuration.showSwap
        }

        Network {
            visible: Plasmoid.configuration.showNetwork
        }

        Disk {
            visible: Plasmoid.configuration.showDisk
        }
    }
}
