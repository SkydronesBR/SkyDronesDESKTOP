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

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Palette

SetupPage {
    id:             radioPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: Math.max(leftColumn.height, rightColumn.height)

            function setupPageCompleted() {
                controller.start()
                updateChannelCount()
            }

            function updateChannelCount()
            {
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }

            RadioComponentController {
                id:             controller
                statusText:     statusText
                cancelButton:   cancelButton
                nextButton:     nextButton
                skipButton:     skipButton
                onChannelCountChanged:              updateChannelCount()
                onFunctionMappingChangedAPMReboot:  mainWindow.showMessageDialog(qsTr("Reinicialização necessária"), qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."))
                onThrottleReversedCalFailure:       mainWindow.showMessageDialog(qsTr("Canal do acelerador invertido"), qsTr("A calibração falhou. O canal do acelerador em seu transmissor está invertido. Você deve corrigir isso em seu transmissor para concluir a calibração."))
            }

            Component {
                id: spektrumBindDialogComponent

                QGCPopupDialog {
                    title:      qsTr("Ligação Spektrum")
                    buttons:    Dialog.Ok | Dialog.Cancel

                    onAccepted: { controller.spektrumBindMode(radioGroup.checkedButton.bindMode) }

                    ButtonGroup { id: radioGroup }

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight / 2

                        QGCLabel {
                            wrapMode:   Text.WordWrap
                            text:       qsTr("Clique em Ok para colocar seu receptor Spektrum no modo de ligação.")
                        }

                        QGCLabel {
                            wrapMode:   Text.WordWrap
                            text:       qsTr("Selecione o tipo de receptor específico abaixo:")
                        }

                        QGCRadioButton {
                            text:               qsTr("DSM2 Mode")
                            ButtonGroup.group:  radioGroup
                            property int bindMode: RadioComponentController.DSM2
                        }

                        QGCRadioButton {
                            text:               qsTr("DSMX (7 channels or less)")
                            ButtonGroup.group:  radioGroup
                            property int bindMode: RadioComponentController.DSMX7
                        }

                        QGCRadioButton {
                            checked:            true
                            text:               qsTr("DSMX (8 channels or more)")
                            ButtonGroup.group:  radioGroup
                            property int bindMode: RadioComponentController.DSMX8
                        }
                    }
                }
            }

            // Live channel monitor control component
            Component {
                id: channelMonitorDisplayComponent

                Item {
                    property int    rcValue:    1500


                    property int            __lastRcValue:      1500
                    readonly property int   __rcValueMaxJitter: 2
                    property color          __barColor:         qgcPal.windowShade

                    readonly property int _pwmMin:      800
                    readonly property int _pwmMax:      2200
                    readonly property int _pwmRange:    _pwmMax - _pwmMin

                    // Bar
                    Rectangle {
                        id:                     bar
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width
                        height:                 parent.height / 2
                        color:                  __barColor
                    }

                    // Center point
                    Rectangle {
                        anchors.horizontalCenter:   parent.horizontalCenter
                        width:                      globals.defaultTextWidth / 2
                        height:                     parent.height
                        color:                      qgcPal.window
                    }

                    // Indicator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.height * 0.75
                        height:                 width
                        radius:                 width / 2
                        color:                  qgcPal.text
                        visible:                mapped
                        x:                      (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                    }

                    QGCLabel {
                        anchors.fill:           parent
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        text:                   qsTr("Not Mapped")
                        visible:                !mapped
                    }

                    ColorAnimation {
                        id:         barAnimation
                        target:     bar
                        property:   "color"
                        from:       "yellow"
                        to:         __barColor
                        duration:   1500
                    }
                }
            } // Component - channelMonitorDisplayComponent

            // Left side column
            Column {
                id:             leftColumn
                anchors.left:   parent.left
                anchors.right:  columnSpacer.left
                spacing:        10

                // Attitude Controls
                Column {
                    width:      parent.width
                    spacing:    5
                    QGCLabel { text: qsTr("Controles de atitude") }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2
                        QGCLabel {
                            id:     rollLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Roll")
                        }

                        Loader {
                            id:                 rollLoader
                            anchors.left:       rollLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                        }

                        Connections {
                            target: controller

                            onRollChannelRCValueChanged: (rcValue) => rollLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     pitchLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Pitch")
                        }

                        Loader {
                            id:                 pitchLoader
                            anchors.left:       pitchLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                        }

                        Connections {
                            target: controller

                            onPitchChannelRCValueChanged: (rcValue) => pitchLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     yawLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Yaw")
                        }

                        Loader {
                            id:                 yawLoader
                            anchors.left:       yawLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                        }

                        Connections {
                            target: controller

                            onYawChannelRCValueChanged: (rcValue) => yawLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     throttleLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Throttle")
                        }

                        Loader {
                            id:                 throttleLoader
                            anchors.left:       throttleLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                        }

                        Connections {
                            target:                             controller
                            onThrottleChannelRCValueChanged:    (rcValue) => throttleLoader.item.rcValue = rcValue
                        }
                    }
                } // Column - Attitude Control labels

                // Command Buttons
                Row {
                    spacing: 10

                    QGCButton {
                        id:         skipButton
                        text:       qsTr("Próximo")
                        onClicked:  controller.skipButtonClicked()
                    }

                    QGCButton {
                        id:         cancelButton
                        text:       qsTr("Cancelar")
                        onClicked:  controller.cancelButtonClicked()
                    }

                    QGCButton {
                        id:         nextButton
                        primary:    true
                        text:       qsTr("Calibrar")

                        onClicked: {
                            if (text === qsTr("Calibrar")) {
                                if (controller.channelCount < controller.minChannelCount) {
                                    mainWindow.showMessageDialog(qsTr("Rádio não está pronto"),
                                                                 controller.channelCount == 0 ? qsTr("Por favor ligue o transmissor.") :
                                                                                                (controller.channelCount < controller.minChannelCount ?
                                                                                                     qsTr("%1 canais ou mais são necessários para voar.").arg(controller.minChannelCount) :
                                                                                                     qsTr("Pronto para calibrar.")))
                                } else {
                                    mainWindow.showMessageDialog(qsTr("Zero cortes"),
                                                                 qsTr("Antes de calibrar você deve zerar todos os seus cortes e subtrims. Clique em Ok para iniciar a calibração.\n\n%1").arg(
                                                                     (QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? "" : qsTr("Certifique-se de que toda a alimentação do motor esteja desconectada E que todos os suportes sejam removidos do veículo."))),
                                                                 Dialog.Ok,
                                                                 function() { controller.nextButtonClicked() })
                                }
                            } else {
                                controller.nextButtonClicked()
                            }
                        }
                    }
                } // Row - Buttons

                // Status Text
                QGCLabel {
                    id:         statusText
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                }

                Rectangle {
                    width:          parent.width
                    height:         1
                    border.color:   qgcPal.text
                    border.width:   1
                }

                QGCLabel { text: qsTr("Configuração adicional de rádio:") }

                GridLayout {
                    id:                 switchSettingsGrid
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    columns:            2
                    columnSpacing:      ScreenTools.defaultFontPixelWidth

                    Repeater {
                        model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ?
                                   (QGroundControl.multiVehicleManager.activeVehicle.multiRotor ?
                                        [ "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"] :
                                        [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"]) :
                                   0

                        RowLayout {
                            Layout.fillWidth: true

                            property Fact fact: controller.getParameterFact(-1, modelData)

                            QGCLabel {
                                Layout.fillWidth:   true
                                text:               fact.shortDescription
                            }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       parent.fact
                                indexModel: false
                            }
                        }
                    }
                }

                RowLayout {
                    QGCButton {
                        id:         bindButton
                        text:       qsTr("Ligação Spektrum")
                        onClicked:  spektrumBindDialogComponent.createObject(mainWindow).open()
                    }

                    QGCButton {
                        text:       qsTr("Copiar guarnições")
                        onClicked:  mainWindow.showMessageDialog(qsTr("Copiar guarnições"),
                                                                 qsTr("Centralize seus manípulos e mova o acelerador totalmente para baixo e pressione Ok para copiar os cortes. Depois de pressionar OK, redefina os trims do seu rádio para zero."),
                                                                 Dialog.Ok | Dialog.Cancel,
                                                                 function() { controller.copyTrims() })
                    }
                }
            } // Column - Left Column

            Item {
                id:             columnSpacer
                anchors.right:  rightColumn.left
                width:          20
            }

            // Right side column
            Column {
                id:             rightColumn
                anchors.top:    parent.top
                anchors.right:  parent.right
                width:          ScreenTools.defaultFontPixelWidth * 40
                spacing:        ScreenTools.defaultFontPixelHeight / 2

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCRadioButton {
                        text:       qsTr("Modo 1")
                        checked:    controller.transmitterMode == 1
                        onClicked:  controller.transmitterMode = 1
                    }

                    QGCRadioButton {
                        text:       qsTr("Modo 2")
                        checked:    controller.transmitterMode == 2
                        onClicked:  controller.transmitterMode = 2
                    }
                }

                Image {
                    width:      parent.width
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp
                }

                RCChannelMonitor {
                    width:      parent.width
                    twoColumn:  true
                }
            } // Column - Right Column
        } // Item
    } // Component - pageComponent
} // SetupPage
