pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_processorInterval: processorIntervalSpinBox.value
    property alias cfg_processorSystemColor: processorSystemColorButton.color
    property alias cfg_processorUserColor: processorUserColorButton.color
    property alias cfg_processorWaitColor: processorWaitColorButton.color
    property alias cfg_processorWidth: processorWidthSpinBox.value

    Kirigami.FormLayout {
        Controls.SpinBox {
            id: processorWidthSpinBox

            Kirigami.FormData.label: i18n("Width")
            editable: true
            from: 1
            stepSize: 1
            to: 500
        }

        Layouts.RowLayout {
            Kirigami.FormData.label: i18n("Refresh interval")

            Controls.SpinBox {
                id: processorIntervalSpinBox

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
            id: processorUserColorButton

            Kirigami.FormData.label: i18n("User")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: processorSystemColorButton

            Kirigami.FormData.label: i18n("System")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: processorWaitColorButton

            Kirigami.FormData.label: i18n("Wait")
            showAlphaChannel: false
        }
    }
}
