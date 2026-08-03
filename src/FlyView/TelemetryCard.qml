import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
Rectangle {
    id: root

    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Self-anchored to the parent's top-left, clearing the toolbar/header.
    // If the parent that instantiates TelemetryCard already anchors it
    // explicitly, remove this block and let the parent control placement.
    anchors {
        top:  parent.top
        left: parent.left
        topMargin:  ScreenTools.toolbarHeight + 12
        leftMargin: 12
    }

    width: 220
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

        spacing: 8

        //---------------------------------------------------
        SectionHeader { text: "FLIGHT" }

        GridLayout {
            width: parent.width

            columns: 2

            columnSpacing: 12
            rowSpacing: 7

            InfoItem {
                icon: "↑"
                iconColor: "#5DA8FF"
                value: vehicle ? vehicle.altitudeRelative.valueString + " m" : "--"
            }

            InfoItem {
                icon: "→"
                iconColor: "#5DA8FF"
                value: vehicle ? vehicle.groundSpeed.valueString + " m/s" : "--"
            }

            InfoItem {
                icon: "⏱"
                iconColor: "#4CB6FF"
                value: vehicle ? vehicle.flightTime.valueString : "--"
            }

            InfoItem {
                icon: "🏠"
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
                icon: "🔋"
                iconColor: "#8AE34A"

                value:
                    vehicle && vehicle.batteries.count > 0 ?
                    vehicle.batteries.get(0).percentRemaining.valueString + "%" :
                    "--"
            }

            InfoItem {
                icon: "⚡"
                iconColor: "#FFD84C"

                value:
                    vehicle && vehicle.batteries.count > 0 ?
                    vehicle.batteries.get(0).voltage.valueString + " V" :
                    "--"
            }

            InfoItem {
                icon: "🛰"
                iconColor: "#73BFFF"

                value:
                    vehicle ?
                    vehicle.gps.count.valueString :
                    "--"
            }

            InfoItem {
                icon: "📍"
                iconColor: "#FF6060"

                value:
                    vehicle ?
                    vehicle.gps.hdop.valueString :
                    "--"
            }

            InfoItem {
                icon: "🌍"
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

            // NOTE: "vehicle.gimbal" never existed - the real path is
            // vehicle.gimbalController.activeGimbal. This is why mode/roll/
            // pitch/yaw were always falling through to their fallback values.
            property var _activeGimbal: vehicle && vehicle.gimbalController ?
                                             vehicle.gimbalController.activeGimbal :
                                             null

            InfoItem {
                icon: "🎥"
                iconColor: "#B56CFF"

                // TODO(confirm): couldn't verify a "mode" string on the
                // Gimbal object from source - only absoluteRoll/Pitch/Yaw
                // are confirmed. Flagging rather than guessing; swap this
                // for the real property once confirmed (e.g. yawLock).
                value: _activeGimbal ? "Active" : "--"
            }

            Item { }    // empty cell

            InfoItem {
                icon: "⤴"
                iconColor: "#B56CFF"

                value:
                    _activeGimbal ?
                    Number(_activeGimbal.absoluteRoll.rawValue).toFixed(1) + "°" :
                    "--"
            }

            InfoItem {
                icon: "↕"
                iconColor: "#B56CFF"

                value:
                    _activeGimbal ?
                    Number(_activeGimbal.absolutePitch.rawValue).toFixed(1) + "°" :
                    "--"
            }

            InfoItem {
                icon: "↺"
                iconColor: "#B56CFF"

                value:
                    _activeGimbal ?
                    Number(_activeGimbal.absoluteYaw.rawValue).toFixed(1) + "°" :
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
                icon: "🚢"
                iconColor: "#FF9C43"

                value:
                    vehicle ?
                    (vehicle.homeBeaconValid ? "Connected" : "Lost") :
                    "--"
            }

            InfoItem {
                icon: "🧭"
                iconColor: "#FF9C43"

                value:
                    vehicle ?
                    Number(vehicle.homeBeaconHeading).toFixed(0) + "°" :
                    "--"
            }

            InfoItem {
                icon: "📡"
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
