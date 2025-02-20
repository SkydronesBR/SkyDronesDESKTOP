 /****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "FactSystem.h"
#include "FirmwarePluginManager.h"
#include "AudioOutput.h"
#ifndef __mobile__
#include "GPSManager.h"
#endif
#include "JoystickManager.h"
#include "LinkManager.h"
#include "MAVLinkProtocol.h"
#include "MissionCommandTree.h"
#include "MultiVehicleManager.h"
#include "QGCImageProvider.h"
#include "UASMessageHandler.h"
#include "QGCMapEngineManager.h"
#include "FollowMe.h"
#include "PositionManager.h"
#include "VideoManager.h"
#include "MAVLinkLogManager.h"
#include "QGCCorePlugin.h"
#include "QGCOptions.h"
#include "SettingsManager.h"
#include "QGCApplication.h"
#include "ADSBVehicleManager.h"

#if defined(QGC_CUSTOM_BUILD)
#include CUSTOMHEADER
#endif

 /**
  * @brief Helper function to register a type with QML that is not creatable from QML
  * @param uri The URI to register the type under
  * @param majorVersion The major version of the type
  * @param minorVersion The minor version of the type
  * @param qmlName The name of the type in QML
  */
 template<class T>
 void registerUncreatableQmlType(const char *uri, int majorVersion, int minorVersion, const char *qmlName)
 {
     qmlRegisterUncreatableType<T>(uri, majorVersion, minorVersion, qmlName, "Reference only");
 }

QGCToolbox::QGCToolbox(QGCApplication* app)
{
    // SettingsManager must be first so settings are available to any subsequent tools
    _settingsManager        = new SettingsManager           (app, this);
    registerUncreatableQmlType<SettingsManager>("QGroundControl.SettingsManager", 1, 0, "SettingsManager");

    //-- Scan and load plugins
    _scanAndLoadPlugins(app);
    _audioOutput            = new AudioOutput               (app, this);
    _factSystem             = new FactSystem                (app, this);
    _firmwarePluginManager  = new FirmwarePluginManager     (app, this);
#ifndef __mobile__
    _gpsManager             = new GPSManager                (app, this);
#endif
    _imageProvider          = new QGCImageProvider          (app, this);
    _joystickManager        = new JoystickManager           (app, this);
    _linkManager            = new LinkManager               (app, this);
    _mavlinkProtocol        = new MAVLinkProtocol           (app, this);
    _missionCommandTree     = new MissionCommandTree        (app, this);
    _multiVehicleManager    = new MultiVehicleManager       (app, this);
    _mapEngineManager       = new QGCMapEngineManager       (app, this);
    registerUncreatableQmlType<QGCMapEngineManager>("QGroundControl.QGCMapEngineManager", 1, 0, "QGCMapEngineManager");
    _uasMessageHandler      = new UASMessageHandler         (app, this);
    _qgcPositionManager     = new QGCPositionManager        (app, this);
    _followMe               = new FollowMe                  (app, this);
    _videoManager           = new VideoManager              (app, this);
    registerUncreatableQmlType<VideoManager>("QGroundControl.VideoManager", 1, 0, "VideoManager");

    _mavlinkLogManager      = new MAVLinkLogManager         (app, this);
    _adsbVehicleManager     = new ADSBVehicleManager        (app, this);
}

void QGCToolbox::setChildToolboxes(void)
{
    // SettingsManager must be first so settings are available to any subsequent tools
    _settingsManager->setToolbox(this);

    _corePlugin->setToolbox(this);
    _audioOutput->setToolbox(this);
    _factSystem->setToolbox(this);
    _firmwarePluginManager->setToolbox(this);
#ifndef __mobile__
    _gpsManager->setToolbox(this);
#endif
    _imageProvider->setToolbox(this);
    _joystickManager->setToolbox(this);
    _linkManager->setToolbox(this);
    _mavlinkProtocol->setToolbox(this);
    _missionCommandTree->setToolbox(this);
    _multiVehicleManager->setToolbox(this);
    _mapEngineManager->setToolbox(this);
    _uasMessageHandler->setToolbox(this);
    _followMe->setToolbox(this);
    _qgcPositionManager->setToolbox(this);
    _videoManager->setToolbox(this);
    _mavlinkLogManager->setToolbox(this);
    _adsbVehicleManager->setToolbox(this);
}

void QGCToolbox::_scanAndLoadPlugins(QGCApplication* app)
{
#if defined (QGC_CUSTOM_BUILD)
    //-- Create custom plugin (Static)
    _corePlugin = (QGCCorePlugin*) new CUSTOMCLASS(app, this);
    if(_corePlugin) {
        return;
    }
#endif
    //-- No plugins found, use default instance
    _corePlugin = new QGCCorePlugin(app, this);
}

QGCTool::QGCTool(QGCApplication* app, QGCToolbox* toolbox)
    : QObject(toolbox)
    , _app(app)
    , _toolbox(nullptr)
{
}

void QGCTool::setToolbox(QGCToolbox* toolbox)
{
    _toolbox = toolbox;
}
