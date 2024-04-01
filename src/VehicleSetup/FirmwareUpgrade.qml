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
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controllers
import QGroundControl.ScreenTools

SetupPage {
    id:             firmwarePage
    pageComponent:  firmwarePageComponent
    pageName:       qsTr("Firmware")
    showAdvanced:   globals.activeVehicle && globals.activeVehicle.apmFirmware

    Component {
        id: firmwarePageComponent

        ColumnLayout {
            width:   availableWidth
            height:  availableHeight
            spacing: ScreenTools.defaultFontPixelHeight

            // Those user visible strings are hard to translate because we can't send the
            // HTML strings to translation as this can create a security risk. we need to find
            // a better way to hightlight them, or use less highlights.

            // User visible strings
            readonly property string title:             qsTr("Atualizar Firmware") // Popup dialog title
            readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string highlightSuffix:   "</font>"
            readonly property string welcomeText:       qsTr("%1 pode atualizar o firmware em dispositivos Pixhawk, rádios SiK e câmeras inteligentes PX4 Flow.").arg(QGroundControl.appName)
            readonly property string welcomeTextSingle: qsTr("Update the autopilot firmware to the latest version")
            readonly property string plugInText:        "<big>" + highlightPrefix + qsTr("Conecte seu dispositivo") + highlightSuffix + qsTr(" via USB para ") + highlightPrefix + qsTr("Iniciar") + highlightSuffix + qsTr(" atualização do firmware.") + "</big>"
            readonly property string flashFailText:     qsTr("Se a atualização falhar, certifique-se de conectar ") + highlightPrefix + qsTr("diretamente") + highlightSuffix + qsTr(" a uma porta USB alimentada no seu computador, e não através de um hub USB. ") +
                                                        qsTr("Certifique-se também de que você está alimentado apenas via USB ") + highlightPrefix + qsTr("não bateria") + highlightSuffix + "."
            readonly property string qgcUnplugText1:    qsTr("Todas as %1 conexões com veículos devem ser ").arg(QGroundControl.appName) + highlightPrefix + qsTr(" desconectado ") + highlightSuffix + qsTr("antes da atualização do firmware.")
            readonly property string qgcUnplugText2:    highlightPrefix + "<big>" + qsTr("Por favor, desconecte seu Pixhawk e/ou Rádio do USB.") + "</big>" + highlightSuffix

            readonly property int _defaultFimwareTypePX4:   12
            readonly property int _defaultFimwareTypeAPM:   3

            property var    _firmwareUpgradeSettings:   QGroundControl.settingsManager.firmwareUpgradeSettings
            property var    _defaultFirmwareFact:       _firmwareUpgradeSettings.defaultFirmwareType
            property bool   _defaultFirmwareIsPX4:      true

            property string firmwareWarningMessage
            property bool   firmwareWarningMessageVisible:  false
            property bool   initialBoardSearch:             true
            property string firmwareName

            property bool _singleFirmwareMode:          QGroundControl.corePlugin.options.firmwareUpgradeSingleURL.length != 0   ///< true: running in special single firmware download mode

            function setupPageCompleted() {
                controller.startBoardSearch()
                _defaultFirmwareIsPX4 = _defaultFirmwareFact.rawValue === _defaultFimwareTypePX4 // we don't want this to be bound and change as radios are selected
            }

            QGCFileDialog {
                id:                 customFirmwareDialog
                title:              qsTr("Selecione o arquivo")
                nameFilters:        [qsTr("Arquivos de Firmware (*.px4 *.apj *.bin *.ihx)"), qsTr("Todos Arquivos (*)")]
                folder:             QGroundControl.settingsManager.appSettings.logSavePath
                onAcceptedForLoad: (file) => {
                    controller.flashFirmwareUrl(file)
                    close()
                }
            }

            FirmwareUpgradeController {
                id:             controller
                progressBar:    progressBar
                statusLog:      statusTextArea

                property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

                onActiveVehicleChanged: {
                    if (!globals.activeVehicle) {
                        statusTextArea.append(plugInText)
                    }
                }

                onNoBoardFound: {
                    initialBoardSearch = false
                    if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                        statusTextArea.append(plugInText)
                    }
                }

                onBoardGone: {
                    initialBoardSearch = false
                    if (!QGroundControl.multiVehicleManager.activeVehicleAvailable) {
                        statusTextArea.append(plugInText)
                    }
                }

                onBoardFound: {
                    if (initialBoardSearch) {
                        // Board was found right away, so something is already plugged in before we've started upgrade
                        statusTextArea.append(qgcUnplugText1)
                        statusTextArea.append(qgcUnplugText2)

                        var availableDevices = controller.availableBoardsName()
                        if (availableDevices.length > 1) {
                            statusTextArea.append(highlightPrefix + qsTr("Vários dispositivos detectados! Remova todos os dispositivos detectados para realizar a atualização do firmware."))
                            statusTextArea.append(qsTr("Detectado [%1]: ").arg(availableDevices.length) + availableDevices.join(", "))
                        }
                        if (QGroundControl.multiVehicleManager.activeVehicle) {
                            QGroundControl.multiVehicleManager.activeVehicle.vehicleLinkManager.autoDisconnect = true
                        }
                    } else {
                        // We end up here when we detect a board plugged in after we've started upgrade
                        statusTextArea.append(highlightPrefix + qsTr("Dispositivo encontrado") + highlightSuffix + ": " + controller.boardType)
                    }
                }

                onShowFirmwareSelectDlg:    firmwareSelectDialogComponent.createObject(mainWindow).open()
                onError:                    statusTextArea.append(flashFailText)
            }

            Component {
                id: firmwareSelectDialogComponent

                QGCPopupDialog {
                    id:         firmwareSelectDialog
                    title:      qsTr("Atualizar Firmware")
                    buttons:    Dialog.Ok | Dialog.Cancel

                    property bool showFirmwareTypeSelection:    _advanced.checked
                    property bool px4Flow:                      controller.px4FlowBoard

                    function firmwareVersionChanged(model) {
                        firmwareWarningMessageVisible = false
                        // All of this bizarre, setting model to null and index to 1 and then to 0 is to work around
                        // strangeness in the combo box implementation. This sequence of steps correctly changes the combo model
                        // without generating any warnings and correctly updates the combo text with the new selection.
                        firmwareBuildTypeCombo.model = null
                        firmwareBuildTypeCombo.model = model
                        firmwareBuildTypeCombo.currentIndex = 1
                        firmwareBuildTypeCombo.currentIndex = 0
                    }

                    function updatePX4VersionDisplay() {
                        var versionString = ""
                        if (_advanced.checked) {
                            switch (controller.selectedFirmwareBuildType) {
                            case FirmwareUpgradeController.StableFirmware:
                                versionString = controller.px4StableVersion
                                break
                            case FirmwareUpgradeController.BetaFirmware:
                                versionString = controller.px4BetaVersion
                                break
                            }
                        } else {
                            versionString = controller.px4StableVersion
                        }
                        px4FlightStackRadio.text = qsTr("PX4 Pro ") + versionString
                        //px4FlightStackRadio2.text = qsTr("PX4 Pro ") + versionString
                    }

                    Component.onCompleted: {
                        firmwarePage.advanced = false
                        firmwarePage.showAdvanced = false
                        updatePX4VersionDisplay()
                    }

                    Connections {
                        target:     controller
                        onError:    reject()
                    }

                    onAccepted: {
                        if (_singleFirmwareMode) {
                            controller.flashSingleFirmwareMode(controller.selectedFirmwareBuildType)
                        } else {
                            var stack
                            var firmwareBuildType = firmwareBuildTypeCombo.model.get(firmwareBuildTypeCombo.currentIndex).firmwareType
                            var vehicleType = FirmwareUpgradeController.DefaultVehicleFirmware

                            if (px4Flow) {
                                stack = px4FlowTypeSelectionCombo.model.get(px4FlowTypeSelectionCombo.currentIndex).stackType
                                vehicleType = FirmwareUpgradeController.DefaultVehicleFirmware
                            } else {
                                stack = apmFlightStack.checked ? FirmwareUpgradeController.AutoPilotStackAPM : FirmwareUpgradeController.AutoPilotStackPX4
                                if (apmFlightStack.checked) {
                                    if (firmwareBuildType === FirmwareUpgradeController.CustomFirmware) {
                                        vehicleType = apmVehicleTypeCombo.currentIndex
                                    } else {
                                        if (controller.apmFirmwareNames.length === 0) {
                                            // Not ready yet, or no firmware available
                                            mainWindow.showMessageDialog(firmwareSelectDialog.title, qsTr("A lista de firmware ainda está sendo baixada ou nenhum firmware está disponível para a seleção atual."))
                                            firmwareSelectDialog.preventClose = true
                                            return
                                        }
                                        if (ardupilotFirmwareSelectionCombo.currentIndex == -1) {
                                            mainWindow.showMessageDialog(firmwareSelectDialog.title, qsTr("Você deve escolher um tipo de placa."))
                                            firmwareSelectDialog.preventClose = true
                                            return
                                        }

                                        var firmwareUrl = controller.apmFirmwareUrls[ardupilotFirmwareSelectionCombo.currentIndex]
                                        if (firmwareUrl == "") {
                                            mainWindow.showMessageDialog(firmwareSelectDialog.title, qsTr("Nenhum firmware foi encontrado para a seleção atual."))
                                            firmwareSelectDialog.preventClose = true
                                            return
                                        }
                                        controller.flashFirmwareUrl(controller.apmFirmwareUrls[ardupilotFirmwareSelectionCombo.currentIndex])
                                        return
                                    }
                                }
                            }
                            //-- If custom, get file path
                            if (firmwareBuildType === FirmwareUpgradeController.CustomFirmware) {
                                customFirmwareDialog.openForLoad()
                            } else {
                                controller.flash(stack, firmwareBuildType, vehicleType)
                            }
                        }
                    }

                    function reject() {
                        statusTextArea.append(highlightPrefix + qsTr("Atualização cancelada") + highlightSuffix)
                        statusTextArea.append("------------------------------------------")
                        controller.cancel()
                        close()
                    }

                    ListModel {
                        id: firmwareBuildTypeList

                        /* ListElement {
                            text:           qsTr("Versão Padrão (estável)")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        } */
                        /* ListElement {
                            text:           qsTr("Teste beta (beta)")
                            firmwareType:   FirmwareUpgradeController.BetaFirmware
                        } */
                        /* ListElement {
                            text:           qsTr("Versão do desenvolvedor (mestre)")
                            firmwareType:   FirmwareUpgradeController.DeveloperFirmware
                        } */
                        ListElement {
                            text:           qsTr("Arquivo de firmware personalizado...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    /* ListModel {
                        id: px4FlowFirmwareList

                        ListElement {
                            text:           qsTr("PX4 Pro")
                            stackType:   FirmwareUpgradeController.PX4FlowPX4
                        }
                        ListElement {
                            text:           qsTr("ArduPilot")
                            stackType:   FirmwareUpgradeController.PX4FlowAPM
                        }
                    } */

                    ListModel {
                        id: px4FlowTypeList

                        ListElement {
                            text:           qsTr("Versão Padrão (estável)")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        }
                        ListElement {
                            text:           qsTr("Arquivo de firmware personalizado...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    ListModel {
                        id: singleFirmwareModeTypeList

                        ListElement {
                            text:           qsTr("Versão padrão")
                            firmwareType:   FirmwareUpgradeController.StableFirmware
                        }
                        ListElement {
                            text:           qsTr("Arquivo de firmware personalizado...")
                            firmwareType:   FirmwareUpgradeController.CustomFirmware
                        }
                    }

                    ColumnLayout {
                        width:      Math.max(ScreenTools.defaultFontPixelWidth * 40, firmwareRadiosColumn.width)
                        spacing:    globals.defaultTextHeight / 2

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               (_singleFirmwareMode || !QGroundControl.apmFirmwareSupported) ? _singleFirmwareLabel : (px4Flow ? _px4FlowLabel : _pixhawkLabel)

                            readonly property string _px4FlowLabel:          qsTr("Placa de fluxo PX4 detectada. O firmware que você usa no PX4 Flow deve corresponder ao tipo de firmware do AutoPilot que você está usando no veículo:")
                            readonly property string _pixhawkLabel:          qsTr("Placa Pixhawk detectada. Você pode selecionar entre as seguintes pilhas de voo:")
                            readonly property string _singleFirmwareLabel:   qsTr("Pressione OK para atualizar seu veículo.")
                        }

                        Column {
                            id:         firmwareRadiosColumn
                            spacing:    0

                            visible: !_singleFirmwareMode && !px4Flow && QGroundControl.apmFirmwareSupported

                            Component.onCompleted: {
                                if(!QGroundControl.apmFirmwareSupported) {
                                    _defaultFirmwareFact.rawValue = _defaultFimwareTypePX4
                                    firmwareVersionChanged(firmwareBuildTypeList)
                                }
                            }

                            QGCRadioButton {
                                id:             px4FlightStackRadio
                                text:           qsTr("PX4 Pro ")
                                font.bold:      _defaultFirmwareIsPX4
                                checked:        _defaultFirmwareIsPX4

                                onClicked: {
                                    _defaultFirmwareFact.rawValue = _defaultFimwareTypePX4
                                    firmwareVersionChanged(firmwareBuildTypeList)
                                }
                            }

                            QGCRadioButton {
                                id:             apmFlightStack
                                text:           qsTr("ArduPilot")
                                font.bold:      !_defaultFirmwareIsPX4
                                checked:        !_defaultFirmwareIsPX4
                                visible:        false

                                onClicked: {
                                    _defaultFirmwareFact.rawValue = _defaultFimwareTypeAPM
                                    firmwareVersionChanged(firmwareBuildTypeList)
                                }
                            }
                        }

                        FactComboBox {
                            Layout.fillWidth:   true
                            visible:            false //!px4Flow && apmFlightStack.checked
                            fact:               _firmwareUpgradeSettings.apmChibiOS
                            indexModel:         false
                        }

                        FactComboBox {
                            id:                 apmVehicleTypeCombo
                            Layout.fillWidth:   true
                            visible:            false //!px4Flow && apmFlightStack.checked
                            fact:               _firmwareUpgradeSettings.apmVehicleType
                            indexModel:         false
                        }

                        QGCComboBox {
                            id:                 ardupilotFirmwareSelectionCombo
                            Layout.fillWidth:   true
                            visible:            !px4Flow && apmFlightStack.checked && !controller.downloadingFirmwareList && controller.apmFirmwareNames.length !== 0
                            model:              controller.apmFirmwareNames
                            onModelChanged:     currentIndex = controller.apmFirmwareNamesBestIndex
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Baixando lista de firmwares disponíveis...")
                            visible:            controller.downloadingFirmwareList
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Nenhum firmware disponível")
                            visible:            !controller.downloadingFirmwareList && (QGroundControl.apmFirmwareSupported && controller.apmFirmwareNames.length === 0)
                        }

                        QGCComboBox {
                            id:                 px4FlowTypeSelectionCombo
                            Layout.fillWidth:   true
                            visible:            px4Flow
                            model:              px4FlowFirmwareList
                            textRole:           "text"
                            currentIndex:       _defaultFirmwareIsPX4 ? 0 : 1
                        }

                        QGCCheckBox {
                            id:         _advanced
                            text:       qsTr("Configurações Avançadas")
                            checked:    px4Flow ? true : false
                            visible:    !px4Flow

                            onClicked: {
                                firmwareBuildTypeCombo.currentIndex = 0
                                firmwareWarningMessageVisible = false
                                updatePX4VersionDisplay()
                            }
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            visible:            showFirmwareTypeSelection
                            text:               _singleFirmwareMode ?  qsTr("Selecione a versão padrão ou uma do sistema de arquivos (baixada anteriormente):") :
                                                                      (px4Flow ? qsTr("Selecione qual versão do firmware você deseja instalar:") :
                                                                                 qsTr("Selecione qual versão da pilha de voo acima você gostaria de instalar:"))
                        }

                        QGCComboBox {
                            id:                 firmwareBuildTypeCombo
                            Layout.fillWidth:   true
                            visible:            showFirmwareTypeSelection
                            textRole:           "text"
                            model:              _singleFirmwareMode ? singleFirmwareModeTypeList : (px4Flow ? px4FlowTypeList : firmwareBuildTypeList)

                            onActivated: {
                                controller.selectedFirmwareBuildType = model.get(index).firmwareType
                                if (model.get(index).firmwareType === FirmwareUpgradeController.BetaFirmware) {
                                    firmwareWarningMessageVisible = true
                                    firmwareVersionWarningLabel.text = qsTr("AVISO: FIRMWARE BETA. ") +
                                            qsTr("Esta versão de firmware destina-se APENAS a testadores beta. ") +
                                            qsTr("Embora tenha recebido FLIGHT TESTING, representa código alterado ativamente. ") +
                                            qsTr("NÃO use para operação normal.")
                                } else if (model.get(index).firmwareType === FirmwareUpgradeController.DeveloperFirmware) {
                                    firmwareWarningMessageVisible = true
                                    firmwareVersionWarningLabel.text = qsTr("AVISO: FIRMWARE DE CONSTRUÇÃO CONTÍNUA.") +
                                            qsTr("Este firmware NÃO FOI TESTADO EM VÔO. ") +
                                            qsTr("Destina-se apenas a DESENVOLVEDORES. ") +
                                            qsTr("Execute testes de bancada sem acessórios primeiro. ") +
                                            qsTr("NÃO voe sem precauções de segurança adicionais. ") +
                                            qsTr("Siga os fóruns ativamente ao usá-lo.")
                                } else {
                                    firmwareWarningMessageVisible = false
                                }
                                updatePX4VersionDisplay()
                            }
                        }

                        QGCLabel {
                            id:                 firmwareVersionWarningLabel
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            visible:            firmwareWarningMessageVisible
                        }
                    } // ColumnLayout
                } // QGCPopupDialog
            } // Component - firmwareSelectDialogComponent

            ProgressBar {
                id:                     progressBar
                Layout.preferredWidth:  parent.width
                visible:                !flashBootloaderButton.visible
            }

            QGCButton {
                id:         flashBootloaderButton
                text:       qsTr("Carregador de inicialização Flash ChibiOS")
                visible:    firmwarePage.advanced
                onClicked:  globals.activeVehicle.flashBootloader()
            }
            QGCButton {
                text: "Baixar Firmware mais recente"
                onClicked: {
                        /* if (!QGroundControl.multiVehicleManager.activeVehicle || QGroundControl.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
                            mainWindow.showMessageDialog(qsTr("Atualizar Firmware"), qsTr("Você deve estar conectado a um veículo. Conecte com seu veículo via USB"))
                        } else {
                            openFirmwareSelectDialog()
                        } */
                        Qt.openUrlExternally("https://skydrones.com.br/Firmware/Copter/arducopter.apj")
                    }
            }

            TextArea {
                id:                 statusTextArea
                Layout.preferredWidth:              parent.width
                Layout.fillHeight:  true
                readOnly:           true
                font.pointSize:     ScreenTools.defaultFontPointSize
                textFormat:         TextEdit.RichText
                text:               _singleFirmwareMode ? welcomeTextSingle : welcomeText
                color:              qgcPal.text

                background: Rectangle {
                    color: qgcPal.windowShade
                }
            }
            
            function openFirmwareSelectDialog() {
                firmwareSelectDialogComponent.createObject(mainWindow).open()
            }
        } // ColumnLayout
    } // Component
} // SetupPage
