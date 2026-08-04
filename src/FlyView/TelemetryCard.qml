import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Rectangle {
    id: root

    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Live per-flight timer. vehicle.hobbsMeter is a LIFETIME accumulated
    // counter, not a per-flight stopwatch, and Vehicle's real flight timer
    // (_flightTimer) is private C++ with no public QML property - so this
    // tracks it independently off the confirmed-real vehicle.armed property.
    property real _flightStartMs: 0
    property int  _flightElapsedSec: 0

    function _formatFlightTime(totalSeconds) {
        var h = Math.floor(totalSeconds / 3600)
        var m = Math.floor((totalSeconds % 3600) / 60)
        var s = totalSeconds % 60

        function pad(n) { return (n < 10 ? "0" : "") + n }

        return h > 0 ? (pad(h) + ":" + pad(m) + ":" + pad(s))
                      : (pad(m) + ":" + pad(s))
    }

    Connections {
        target: vehicle
        function onArmedChanged(armed) {
            if (armed) {
                root._flightStartMs = Date.now()
                root._flightElapsedSec = 0
                flightTimeTicker.start()
            } else {
                root._flightElapsedSec = Math.floor((Date.now() - root._flightStartMs) / 1000)
                flightTimeTicker.stop()
            }
        }
    }

    Timer {
        id:       flightTimeTicker
        interval: 1000
        repeat:   true
        onTriggered: {
            root._flightElapsedSec = Math.floor((Date.now() - root._flightStartMs) / 1000)
        }
    }

    width: 236
    implicitHeight: contentColumn.implicitHeight + 28

    radius: 14

    color: "#7A0A1525"
    border.color: "#3DFFFFFF"
    border.width: 1

    Column {
        id: contentColumn

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 14
        }

        spacing: 12

        //---------------------------------------------------
        SectionHeader { text: "FLIGHT" }

        GridLayout {
            width: parent.width

            columns: 2

            columnSpacing: 12
            rowSpacing: 7

            InfoItem {
                icon: "ALT"
                iconColor: "#5DA8FF"
                value: vehicle ? vehicle.altitudeRelative.valueString + " m" : "--"
            }

            InfoItem {
                icon: "SPD"
                iconColor: "#5DA8FF"
                value: vehicle ? vehicle.groundSpeed.valueString + " m/s" : "--"
            }

            InfoItem {
                icon: "TIME"
                iconColor: "#4CB6FF"
                value: root._flightStartMs > 0 ? root._formatFlightTime(root._flightElapsedSec) : "--:--"
            }

            InfoItem {
                icon: "HOME"
                iconColor: "#FFB366"
                value: vehicle ? vehicle.distanceToHome.valueString + " m" : "--"
            }
        }

        //---------------------------------------------------
        SectionHeader { text: "VEHICLE" }

        GridLayout {
            width: parent.width

            columns: 2

            columnSpacing: 12
            rowSpacing: 7

            InfoItem {
                icon: "BAT"
                iconColor: "#8AE34A"

                value:
                    vehicle && vehicle.batteries.count > 0 ?
                    vehicle.batteries.get(0).percentRemaining.valueString + "%" :
                    "--"
            }

            InfoItem {
                icon: "VOLT"
                iconColor: "#FFD84C"

                value:
                    vehicle && vehicle.batteries.count > 0 ?
                    vehicle.batteries.get(0).voltage.valueString + " V" :
                    "--"
            }

            InfoItem {
                icon: "SAT"
                iconColor: "#73BFFF"

                value:
                    vehicle ?
                    vehicle.gps.count.valueString :
                    "--"
            }

            InfoItem {
                icon: "HDOP"
                iconColor: "#FF6060"

                value:
                    vehicle ?
                    vehicle.gps.hdop.valueString :
                    "--"
            }

            InfoItem {
                icon: "GPS"
                iconColor: "#58D6A0"

                Layout.columnSpan: 2

                value:
                    vehicle ?
                    vehicle.gps.lock.valueString :
                    "--"
            }
        }

        //---------------------------------------------------
        SectionHeader { text: "GIMBAL" }

        GridLayout {
            width: parent.width
            columns: 2

            columnSpacing: 12
            rowSpacing: 7

            // Confirmed against your actual GimbalIndicator.qml source:
            // gimbalController.activeGimbal IS real, and retracted/yawLock/
            // absolutePitch/absoluteYaw are all real Fact properties on it.
            // No absoluteRoll used - your own gimbal indicator never shows
            // roll either (most gimbals are 2-axis pitch/yaw).
            property var _activeGimbal:
                vehicle && vehicle.gimbalController ?
                vehicle.gimbalController.activeGimbal :
                null

            InfoItem {
                icon: "GIM"
                iconColor: "#B56CFF"

                Layout.columnSpan: 2

                value:
                    parent._activeGimbal ?
                    (parent._activeGimbal.retracted ? "Retracted" :
                     (parent._activeGimbal.yawLock ? "Yaw Locked" : "Yaw Follow")) :
                    "No gimbal"
            }

            InfoItem {
                icon: "PITCH"
                iconColor: "#B56CFF"

                value:
                    parent._activeGimbal ?
                    parent._activeGimbal.absolutePitch.valueString :
                    "--"
            }

            InfoItem {
                icon: "YAW"
                iconColor: "#B56CFF"

                value:
                    parent._activeGimbal ?
                    parent._activeGimbal.absoluteYaw.valueString :
                    "--"
            }
        }

        //---------------------------------------------------
        SectionHeader { text: "BEACON" }

        GridLayout {
            width: parent.width

            columns: 2

            columnSpacing: 12
            rowSpacing: 7

            InfoItem {
                icon: "BCN"
                iconColor: "#FF9C43"

                value:
                    vehicle ?
                    (vehicle.homeBeaconValid ? "Connected" : "Lost") :
                    "--"
            }

            InfoItem {
                icon: "HDG"
                iconColor: "#FF9C43"

                value:
                    vehicle ?
                    Number(vehicle.homeBeaconHeading).toFixed(0) + "°" :
                    "--"
            }

            InfoItem {
                icon: "DIST"
                iconColor: "#FF9C43"

                Layout.columnSpan: 2

                value: {
                    if (!vehicle || !vehicle.homeBeaconValid)
                        return "--"

                    return vehicle.coordinate.distanceTo(
                                vehicle.homeBeaconCoordinate).toFixed(1) + " m"
                }
            }
        }
    }
}
