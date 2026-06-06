#pragma once

#include <QObject>
#include "QmlObjectListModel.h"

class RescueWaypoint;

class VehicleRescueManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QmlObjectListModel* rescuePoints
               READ rescuePoints
               CONSTANT)

    Q_PROPERTY(int activeIndex
               READ activeIndex
               NOTIFY activeIndexChanged)

public:
    explicit VehicleRescueManager(QObject* parent = nullptr);

    QmlObjectListModel* rescuePoints()
    {
        return &_rescuePoints;
    }

    int activeIndex() const
    {
        return _activeIndex;
    }

    void clear();

    void handleRescueWaypoint(
        uint16_t totalCount,
        uint16_t seq,
        int32_t lat,
        int32_t lon);

    void handleWaypointReached(
        uint16_t index,
        bool reached);

signals:
    void rescuePointsChanged();
    void activeIndexChanged();

private:
    QmlObjectListModel _rescuePoints;
    int _activeIndex = -1;
};
