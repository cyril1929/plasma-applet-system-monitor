pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_fastRefreshTooltips: fastRefreshTooltipsCheckBox.checked
    property alias cfg_showDisk: showDiskCheckBox.checked
    property alias cfg_showLabels: showLabelsCheckBox.checked
    property alias cfg_showMemory: showMemoryCheckBox.checked
    property alias cfg_showNetwork: showNetworkCheckBox.checked
    property alias cfg_showProcessor: showProcessorCheckBox.checked
    property alias cfg_showSwap: showSwapCheckBox.checked

    Kirigami.FormLayout {
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Monitors")
        }

        Controls.CheckBox {
            id: showProcessorCheckBox

            text: i18n("Processor")
        }

        Controls.CheckBox {
            id: showMemoryCheckBox

            text: i18n("Memory")
        }

        Controls.CheckBox {
            id: showSwapCheckBox

            text: i18n("Swap")
        }

        Controls.CheckBox {
            id: showNetworkCheckBox

            text: i18n("Network")
        }

        Controls.CheckBox {
            id: showDiskCheckBox

            text: i18n("Disk")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Appearance")
        }

        Controls.CheckBox {
            id: showLabelsCheckBox

            text: i18n("Show labels")
        }

        Controls.CheckBox {
            id: fastRefreshTooltipsCheckBox

            text: i18n("Fast refresh of tooltips")
        }
    }
}
