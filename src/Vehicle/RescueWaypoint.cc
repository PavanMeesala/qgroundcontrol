#include "RescueWaypoint.h"

RescueWaypoint::RescueWaypoint(
    const QGeoCoordinate& coordinate,
    QObject* parent)
    : QObject(parent)
    , _coordinate(coordinate)
{
}

void RescueWaypoint::setReached(bool reached)
{
    if (_reached == reached) {
        return;
    }

    _reached = reached;
    emit reachedChanged();
}
