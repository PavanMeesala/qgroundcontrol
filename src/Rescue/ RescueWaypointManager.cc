#include "RescueWaypointManager.h"
#include "Vehicle.h"

RescueWaypointManager::RescueWaypointManager(
    Vehicle* vehicle,
    QObject* parent)
    : QObject(parent)
{
    connect(vehicle,
            &Vehicle::rescueWaypointReceived,
            this,
            &RescueWaypointManager::_onWaypointReceived);

    connect(vehicle,
            &Vehicle::rescueWaypointReached,
            this,
            &RescueWaypointManager::_onWaypointReached);
    connect(vehicle,
            &Vehicle::flightModeChanged,
            this,
            &RescueWaypointManager::_onFlightModeChanged);
}
QVariantList RescueWaypointManager::rescuePoints() const
{
    return _points;
}
int RescueWaypointManager::currentIndex() const
{
    return _currentIndex;
}
void RescueWaypointManager::_onWaypointReceived(
    uint16_t total,
    uint16_t seq,
    int32_t lat,
    int32_t lon)
{
    if(seq == 0)
    {
        _points.clear();
        _expectedCount = total;
    }

    _points.append(
        QVariant::fromValue(
            QGeoCoordinate(
                lat / 1e7,
                lon / 1e7)));

    emit rescuePointsChanged();
}
void RescueWaypointManager::_onWaypointReached(
    uint16_t index,
    bool reached)
{
    if(reached)
    {
        _currentIndex = index;
        emit currentIndexChanged();
    }
}
void RescueWaypointManager::_onFlightModeChanged(QString flightMode)
{
    if (flightMode != "RESCUE")
    {
        _points.clear();
        _currentIndex = -1;

        emit rescuePointsChanged();
        emit currentIndexChanged();
    }
}
