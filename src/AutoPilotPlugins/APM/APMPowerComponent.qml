/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

SetupPage {
    id:             powerPage
    pageComponent:  powerPageComponent

    FactPanelController {
        id:         controller
    }

    Component {
        id: powerPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            property Fact _batt1Monitor:            controller.getParameterFact(-1, "BATT_MONITOR")
            property Fact _batt2Monitor:            controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
            property bool _batt2MonitorAvailable:   controller.parameterExists(-1, "BATT2_MONITOR")
            property bool _batt1MonitorEnabled:     _batt1Monitor.rawValue !== 0
            property bool _batt2MonitorEnabled:     _batt2MonitorAvailable && _batt2Monitor.rawValue !== 0
            property bool _batt1ParamsAvailable:    controller.parameterExists(-1, "BATT_CAPACITY")
            property bool _batt2ParamsAvailable:    controller.parameterExists(-1, "BATT2_CAPACITY")
            property bool _showBatt1Reboot:         _batt1MonitorEnabled && !_batt1ParamsAvailable
            property bool _showBatt2Reboot:         _batt2MonitorEnabled && !_batt2ParamsAvailable
            property bool _escCalibrationAvailable: controller.parameterExists(-1, "ESC_CALIBRATION")
            property Fact _escCalibration:          controller.getParameterFact(-1, "ESC_CALIBRATION", false /* reportMissing */)

            property string _restartRequired: qsTr("Requires vehicle reboot")

            QGCPalette { id: ggcPal; colorGroupEnabled: true }

            // Battery1 Monitor settings only - used when only monitor param is available
            Column {
                spacing: _margins / 2
                visible: !_batt1MonitorEnabled || !_batt1ParamsAvailable

                QGCLabel {
                    text:       qsTr("Bateria 1")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  batt1Column.x + batt1Column.width + _margins
                    height: batt1Column.y + batt1Column.height + _margins
                    color:  ggcPal.windowShade

                    ColumnLayout {
                        id:                 batt1Column
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            id:                 batt1MonitorRow
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery1 monitor:") }
                            FactComboBox {
                                id:         monitor1Combo
                                fact:       _batt1Monitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt1Reboot
                        }

                        QGCButton {
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt1Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            // Battery 1 settings
            Column {
                id:         _batt1FullSettings
                spacing:    _margins / 2
                visible:    _batt1MonitorEnabled && _batt1ParamsAvailable

                QGCLabel {
                    text:       qsTr("Bateria 1")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  battery1Loader.x + battery1Loader.width + _margins
                    height: battery1Loader.y + battery1Loader.height + _margins
                    color:  ggcPal.windowShade

                    Loader {
                        id:                 battery1Loader
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        sourceComponent:    _batt1FullSettings.visible ? powerSetupComponent : undefined

                        property Fact armVoltMin:       controller.getParameterFact(-1, "r.BATT_ARM_VOLT", false /* reportMissing */)
                        property Fact battAmpPerVolt:   controller.getParameterFact(-1, "r.BATT_AMP_PERVLT", false /* reportMissing */)
                        property Fact battAmpOffset:    controller.getParameterFact(-1, "BATT_AMP_OFFSET", false /* reportMissing */)
                        property Fact battCapacity:     controller.getParameterFact(-1, "BATT_CAPACITY", false /* reportMissing */)
                        property Fact battCurrPin:      controller.getParameterFact(-1, "BATT_CURR_PIN", false /* reportMissing */)
                        property Fact battMonitor:      controller.getParameterFact(-1, "BATT_MONITOR", false /* reportMissing */)
                        property Fact battVoltMult:     controller.getParameterFact(-1, "BATT_VOLT_MULT", false /* reportMissing */)
                        property Fact battVoltPin:      controller.getParameterFact(-1, "BATT_VOLT_PIN", false /* reportMissing */)
                        property FactGroup  _batteryFactGroup:  _batt1FullSettings.visible ? controller.vehicle.getFactGroup("battery0") : null
                        property Fact vehicleVoltage:   _batteryFactGroup ? _batteryFactGroup.voltage : null
                        property Fact vehicleCurrent:   _batteryFactGroup ? _batteryFactGroup.current : null
                    }
                }
            }

            // Battery2 Monitor settings only - used when only monitor param is available
            Column {
                spacing: _margins / 2
                visible: !_batt2MonitorEnabled || !_batt2ParamsAvailable

                QGCLabel {
                    text:       qsTr("Bateria 2")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  batt2Column.x + batt2Column.width + _margins
                    height: batt2Column.y + batt2Column.height + _margins
                    color:  ggcPal.windowShade

                    ColumnLayout {
                        id:                 batt2Column
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            id:                 batt2MonitorRow
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Monitor de Bateria 2 :") }
                            FactComboBox {
                                id:         monitor2Combo
                                fact:       _batt2Monitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt2Reboot
                        }

                        QGCButton {
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt2Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            // Battery 2 settings - Used when full params are available
            Column {
                id:         batt2FullSettings
                spacing:    _margins / 2
                visible:    _batt2MonitorEnabled && _batt2ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 2")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  battery2Loader.x + battery2Loader.width + _margins
                    height: battery2Loader.y + battery2Loader.height + _margins
                    color:  ggcPal.windowShade

                    Loader {
                        id:                 battery2Loader
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        sourceComponent:    batt2FullSettings.visible ? powerSetupComponent : undefined

                        property Fact armVoltMin:       controller.getParameterFact(-1, "r.BATT2_ARM_VOLT", false /* reportMissing */)
                        property Fact battAmpPerVolt:   controller.getParameterFact(-1, "r.BATT2_AMP_PERVLT", false /* reportMissing */)
                        property Fact battAmpOffset:    controller.getParameterFact(-1, "BATT2_AMP_OFFSET", false /* reportMissing */)
                        property Fact battCapacity:     controller.getParameterFact(-1, "BATT2_CAPACITY", false /* reportMissing */)
                        property Fact battCurrPin:      controller.getParameterFact(-1, "BATT2_CURR_PIN", false /* reportMissing */)
                        property Fact battMonitor:      controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
                        property Fact battVoltMult:     controller.getParameterFact(-1, "BATT2_VOLT_MULT", false /* reportMissing */)
                        property Fact battVoltPin:      controller.getParameterFact(-1, "BATT2_VOLT_PIN", false /* reportMissing */)
                        property FactGroup  _batteryFactGroup:  batt2FullSettings.visible ? controller.vehicle.getFactGroup("battery1") : null
                        property Fact vehicleVoltage:   _batteryFactGroup ? _batteryFactGroup.voltage : null
                        property Fact vehicleCurrent:   _batteryFactGroup ? _batteryFactGroup.current : null
                    }
                }
            }

            Column {
                spacing:    _margins / 2
                visible:    _escCalibrationAvailable

                QGCLabel {
                    text:       qsTr("Calibração ESC")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  escCalibrationHolder.x + escCalibrationHolder.width + _margins
                    height: escCalibrationHolder.y + escCalibrationHolder.height + _margins
                    color:  ggcPal.windowShade

                    Column {
                        id:         escCalibrationHolder
                        x:          _margins
                        y:          _margins
                        spacing:    _margins

                        Column {
                            spacing: _margins

                            QGCLabel {
                                text:   qsTr("AVISO: Remova os suportes antes da calibração!")
                                color:  qgcPal.warningText
                            }

                            Row {
                                spacing: _margins

                                QGCButton {
                                    text: qsTr("Calibrar")
                                    enabled:    _escCalibration && _escCalibration.rawValue === 0
                                    onClicked:  if(_escCalibration) _escCalibration.rawValue = 3
                                }

                                Column {
                                    enabled: _escCalibration && _escCalibration.rawValue === 3
                                    QGCLabel { text:   _escCalibration ? (_escCalibration.rawValue === 3 ? qsTr("Agora realize essas etapas:") : qsTr("Clique em Calibrar para começar e então:")) : "" }
                                    QGCLabel { text:   qsTr("- Desconecte o USB e a bateria para que o controlador de voo seja desligado") }
                                    QGCLabel { text:   qsTr("- Conecte a bateria") }
                                    QGCLabel { text:   qsTr("- O tom de armamento será reproduzido (se o veículo tiver um buzzer conectado)") }
                                    QGCLabel { text:   qsTr("- Se estiver usando um controlador de voo com um botão de segurança, pressione-o até que ele exiba vermelho sólido") }
                                    QGCLabel { text:   qsTr("- Você ouvirá um tom musical e depois dois bipes") }
                                    QGCLabel { text:   qsTr("- Alguns segundos depois, você deverá ouvir vários bipes (um para cada célula da bateria que está usando)") }
                                    QGCLabel { text:   qsTr("- E finalmente um bipe longo único indicando que os pontos finais foram ajustados e o ESC está calibrado") }
                                    QGCLabel { text:   qsTr("- Desconecte a bateria e ligue novamente normalmente") }

                                }
                            }
                        }
                    }
                }
            }
        } // Flow
    } // Component - powerPageComponent

    Component {
        id: powerSetupComponent

        Column {
            spacing: _margins

            property real _margins:         ScreenTools.defaultFontPixelHeight / 2
            property bool _showAdvanced:    sensorCombo.currentIndex === sensorModel.count - 1
            property real _fieldWidth:      ScreenTools.defaultFontPixelWidth * 25

            Component.onCompleted: calcSensor()

            function calcSensor() {
                for (var i=0; i<sensorModel.count - 1; i++) {
                    if (sensorModel.get(i).voltPin === battVoltPin.value &&
                            sensorModel.get(i).currPin === battCurrPin.value &&
                            Math.abs(sensorModel.get(i).voltMult - battVoltMult.value) < 0.001 &&
                            Math.abs(sensorModel.get(i).ampPerVolt - battAmpPerVolt.value) < 0.0001 &&
                            Math.abs(sensorModel.get(i).ampOffset - battAmpOffset.value) < 0.0001) {
                        sensorCombo.currentIndex = i
                        return
                    }
                }
                sensorCombo.currentIndex = sensorModel.count - 1
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            ListModel {
                id: sensorModel

                ListElement {
                    text:       qsTr("Módulo de Potência 90A")
                    voltPin:    2
                    currPin:    3
                    voltMult:   10.1
                    ampPerVolt: 17.0
                    ampOffset:  0
                }

                ListElement {
                    text:       qsTr("Módulo de potência AT")
                    voltPin:    2
                    currPin:    3
                    voltMult:   12.02
                    ampPerVolt: 39.877
                    ampOffset:  0
                }

                ListElement {
                    text:       qsTr("3DR Iris")
                    voltPin:    2
                    currPin:    3
                    voltMult:   12.02
                    ampPerVolt: 17.0
                    ampOffset:  0
                }

                ListElement {
                    text:       qsTr("Módulo de detecção de potência da Blue Robotics")
                    voltPin:    2
                    currPin:    3
                    voltMult:   11.000
                    ampPerVolt: 37.8788
                    ampOffset:  0.330
                }

                ListElement {
                    text:       qsTr("Navegador com módulo Blue Robotics Power Sense")
                    voltPin:    5
                    currPin:    4
                    voltMult:   11.000
                    ampPerVolt: 37.8788
                    ampOffset:  0.330
                }

                ListElement {
                    text:       qsTr("Outro")
                }
            }


            GridLayout {
                columns:        3
                rowSpacing:     _margins
                columnSpacing:  _margins

                QGCLabel { text: qsTr("Monitor de bateria:") }

                FactComboBox {
                    id:         monitorCombo
                    fact:       battMonitor
                    indexModel: false
                    sizeToContents: true
                }

                QGCLabel {
                    Layout.row:     1
                    Layout.column:  0
                    text:           qsTr("Capacidade de carga:")
                }

                FactTextField {
                    id:     capacityField
                    width:  _fieldWidth
                    fact:   battCapacity
                }

                QGCLabel {
                    Layout.row:     2
                    Layout.column:  0
                    text:           qsTr("Tensão mínima de armar:")
                }

                FactTextField {
                    id:     armVoltField
                    width:  _fieldWidth
                    fact:   armVoltMin
                }

                QGCLabel {
                    Layout.row:     3
                    Layout.column:  0
                    text:           qsTr("Sensor de potência:")
                }

                QGCComboBox {
                    id:                     sensorCombo
                    Layout.minimumWidth:    _fieldWidth
                    model:                  sensorModel
                    textRole:               "text"

                    onActivated: {
                        if (index < sensorModel.count - 1) {
                            battVoltPin.value = sensorModel.get(index).voltPin
                            battCurrPin.value = sensorModel.get(index).currPin
                            battVoltMult.value = sensorModel.get(index).voltMult
                            battAmpPerVolt.value = sensorModel.get(index).ampPerVolt
                            battAmpOffset.value = sensorModel.get(index).ampOffset
                        } else {

                        }
                    }
                }

                QGCLabel {
                    Layout.row:     4
                    Layout.column:  0
                    text:           qsTr("PIN atual:")
                    visible:        _showAdvanced
                }

                FactComboBox {
                    Layout.minimumWidth:    _fieldWidth
                    fact:                   battCurrPin
                    indexModel:             false
                    visible:                _showAdvanced
                    sizeToContents:         true
                }

                QGCLabel {
                    Layout.row:     5
                    Layout.column:  0
                    text:           qsTr("Pino de tensão:")
                    visible:        _showAdvanced
                }

                FactComboBox {
                    Layout.minimumWidth:    _fieldWidth
                    fact:                   battVoltPin
                    indexModel:             false
                    visible:                _showAdvanced
                    sizeToContents:         true
                }

                QGCLabel {
                    Layout.row:     6
                    Layout.column:  0
                    text:           qsTr("Multiplicador de tensão:")
                    visible:        _showAdvanced
                }

                FactTextField {
                    width:      _fieldWidth
                    fact:       battVoltMult
                    visible:    _showAdvanced
                }

                QGCButton {
                    text:       qsTr("Calcular")
                    visible:    _showAdvanced
                    onClicked:  calcVoltageMultiplierDlgComponent.createObject(mainWindow, { vehicleVoltageFact: vehicleVoltage, battVoltMultFact: battVoltMult }).open()
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("Se a tensão da bateria informada pelo veículo for muito diferente da tensão lida externamente usando um voltímetro, você poderá ajustar o valor do multiplicador de tensão para corrigir isso. Clique no botão Calcular para obter ajuda no cálculo de um novo valor.")
                    visible:            _showAdvanced
                }

                QGCLabel {
                    text:       qsTr("Ampères por volt:")
                    visible:    _showAdvanced
                }

                FactTextField {
                    width:      _fieldWidth
                    fact:       battAmpPerVolt
                    visible:    _showAdvanced
                }

                QGCButton {
                    text:       qsTr("Calcular")
                    visible:    _showAdvanced
                    onClicked:  calcAmpsPerVoltDlgComponent.createObject(mainWindow, { vehicleCurrentFact: vehicleCurrent, battAmpPerVoltFact: battAmpPerVolt }).open()
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("Se o consumo de corrente relatado pelo veículo for muito diferente da corrente lida externamente usando um medidor de corrente, você poderá ajustar o valor de amperes por volt para corrigir isso. Clique no botão Calcular para obter ajuda no cálculo de um novo valor.")
                    visible:            _showAdvanced
                }

                QGCLabel {
                    text:       qsTr("Compensação de Amps:")
                    visible:    _showAdvanced
                }

                FactTextField {
                    width:      _fieldWidth
                    fact:       battAmpOffset
                    visible:    _showAdvanced
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("Se o veículo relatar uma leitura de corrente alta quando houver pouca ou nenhuma corrente passando por ele, ajuste o Compensação de Amps. Deve ser igual à tensão informada pelo sensor quando a corrente é zero.")
                    visible:            _showAdvanced
                }

            } // GridLayout
        } // Column
    } // Component - powerSetupComponent

    Component {
        id: calcVoltageMultiplierDlgComponent

        QGCPopupDialog {
            title:      qsTr("Calcular o multiplicador de tensão")
            buttons:    Dialog.Close

            property Fact vehicleVoltageFact
            property Fact battVoltMultFact

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.preferredWidth:  gridLayout.width
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("Meça a tensão da bateria usando um voltímetro externo e insira o valor abaixo. Clique em Calcular para definir o novo multiplicador de tensão ajustado.")
                }

                GridLayout {
                    id:         gridLayout
                    columns:    2

                    QGCLabel {
                        text: qsTr("Tensão medida:")
                    }
                    QGCTextField { id: measuredVoltage }

                    QGCLabel { text: qsTr("Tensão do veículo:") }
                    FactLabel { fact: vehicleVoltageFact }

                    QGCLabel { text: qsTr("Multiplicador de tensão:") }
                    FactLabel { fact: battVoltMultFact }
                }

                QGCButton {
                    text: qsTr("Calcular e definir")

                    onClicked:  {
                        var measuredVoltageValue = parseFloat(measuredVoltage.text)
                        if (measuredVoltageValue === 0 || isNaN(measuredVoltageValue) || !vehicleVoltageFact || !battVoltMultFact) {
                            return
                        }
                        var newVoltageMultiplier = (vehicleVoltageFact.value !== 0) ? (measuredVoltageValue * battVoltMultFact.value) / vehicleVoltageFact.value : 0
                        if (newVoltageMultiplier > 0) {
                            battVoltMultFact.value = newVoltageMultiplier
                        }
                    }
                }
            }
        }
    }

    Component {
        id: calcAmpsPerVoltDlgComponent

        QGCPopupDialog {
            title:      qsTr("Calcular e definir")
            buttons:    Dialog.Close

            property Fact vehicleCurrentFact
            property Fact battAmpPerVoltFact

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.preferredWidth:  gridLayout.width
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("Meça o consumo de corrente usando um medidor de corrente externo e insira o valor abaixo. Clique em Calcular para definir o novo valor de amperes por volt.")
                }

                GridLayout {
                    id:         gridLayout
                    columns:    2

                    QGCLabel {
                        text: qsTr("Corrente medida:")
                    }
                    QGCTextField { id: measuredCurrent }

                    QGCLabel { text: qsTr("Corrente do veículo:") }
                    FactLabel { fact: vehicleCurrentFact }

                    QGCLabel { text: qsTr("Ampères por volt:") }
                    FactLabel { fact: battAmpPerVoltFact }
                }

                QGCButton {
                    text: qsTr("Calcular e definir")

                    onClicked:  {
                        var measuredCurrentValue = parseFloat(measuredCurrent.text)
                        if (measuredCurrentValue === 0 || isNaN(measuredCurrentValue) || !vehicleCurrentFact || !battAmpPerVoltFact) {
                            return
                        }
                        var newAmpsPerVolt = (vehicleCurrentFact.value !== 0) ? (measuredCurrentValue * battAmpPerVoltFact.value) / vehicleCurrentFact.value : 0
                        if (newAmpsPerVolt !== 0) {
                            battAmpPerVoltFact.value = newAmpsPerVolt
                        }
                    }
                }
            }
        }
    }
} // SetupPage
