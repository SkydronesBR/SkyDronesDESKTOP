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
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.FactSystem
import QGroundControl.FactControls

Item {
    id:         _root

    property Fact   _editorDialogFact: Fact { }
    property int    _rowHeight:         ScreenTools.defaultFontPixelHeight * 2
    property int    _rowWidth:          10 // Dynamic adjusted at runtime
    property bool   _searchFilter:      searchText.text.trim() != "" || controller.showModifiedOnly  ///< true: showing results of search
    property var    _searchResults      ///< List of parameter names from search results
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _showRCToParam:     _activeVehicle.px4Firmware
    property var    _appSettings:       QGroundControl.settingsManager.appSettings
    property var    _controller:        controller

    ParameterEditorController {
        id: controller
    }

    //---------------------------------------------
    //-- Header
    Row {
        id:             header
        anchors.left:   parent.left
        anchors.right:  parent.right
        spacing:        ScreenTools.defaultFontPixelWidth

        Timer {
            id:         clearTimer
            interval:   100;
            running:    false;
            repeat:     false
            onTriggered: {
                searchText.text = ""
                controller.searchText = ""
            }
        }

        QGCLabel {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Procurar:")
        }

        QGCTextField {
            id:                 searchText
            text:               controller.searchText
            onDisplayTextChanged: controller.searchText = displayText
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCButton {
            text: qsTr("Limpar")
            onClicked: {
                if(ScreenTools.isMobile) {
                    Qt.inputMethod.hide();
                }
                clearTimer.start()
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCCheckBox {
            text:                   qsTr("Show modified only")
            anchors.verticalCenter: parent.verticalCenter
            checked:                controller.showModifiedOnly
            onClicked:              controller.showModifiedOnly = checked
            visible:                QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
        }
    } // Row - Header

    QGCButton {
        anchors.top:    header.top
        anchors.bottom: header.bottom
        anchors.right:  parent.right
        text:           qsTr("Ferramentas")
        onClicked:      toolsMenu.popup()
    }

    QGCMenu {
        id:                 toolsMenu
        QGCMenuItem {
            text:           qsTr("Atualizar")
            onTriggered:	controller.refresh()
        }
        QGCMenuItem {
            text:           qsTr("Redefinir tudo para os padrões do firmware")
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reiniciar tudo"),
                                                         qsTr("Selecione Redefinir para redefinir todos os parâmetros para seus padrões.\n\nObserve que isso também redefinirá tudo completamente, incluindo nós UAVCAN, todas as configurações, configurações e calibrações do veículo."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToDefaults() })
        }
        QGCMenuItem {
            text:           qsTr("Redefinir para os padrões de configuração do veículo")
            visible:        !_activeVehicle.apmFirmware
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reiniciar tudo"),
                                                         qsTr("Selecione Redefinir para redefinir todos os parâmetros para os padrões de configuração do veículo."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToVehicleConfiguration() })
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Carregar do arquivo...")
            onTriggered: {
                fileDialog.title =          qsTr("Carregar parâmetros")
                fileDialog.openForLoad()
            }
        }
        QGCMenuItem {
            text:           qsTr("Salvar em arquivo...")
            onTriggered: {
                fileDialog.title =          qsTr("Salvar parâmetros")
                fileDialog.openForSave()
            }
        }
        QGCMenuSeparator { visible: _showRCToParam }
        QGCMenuItem {
            text:           qsTr("Limpar todo RC para Param")
            onTriggered:	_activeVehicle.clearAllParamMapRC()
            visible:        _showRCToParam
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Reiniciar")
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reiniciar"),
                                                         qsTr("Selecione Ok para reiniciar."),
                                                         Dialog.Cancel | Dialog.Ok,
                                                         function() { _activeVehicle.rebootVehicle() })
        }
    }

    /// Group buttons
    QGCFlickable {
        id :                groupScroll
        width:              ScreenTools.defaultFontPixelWidth * 25
        anchors.top:        header.bottom
        anchors.bottom:     parent.bottom
        clip:               true
        pixelAligned:       true
        contentHeight:      groupedViewCategoryColumn.height
        flickableDirection: Flickable.VerticalFlick
        visible:            !_searchFilter

        ColumnLayout {
            id:             groupedViewCategoryColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)

            Repeater {
                model: controller.categories

                Column {
                    Layout.fillWidth:   true
                    spacing:            Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)


                    SectionHeader {
                        id:             categoryHeader
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           object.name
                        checked:        object == controller.currentCategory

                        onCheckedChanged: {
                            if (checked) {
                                controller.currentCategory  = object
                            }
                        }
                    }

                    Repeater {
                        model: categoryHeader.checked ? object.groups : 0

                        QGCButton {
                            width:          ScreenTools.defaultFontPixelWidth * 25
                            text:           object.name
                            height:         _rowHeight
                            checked:        object == controller.currentGroup
                            autoExclusive:  true

                            onClicked: {
                                if (!checked) _rowWidth = 10
                                checked = true
                                controller.currentGroup = object
                            }
                        }
                    }
                }
            }
        }
    }

    /// Parameter list
    QGCListView {
        id:                 editorListView
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        anchors.left:       _searchFilter ? parent.left : groupScroll.right
        anchors.right:      parent.right
        anchors.top:        header.bottom
        anchors.bottom:     parent.bottom
        orientation:        ListView.Vertical
        model:              controller.parameters
        cacheBuffer:        height > 0 ? height * 2 : 0
        clip:               true

        delegate: Rectangle {
            height: _rowHeight
            width:  _rowWidth
            color:  Qt.rgba(0,0,0,0)

            Row {
                id:     factRow
                spacing: Math.ceil(ScreenTools.defaultFontPixelWidth * 0.5)
                anchors.verticalCenter: parent.verticalCenter

                property Fact modelFact: object

                QGCLabel {
                    id:     nameLabel
                    width:  ScreenTools.defaultFontPixelWidth  * 20
                    text:   factRow.modelFact.name
                    clip:   true
                }

                QGCLabel {
                    id:     valueLabel
                    width:  ScreenTools.defaultFontPixelWidth  * 20
                    color:  factRow.modelFact.defaultValueAvailable ? (factRow.modelFact.valueEqualsDefault ? qgcPal.text : qgcPal.warningText) : qgcPal.text
                    text:   {
                        if(factRow.modelFact.enumStrings.length === 0) {
                            return factRow.modelFact.valueString + " " + factRow.modelFact.units
                        }

                        if(factRow.modelFact.bitmaskStrings.length != 0) {
                            return factRow.modelFact.selectedBitmaskStrings.join(',')
                        }

                        return factRow.modelFact.enumStringValue
                    }
                    clip:   true
                }

                QGCLabel {
                    text:   factRow.modelFact.shortDescription
                }

                Component.onCompleted: {
                    if(_rowWidth < factRow.width + ScreenTools.defaultFontPixelWidth) {
                        _rowWidth = factRow.width + ScreenTools.defaultFontPixelWidth
                    }
                }
            }

            Rectangle {
                width:  _rowWidth
                height: 1
                color:  qgcPal.text
                opacity: 0.15
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
            }

            MouseArea {
                anchors.fill:       parent
                acceptedButtons:    Qt.LeftButton
                onClicked: {
                    _editorDialogFact = factRow.modelFact
                    editorDialogComponent.createObject(mainWindow).open()
                }
            }
        }
    }

    QGCFileDialog {
        id:             fileDialog
        folder:         _appSettings.parameterSavePath
        nameFilters:    [ qsTr("Arquivos (*.%1)").arg(_appSettings.parameterFileExtension) , qsTr("Todos Arquivos (*)") ]

        onAcceptedForSave: (file) => {
            controller.saveToFile(file)
            close()
        }

        onAcceptedForLoad: (file) => {
            close()
            if (controller.buildDiffFromFile(file)) {
                parameterDiffDialog.createObject(mainWindow).open()
            }
        }
    }

    Component {
        id: editorDialogComponent

        ParameterEditorDialog {
            fact:           _editorDialogFact
            showRCToParam:  _showRCToParam
        }
    }

    Component {
        id: parameterDiffDialog

        ParameterDiffDialog {
            paramController: _controller
        }
    }
}
