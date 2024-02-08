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

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controllers
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController
    

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    FlyViewToolBar {
        id:         toolbar
        visible:    !QGroundControl.videoManager.fullScreen
    }

   /*  Item {
        id:                 mapHolder
        anchors.top:        toolbar.bottom
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right

        
        
    } */


    
    Item {
        id: viewFly
        width:  parent.width    * 0.75
        height: parent.height   * 0.75
        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        
        Image {
            id:                     viewImage
            source:                 "/res/QGCLogoWhite"
            anchors.fill:           parent
            //fillMode: Image.PreserveAspectCrop
        }
    }

    Column {
        id: buttonFirm
        spacing:            35
        anchors.leftMargin: 50
        anchors.topMargin: 70
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width * 0.5
        height: parent.height * 0.1

        

        Rectangle {
            color: "#FF4D00"
            radius: 25
            width: parent.width * 0.3
            height: parent.height * 0.1
            visible: true
            function showAnalyzeTool() {
                showTool("AnalyzeView.qml")
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Image {
                    source: "/qmlimages/FirmwareUpgradeIcon.png"
                    Layout.preferredWidth: height
                    Layout.preferredHeight: height
                    Layout.alignment: Qt.AlignVCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    anchors.leftMargin: 10
                }

                Text {
                    text: qsTr("FIRMWARE")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showAnalyzeTool())
                }
            }
        } // FIRMWARE
        Rectangle {
            color: "#FF4D00"
            radius: 25
            width: parent.width * 0.3
            height: parent.height * 0.1
            visible: true
            function showSensor(){
                showTool("BatteryIndicator.qml")
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Image {
                    source: "/qmlimages/SensorsComponentIcon.png"
                    Layout.preferredWidth: height
                    Layout.preferredHeight: height
                    Layout.alignment: Qt.AlignVCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    anchors.leftMargin: 10
                }

                Text {
                    text: qsTr("SENSOR")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showSensor())
                }
            }
        } // SENSOR
        Rectangle {
            color: "#FF4D00"
            radius: 25
            width: parent.width * 0.3
            height: parent.height * 0.1
            visible: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Image {
                    source: "/qmlimages/RidIconGreen"
                    Layout.preferredWidth: height
                    Layout.preferredHeight: height
                    Layout.alignment: Qt.AlignVCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    anchors.leftMargin: 10
                }

                Text {
                    text: qsTr("PARÂMETROS")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showAnalyzeTool())
                }
            }
        } // PARAMETROS
        Rectangle {
            color: "#FF4D00"
            radius: 25
            width: parent.width * 0.3
            height: parent.height * 0.1
            visible: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Image {
                    source: "/qmlimages/Analyze"
                    Layout.preferredWidth: height
                    Layout.preferredHeight: height
                    Layout.alignment: Qt.AlignVCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    anchors.leftMargin: 10
                }

                Text {
                    text: qsTr("LOG DOWNLOAD")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showAnalyzeTool())
                }
            }
        } // LOG DOWNLOAD
        Rectangle {
            color: "#FF4D00"
            radius: 25
            width: parent.width * 0.3
            height: parent.height * 0.1
            visible: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Image {
                    source: "/res/LockOpen"
                    Layout.preferredWidth: height
                    Layout.preferredHeight: height
                    Layout.alignment: Qt.AlignVCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    anchors.leftMargin: 10
                }

                Text {
                    text: qsTr("GERAL")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showAnalyzeTool())
                }
            }
        } // GERAL
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30  

        Text {
            text: "SkyDrones Desktop Versão 1.0.0"
            color: "white"
        }
    }

    Item {
        id: suporteIcon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110 // Aumentei a margem inferior para mover a imagem para cima
        anchors.right: parent.right
        anchors.rightMargin: 150
        Image {
            source: "/res/suporte.png"
        }
    }



}