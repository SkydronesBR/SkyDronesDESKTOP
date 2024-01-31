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

        Image {
            id: styleButton
            source: "/res/buttonLeft"
            fillMode: Image.PreserveAspectFill
            width: parent.width * 0.5  
            height: parent.height * 0.1  
            visible: true
        }
        Image {
            id: styleButton2
            source: "/res/buttonLeft"
            fillMode: Image.PreserveAspectFill
            width: parent.width * 0.5  
            height: parent.height * 0.1  
            visible: true
        }
        Image {
            id: styleButton3
            source: "/res/buttonLeft"
            fillMode: Image.PreserveAspectFill
            width: parent.width * 0.5  
            height: parent.height * 0.1  
            visible: true
        }
        Image {
            id: styleButton4
            source: "/res/buttonLeft"
            fillMode: Image.PreserveAspectFill
            width: parent.width * 0.5  
            height: parent.height * 0.1  
            visible: true
        }
        Image {
            id: styleButton5
            source: "/res/buttonLeft"
            fillMode: Image.PreserveAspectFill
            width: parent.width * 0.5  
            height: parent.height * 0.1  
            visible: true
        }
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

}