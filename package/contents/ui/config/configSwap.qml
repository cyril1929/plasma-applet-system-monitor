pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_swapInterval: swapIntervalSpinBox.value
    property alias cfg_swapUsedColor: swapUsedColorButton.color
    property alias cfg_swapWidth: swapWidthSpinBox.value

    Kirigami.FormLayout {
        Controls.SpinBox {
            id: swapWidthSpinBox

            Kirigami.FormData.label: i18n("Width")
            editable: true
            from: 1
            stepSize: 1
            to: 500
        }

        Layouts.RowLayout {
            Kirigami.FormData.label: i18n("Refresh interval")

            Controls.SpinBox {
                id: swapIntervalSpinBox

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
            id: swapUsedColorButton

            Kirigami.FormData.label: i18n("Used")
            showAlphaChannel: false
        }
    }
}
