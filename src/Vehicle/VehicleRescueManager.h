#pragma once

#include <QObject>
#include <QString>
#include "QmlObjectListModel.h"

class RescueWaypoint;

class VehicleRescueManager : public QObject
{
    Q_OBJECT

    // Mission state
    Q_PROPERTY(bool missionInProgress READ missionInProgress NOTIFY statusChanged)
    Q_PROPERTY(bool canStartMission READ canStartMission NOTIFY statusChanged)
    Q_PROPERTY(bool wpsLoaded READ wpsLoaded NOTIFY statusChanged)
    Q_PROPERTY(int currentWP READ currentWP NOTIFY statusChanged)
    Q_PROPERTY(int totalWP READ totalWP NOTIFY statusChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)
    Q_PROPERTY(int phase READ phase NOTIFY statusChanged)

    // Path display
    Q_PROPERTY(QmlObjectListModel* rescuePoints READ rescuePoints NOTIFY rescuePointsChanged)
    Q_PROPERTY(int activeIndex READ activeIndex NOTIFY activeIndexChanged)

public:
    explicit VehicleRescueManager(QObject* parent = nullptr);

    // Status packets
    void handleRescueStatus(
        uint8_t phase,
        uint8_t wp_total,
        uint8_t wp_current,
        uint8_t wps_loaded);

    // Waypoint packets
    void handleRescueWaypoint(
        uint16_t totalCount,
        uint16_t seq,
        int32_t lat,
        int32_t lon);

    void handleWaypointReached(
        uint16_t index,
        bool reached);

    void clear();

    bool missionInProgress() const;
    bool canStartMission() const;

    bool wpsLoaded() const {
        return _wpsLoaded;
    }
    void handleInsertWpAck(
        int32_t lat,
        int32_t lon,
        bool accepted,
        uint8_t insertBeforeWp);
    int phase() const {
        return static_cast<int>(_phase);
    }

    int currentWP() const {
        return static_cast<int>(_currentWP) + 1;
    }

    int totalWP() const {
        return static_cast<int>(_totalWP);
    }

    QString statusText() const;

    QmlObjectListModel* rescuePoints() {
        return &_rescuePoints;
    }

    int activeIndex() const {
        return _activeIndex;
    }

signals:
    void statusChanged();
    void rescuePointsChanged();
    void activeIndexChanged();

    // Used by QML to redraw path
    void pathNeedsRefresh();

private:

    enum class Phase : uint8_t {
        IDLE            = 0,
        TAKEOFF         = 1,
        TAKING_OFF      = 2,
        WP_NAV          = 3,
        INSERT_NAV      = 4,
        HOLD_POINT      = 5,
        TARGET_APPROACH = 6,
        CENTERING       = 7,
        DEPLOYING       = 8,
        GUIDED          = 9,
        WPS_GENERATED   = 10,
    };

    Phase   _phase     { Phase::IDLE };
    uint8_t _totalWP   { 0 };
    uint8_t _currentWP { 0 };
    bool    _wpsLoaded { false };

    QmlObjectListModel _rescuePoints;
    int _activeIndex { 0 };
};
