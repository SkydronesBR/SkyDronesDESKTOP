/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "APMFlightModesComponent.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"
#include "APMRadioComponent.h"

APMFlightModesComponent::APMFlightModesComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("Modos de Voo"))
{
}

QString APMFlightModesComponent::name(void) const
{
    return _name;
}

QString APMFlightModesComponent::description(void) const
{
    return tr("A configuração dos modos de voo é usada para configurar as chaves do transmissor associadas aos modos de voo.");
}

QString APMFlightModesComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/FlightModesComponentIcon.png");
}

bool APMFlightModesComponent::requiresSetup(void) const
{
    return true;
}

bool APMFlightModesComponent::setupComplete(void) const
{
    return true;
}

QStringList APMFlightModesComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMFlightModesComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMFlightModesComponent.qml"));
}

QUrl APMFlightModesComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMFlightModesComponentSummary.qml"));
}
