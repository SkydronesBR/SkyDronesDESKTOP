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
    
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

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
    
    Item {
        id: viewFly
        width:                      parent.width   
        height:                     parent.height  
        anchors.centerIn:           parent
        
        Image {
            id:                     viewImage
            source:                 "/res/QGCLogoWhite"
            anchors.centerIn:       parent
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

        // FIRMWARE
        Rectangle {
            color: "#FF4D00"
            radius: 15
            width:  400
            height: 70
            visible: true
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    insertPass.visible = false; 
                }
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
                    width: parent.height * 0.7
                    height: parent.height * 0.7
                    anchors.leftMargin: 20
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
                    stackView.push(showVehicleSetupTool())
                }
            }
        } 
        // SENSOR
        Rectangle {
            color: "#FF4D00"
            radius: 15
            width:  400
            height: 70
            visible: true

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
                    text: qsTr("CALIBRAR")
                    font.pixelSize: Math.round(parent.height * 0.5)
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showSensorTool())
                }
            }
        } 
        // LOG DOWNLOAD
        Rectangle {
            color: "#FF4D00"
            radius: 15
            width:  400
            height: 70
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
                    stackView.push(showLogTool())
                }
            }
        } 
        // GERAL
        Rectangle {
            color: "#FF4D00"
            radius: 15
            width:  400
            height: 70
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
                    stackView.push(showSettingsTool())
                }
            }
        } 
        // PARÂMETROS
        Rectangle {
            color: "#771100"
            radius: 15
            width:  400
            height: 70
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
                    insertPass.visible = true; // Mostra a caixa de inserção de senha
                }
            }
        } 
    }
    Item{
        id:         insertPass
        anchors.fill: parent
        visible:    false
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                insertPass.visible = false; 
            }
        }
        onVisibleChanged: {
                if (!visible) {
                    passwordField.text = ""; 
                    senhaIncorretaText.visible = false;
                    senhaIncorretaTextt.visible = false;
            }
        }
        Rectangle{
            anchors.fill: parent
            color: qgcPal.window
            opacity:    0.9
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.centerIn: parent
            //border.color: "white"
            //border.width: 1
            Rectangle{
                width:      300
                height:     300
                radius:     15
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color:  qgcPal.window
                border.color: "white"

                Text{
                    id: closePassaword
                    text: "X"
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 5
                    anchors.right: parent.right  
                    anchors.rightMargin: 10 
                    color: "white"
                    font.pointSize: 20
                    font.bold:                      true
                    anchors.top: parent.top
                    
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            insertPass.visible = false; 
                        }
                        z: 1
                    }
                }

                TextField{
                    id: passwordField
                    anchors.centerIn: parent
                    width:  150
                    placeholderText: "Digite a senha"
                    echoMode: TextInput.Password 
                    onAccepted: {
                        if (passwordField.text === "skyP4r4m3tr0$") { 
                            stackView.push(showParamTool());
                            insertPass.visible = false; 
                        } else {
                            console.log("Senha incorreta. Tente novamente.");
                            senhaIncorretaText.visible = true;
                            senhaIncorretaTextt.visible = true;
                        }
                    }
                }
                Rectangle{
                    color: "#FF4D00"
                    radius: 10
                    width:  150
                    height: 30
                    anchors{
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottomMargin: 30
                    }
                    Text{
                        text:       "Confirmar"
                        color:      "white"
                        font.pointSize: 15
                        font.bold:  true
                        anchors.centerIn: parent
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if (passwordField.text === "skyP4r4m3tr0$") { 
                                    stackView.push(showParamTool());
                                    insertPass.visible = false; 
                                } else {
                                    console.log("Senha incorreta. Tente novamente.");
                                    senhaIncorretaText.visible = true;
                                    senhaIncorretaTextt.visible = true;
                                    
                                }
                            }
                        }
                    }
                }

                
                Text{
                    text:                           "Senha"
                    anchors.horizontalCenter:       parent.horizontalCenter
                    anchors.topMargin:              60   
                    color:                          "white"
                    font.pointSize:                 15
                    font.bold:                      true
                    anchors.top:                    parent.top
                }
                Text{
                    id: senhaIncorretaText
                    text: "Senha incorreta"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 180   
                    color: "red"
                    font.pointSize:                 12
                    font.bold:                      true
                    anchors.top: parent.top
                    visible: false 
                }
                Text {
                    id: senhaIncorretaTextt
                    textFormat: Text.RichText 
                    text: "<font color='white'>Entre em contato com a </font> <font color='#FF4D00'>SkyDrones</font>"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 200   
                    font.pointSize: 10
                    anchors.top: parent.top
                    visible: false 
                    MouseArea {
                        anchors.fill: parent 
                        onClicked: {
                            stackView.push(showHelpTool())
                        }
                    }
                }

            }
        }
    }// SENHA

    Item {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20  

        Text {
            text: "SkyDrones V 1.0.0-BETA"
            color: "white"
        }
    }

    Item {
        id: suporteIcon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110 
        anchors.right: parent.right
        anchors.rightMargin: 100
        Image {
            source: "/res/suporte.png"
            MouseArea {
                anchors.fill: parent 

                onClicked: {
                    stackView.push(showHelpTool())
                }
            }
        }
        
    } //SUPORTE

    //---------LOADING SCREEN
    Item {
        anchors.fill: parent
        visible: _activeVehicle ? _activeVehicle.parameterManager.loadProgress * parent.width : 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        


        Rectangle {
            anchors.fill: parent
            color: qgcPal.window
            opacity:    0.8
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "white"
            border.width: 1
            Rectangle{
                width:      500
                height:     500
                radius:     15
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color:  qgcPal.window
                border.color: "white"

                Rectangle {
                    id: loader
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item{
                        id: control
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        
                        property    int     itemCount:  10
                        property    int     itemSize:   10
                        property    int     itemExpand: 10
                        property    color   itemColor:  "white"
                        property    int     itemIndex:  0
                        property    int     duration:   1500
                        property    bool    running:    visible

                        implicitHeight:     200
                        implicitWidth:      200

                        NumberAnimation{
                            target:             control 
                            property:           "itemIndex"
                            from:               0
                            to:                 control.itemCount-1
                            loops:              Animation.Infinite
                            duration:           control.duration
                            running:            control.running
                        }

                        Item{
                            id:                 content
                            anchors.fill:       parent
                            anchors.margins:    control.itemExpand/2+1

                            Repeater{
                                id:             repeater 
                                model:          control.itemCount
                                Rectangle{
                                    id:         item 
                                    height:     control.itemSize
                                    width:      height
                                    x:          content.width/2 -   width/2
                                    y:          content.height/2    -   height/2
                                    radius:     height/2
                                    color:      control.itemColor

                                    transform:  [
                                        Translate{
                                            y:      content.height/2    -   height/2
                                        },
                                        Rotation{
                                            angle:  index   /   repeater.count  *   360
                                            origin.x:       width/2
                                            origin.y:       width/2
                                        }
                                    ]

                                    state:          control.itemIndex===index?"current":"normal"
                                    states: [
                                        State {
                                            name:   "current"
                                            PropertyChanges{
                                                target:         item
                                                opacity:        1
                                                height:         control.itemSize+control.itemExpand
                                            }
                                        },
                                        State {
                                            name:       "normal"
                                            PropertyChanges{
                                                target:         item
                                                opacity:        0.1
                                                height:         control.itemSize
                                            }
                                        }
                                    ]

                                    transitions:[
                                        Transition{
                                            from:       "current"
                                            to:         "normal"
                                            NumberAnimation{
                                                properties:     "opacity,height"
                                                duration:       control.duration
                                            }
                                        },
                                        Transition{
                                            from:               "normal"
                                            to:                 "current"
                                            NumberAnimation{
                                                properties:     "opacity,height"
                                                duration:       0
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    }
                    
                }

                Text{
                    text:                           "Conectando com o drone, por favor aguarde!"
                    anchors.horizontalCenter:       parent.horizontalCenter
                    anchors.topMargin:              60   
                    color:                          "white"
                    font.pointSize:                 15
                    font.bold:                      true
                    anchors.top:                    parent.top
                }
            }
            
        }
    }


}