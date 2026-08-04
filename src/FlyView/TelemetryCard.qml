import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Rectangle {
    id: root

    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

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
                // NOTE: "vehicle.flightTime" never existed - that was wrong
                // of me to give you without checking. The only confirmed
                // public flight-duration property is hobbsMeter, but that's
                // normally a LIFETIME accumulated-hours counter in aviation,
                // not a per-flight stopwatch. Flagging this rather than
                // assuming it's what you actually want.
                value: vehicle ? vehicle.hobbsMeter : "--"
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

            // NOTE: "vehicle.gimbal" never existed - confirmed the real path
            // is vehicle.gimbalController. However I could NOT confirm
            // "activeGimbal" is a real property (that was a guess last
            // time). What IS confirmed from QGC's own source is that
            // gimbalController.gimbals is a real list, and its items expose
            // Fact-based absoluteRoll/absolutePitch/absoluteYaw. Using the
            // first entry in that list instead of gambling on activeGimbal.
            property var _firstGimbal:
                vehicle && vehicle.gimbalController && vehicle.gimbalController.gimbals.count > 0 ?
                vehicle.gimbalController.gimbals.get(0) :
                null

            InfoItem {
                icon: "GIM"
                iconColor: "#B56CFF"

                // TODO(confirm): still unverified - only absoluteRoll/Pitch/
                // Yaw are confirmed Fact names on a gimbal list entry.
                value: _firstGimbal ? "Active" : "--"
            }

            Item { }    // empty cell

            InfoItem {
                icon: "ROLL"
                iconColor: "#B56CFF"

                value:
                    _firstGimbal ?
                    Number(_firstGimbal.absoluteRoll.rawValue).toFixed(1) + "°" :
                    "--"
            }

            InfoItem {
                icon: "PITCH"
                iconColor: "#B56CFF"

                value:
                    _firstGimbal ?
                    Number(_firstGimbal.absolutePitch.rawValue).toFixed(1) + "°" :
                    "--"
            }

            InfoItem {
                icon: "YAW"
                iconColor: "#B56CFF"

                value:
                    _firstGimbal ?
                    Number(_firstGimbal.absoluteYaw.rawValue).toFixed(1) + "°" :
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
