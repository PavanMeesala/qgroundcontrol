#pragma once

#include <QObject>
#include <QVariantList>
#include <QGeoCoordinate>

class Vehicle;

class RescueWaypointManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        QVariantList rescuePoints
        READ rescuePoints
        NOTIFY rescuePointsChanged)

    Q_PROPERTY(
        int currentIndex
        READ currentIndex
        NOTIFY currentIndexChanged)

public:

    explicit RescueWaypointManager(
        Vehicle* vehicle,
        QObject* parent=nullptr);

    QVariantList rescuePoints() const;

    int currentIndex() const;

signals:

    void rescuePointsChanged();
    void currentIndexChanged();

private slots:

    void _onWaypointReceived(
        uint16_t total,
        uint16_t seq,
        int32_t lat,
        int32_t lon);

    void _onWaypointReached(
        uint16_t index,
        bool reached);
    void _onFlightModeChanged(QString flightMode);

private:

    QVariantList _points;
    int _currentIndex = -1;
    uint16_t _expectedCount = 0;

};
