#pragma once

#include <QObject>
#include <QGeoCoordinate>

class RescueWaypoint : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate CONSTANT)
    Q_PROPERTY(bool reached READ reached WRITE setReached NOTIFY reachedChanged)

public:
    explicit RescueWaypoint(
        const QGeoCoordinate& coordinate,
        QObject* parent = nullptr);

    QGeoCoordinate coordinate() const { return _coordinate; }

    bool reached() const { return _reached; }

    void setReached(bool reached);

signals:
    void reachedChanged();

private:
    QGeoCoordinate _coordinate;
    bool _reached = false;
};
