#include "VehicleRescueManager.h"
#include "RescueWaypoint.h"
VehicleRescueManager::VehicleRescueManager(QObject* parent)
    : QObject(parent)
{
}
void VehicleRescueManager::handleRescueStatus(uint8_t phase, uint8_t wp_total,
                                               uint8_t wp_current, uint8_t wps_loaded)
{
    _phase     = static_cast<Phase>(phase);
    _totalWP   = wp_total;
    _currentWP = wp_current;
    _wpsLoaded = (wps_loaded == 1);
    emit statusChanged();
}

bool VehicleRescueManager::missionInProgress() const
{
    return _phase == Phase::TAKEOFF
        || _phase == Phase::TAKING_OFF
        || _phase == Phase::WP_NAV
        || _phase == Phase::GUIDED;
}

bool VehicleRescueManager::canStartMission() const
{
    return _phase == Phase::IDLE && _wpsLoaded;
}

QString VehicleRescueManager::statusText() const
{
    switch (_phase) {
    case Phase::IDLE:
        return _wpsLoaded
            ? QStringLiteral("Ready — press Start Search")
            : QStringLiteral("Waiting for waypoints...");
    case Phase::TAKEOFF:
        return QStringLiteral("Waiting to arm...");
    case Phase::TAKING_OFF:
        return QStringLiteral("Taking off...");
    case Phase::WP_NAV:
        return QString("Searching: WP %1 / %2")
                   .arg(_currentWP + 1)
                   .arg(_totalWP);
    case Phase::GUIDED:
        return QStringLiteral("Target detected — OBC in control");
    }
    return QStringLiteral("Unknown");
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
