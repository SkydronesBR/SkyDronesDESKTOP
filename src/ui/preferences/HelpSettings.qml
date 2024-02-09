/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Layouts  1.11

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    color:          qgcPal.window
    anchors.fill:   parent

    readonly property real _margins: ScreenTools.defaultFontPixelHeight

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    QGCFlickable {
        anchors.margins:    _margins
        anchors.fill:       parent
        contentWidth:       grid.width
        contentHeight:      grid.height
        clip:               true

        GridLayout {
            id:         grid
            columns:    2

            QGCLabel { text: qsTr("Website") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://skydrones.com.br/\">https://skydrones.com.br/</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("E-mail") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"suporte@skydrones.com.br\">suporte@skydrones.com.br</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("Manual") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://docs.skydrones.com.br/\">Manuais SkyDrones</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("Whatsapp") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://api.whatsapp.com/send?phone=5551995950550&text=Ol%C3%A1!\">+55 (51) 995-950-550 </a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("Instagram") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://www.instagram.com/skydronesbr/\">https://www.instagram.com/skydronesbr/</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("LinkedIn") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://www.linkedin.com/company/skydrones/mycompany/\">https://www.linkedin.com/company/skydrones/mycompany/</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("YouTube") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://www.youtube.com/channel/UCQFahs7HebFDIUk3vmZ_rxQ\">https://www.youtube.com/channel/UCQFahs7HebFDIUk3vmZ_rxQ</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("Facebook") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "<a href=\"https://www.facebook.com/SkyDronesBR/?fref=ts\">https://www.facebook.com/SkyDronesBR/?fref=ts</a>"
                onLinkActivated:    Qt.openUrlExternally(link)
            }

            QGCLabel { text: qsTr("Versão") }
            QGCLabel {
                linkColor:          qgcPal.text
                text:               "1.0.0"
                onLinkActivated:    Qt.openUrlExternally(link)
            }
        }
    }
}
