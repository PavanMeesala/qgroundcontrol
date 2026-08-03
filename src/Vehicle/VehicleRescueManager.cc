#include "VehicleRescueManager.h"
#include "RescueWaypoint.h"

VehicleRescueManager::VehicleRescueManager(QObject* parent)
    : QObject(parent)
{
}

void VehicleRescueManager::handleRescueStatus(
    uint8_t phase,
    uint8_t wp_total,
    uint8_t wp_current,
    uint8_t wps_loaded)
{
    Phase oldPhase = _phase;

    _phase     = static_cast<Phase>(phase);
    _totalWP   = wp_total;
    _currentWP = wp_current;
    _wpsLoaded = (wps_loaded == 1);

    qDebug() << "Rescue Manager Phase Change:"
             << static_cast<int>(oldPhase) << "->" << static_cast<int>(_phase)
             << "| WPs:" << _currentWP << "/" << _totalWP;

    emit statusChanged();

    // Force path redraw whenever INSERT_NAV occurs
    if (_phase == Phase::INSERT_NAV &&
        oldPhase != Phase::INSERT_NAV) {

        emit pathNeedsRefresh();
    }
}

void VehicleRescueManager::handleInsertWpAck(
    int32_t lat,
    int32_t lon,
    bool accepted,
    uint8_t insertBeforeWp)
{
    if (!accepted) {
        return;
    }
    auto* wp = new RescueWaypoint(
        QGeoCoordinate(
            lat / 1e7,
            lon / 1e7));

    if (insertBeforeWp >= _rescuePoints.count()) {

        _rescuePoints.append(wp);

    } else {

        _rescuePoints.insert(insertBeforeWp, wp);
        _activeIndex = insertBeforeWp;
        emit activeIndexChanged();

    }

    emit rescuePointsChanged();
    emit pathNeedsRefresh();
}

bool VehicleRescueManager::missionInProgress() const
{
    return _phase == Phase::TAKEOFF
        || _phase == Phase::TAKING_OFF
        || _phase == Phase::WP_NAV
        || _phase == Phase::INSERT_NAV
        || _phase == Phase::HOLD_POINT
        || _phase == Phase::TARGET_APPROACH
        || _phase == Phase::CENTERING
        || _phase == Phase::DEPLOYING
        || _phase == Phase::GUIDED;
}

bool VehicleRescueManager::canStartMission() const
{
    return _phase == Phase::WPS_GENERATED;
}

QString VehicleRescueManager::statusText() const
{
    switch (_phase) {

    case Phase::IDLE:
        return QStringLiteral("Generate rescue waypoints");

    case Phase::WPS_GENERATED:
        return QStringLiteral("Waypoints generated - confirm start");

    case Phase::TAKEOFF:
        return QStringLiteral("Waiting to arm...");

    case Phase::TAKING_OFF:
        return QStringLiteral("Taking off...");

    case Phase::WP_NAV:
        return QString("Searching: WP %1 / %2")
            .arg(_currentWP + 1)
            .arg(_totalWP);

    case Phase::INSERT_NAV:
        return QStringLiteral("Inserting target waypoint");

    case Phase::HOLD_POINT:
        return QStringLiteral("Holding position");

    case Phase::TARGET_APPROACH:
        return QStringLiteral("Approaching target");

    case Phase::CENTERING:
        return QStringLiteral("Centering over target");

    case Phase::DEPLOYING:
        return QStringLiteral("Deploying payload");

    case Phase::GUIDED:
        return QStringLiteral("Target detected - OBC control");
    }

    return QStringLiteral("Unknown");
}

void VehicleRescueManager::clear()
{
    _rescuePoints.clearAndDeleteContents();

    _activeIndex = 0;

    emit activeIndexChanged();
    emit rescuePointsChanged();
    emit pathNeedsRefresh();
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
    emit pathNeedsRefresh();
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
    emit pathNeedsRefresh();
}
