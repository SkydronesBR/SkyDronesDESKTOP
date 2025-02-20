import QtQuick
import QtQuick.Controls

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.Palette

Item {
    anchors.fill:       parent

    APMAirframeComponentController {id: controller; }

    property Fact _frameClass:          controller.getParameterFact(-1, "FRAME_CLASS")
    property Fact _frameType:           controller.getParameterFact(-1, "FRAME_TYPE", false)
    property bool _frameTypeAvailable:  controller.parameterExists(-1, "FRAME_TYPE")

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText:  qsTr("Classe do Frame")
            valueText:  _frameClass.enumStringValue

        }

        VehicleSummaryRow {
            labelText:  qsTr("Tipo de Frame")
            valueText:  visible ? _frameType.enumStringValue : ""
            visible:    _frameTypeAvailable
        }

        VehicleSummaryRow {
            labelText: qsTr("Versão do Firmware")
            valueText: globals.activeVehicle.firmwareMajorVersion == -1 ? qsTr("Inválido") : globals.activeVehicle.firmwareMajorVersion + "." + globals.activeVehicle.firmwareMinorVersion + "." + globals.activeVehicle.firmwarePatchVersion + globals.activeVehicle.firmwareVersionTypeString
        }
    }
}
