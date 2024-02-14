import QtQuick
import QtQuick.Controls
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.Controllers
import QGroundControl.ArduPilot

/*
    IMPORTANT NOTE: Any changes made here must also be made to SensorsComponentSummary.qml
*/

Item {
    anchors.fill:   parent

    APMSensorsComponentController { id: controller; }

    APMSensorParams {
        id:                     sensorParams
        factPanelController:    controller
    }

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
        labelText:  qsTr("Bússolas:")
        valueText: ""
        }

        Repeater {
            model: sensorParams.rgCompassAvailable.length
            RowLayout {
                Layout.fillWidth: true
                width: parent.width

                QGCLabel {

                    text:  sensorParams.rgCompassAvailable[index] ?
                                (sensorParams.rgCompassCalibrated[index] ?
                                     getPriority(index) +
                                     (sensorParams.rgCompassExternalParamAvailable[index] ?
                                          (sensorParams.rgCompassExternal[index] ? ", External" : ", Internal" ) :
                                          "") :
                                     qsTr("Configuração necessária")) :
                                qsTr("Não instalado")

                    function getPriority (index) {
                        if (sensorParams.rgCompassId[index].value == sensorParams.rgCompassPrio[0].value) {
                            return "Primario"
                        }
                        if (sensorParams.rgCompassId[index].value == sensorParams.rgCompassPrio[1].value) {
                            return "Secundário"
                        }
                        if (sensorParams.rgCompassId[index].value == sensorParams.rgCompassPrio[2].value) {
                            return "Terciário"
                        }
                        return "Não utilizado"
                    }
                }

                APMSensorIdDecoder {
                    horizontalAlignment:    Text.AlignRight
                    Layout.alignment:       Qt.AlignRight

                    fact: sensorParams.rgCompassPrio[index]
                }
            }
        }

        VehicleSummaryRow {
            labelText: qsTr("Acelerômetro(s):")
            valueText: controller.accelSetupNeeded ? qsTr("Configuração necessária") : qsTr("Pronto")
        }

        Repeater {
            model: sensorParams.rgInsId.length
            APMSensorIdDecoder {
                fact:          sensorParams.rgInsId[index]
                anchors.right: parent.right
            }
        }

        VehicleSummaryRow {
            labelText: qsTr("Barômetro(s):")
            valueText: sensorParams.baroIdAvailable ? "" : qsTr("Configuração necessária(Over APM 4.1)")
        }

        Repeater {
            model: sensorParams.rgBaroId.length
            APMSensorIdDecoder {
                fact:          sensorParams.rgBaroId[index]
                anchors.right: parent.right
            }
        }
    }
}
