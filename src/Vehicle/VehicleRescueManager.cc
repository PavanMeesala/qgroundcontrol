#include "VehicleRescueManager.h"
#include "RescueWaypoint.h"

VehicleRescueManager::VehicleRescueManager(QObject* parent)
    : QObject(parent)
{
}

void VehicleRescueManager::clear()
{
    _rescuePoints.clearAndDeleteContents();

    _activeIndex = -1;

    emit activeIndexChanged();
    emit rescuePointsChanged();
}

void VehicleRescueManager::handleRescueWaypoint(
    uint16_t totalCount,
    uint16_t seq,
    int32_t lat,
    int32_t lon)
{
    Q_UNUSED(totalCount)

    if (seq == 0) {
        clear();
    }

    auto* wp = new RescueWaypoint(
        QGeoCoordinate(
            lat / 1e7,
            lon / 1e7));

    _rescuePoints.append(wp);
    emit rescuePointsChanged();
}

void VehicleRescueManager::handleWaypointReached(
    uint16_t index,
    bool reached)
{
    if (index >= _rescuePoints.count()) {
        return;
    }

    auto* wp =
        qobject_cast<RescueWaypoint*>(
            _rescuePoints.get(index));

    if (!wp) {
        return;
    }

    wp->setReached(reached);

    if (reached) {
        _activeIndex = index + 1;
    } else {
        _activeIndex = index;
    }

    emit activeIndexChanged();
}
