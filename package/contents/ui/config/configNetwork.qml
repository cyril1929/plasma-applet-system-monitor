pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts as Layouts
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_networkDownloadColor: networkDownloadColorButton.color
    property alias cfg_networkInterval: networkIntervalSpinBox.value
    property alias cfg_networkUploadColor: networkUploadColorButton.color
    property alias cfg_networkWidth: networkWidthSpinBox.value

    Kirigami.FormLayout {
        Controls.SpinBox {
            id: networkWidthSpinBox

            Kirigami.FormData.label: i18n("Width")
            editable: true
            from: 1
            stepSize: 1
            to: 500
        }

        Layouts.RowLayout {
            Kirigami.FormData.label: i18n("Refresh interval")

            Controls.SpinBox {
                id: networkIntervalSpinBox

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
            id: networkDownloadColorButton

            Kirigami.FormData.label: i18n("Download")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: networkUploadColorButton

            Kirigami.FormData.label: i18n("Upload")
            showAlphaChannel: false
        }
    }
}
