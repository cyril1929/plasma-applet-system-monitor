pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_diskInterval: diskIntervalSpinBox.value
    property alias cfg_diskReadColor: diskReadColorButton.color
    property alias cfg_diskWidth: diskWidthSpinBox.value
    property alias cfg_diskWriteColor: diskWriteColorButton.color

    Kirigami.FormLayout {
        Controls.SpinBox {
            id: diskWidthSpinBox

            Kirigami.FormData.label: i18n("Width")
            editable: true
            from: 1
            stepSize: 1
            to: 500
        }

        Layouts.RowLayout {
            Kirigami.FormData.label: i18n("Refresh interval")

            Controls.SpinBox {
                id: diskIntervalSpinBox

                editable: true
                from: 500
                stepSize: 500
                to: 60000
            }

            Controls.Label {
                text: i18n("ms")
            }
        }

        KQuickControls.ColorButton {
            id: diskReadColorButton

            Kirigami.FormData.label: i18n("Read")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: diskWriteColorButton

            Kirigami.FormData.label: i18n("Write")
            showAlphaChannel: false
        }
    }
}
