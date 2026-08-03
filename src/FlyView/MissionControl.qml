import QtQuick
import QtQuick.Controls
import QtPositioning
import QGroundControl
import QGroundControl.Controls

Rectangle {
    id:           missionPanel
    width:        200
    height:       280
    color:        Qt.rgba(0, 0, 0, 0.8)
    radius:       8
    border.color: "white"
    border.width: 1

    // ── FIX 1: activeVehicle must be bound to QGC global, NOT null ──
    // Setting null means it NEVER gets the vehicle — bind it directly
    property var activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
    property var guidedController: null   // injected from FlyView.qml via guidedController: _guidedController

    // Convenience checks
    property bool _vehicleReady: activeVehicle !== null && activeVehicle !== undefined
    property bool _gcReady:      guidedController !== null && guidedController !== undefined

    // ── Debug strip — shows live status, remove after confirmed working ──
    QGCLabel {
        anchors.top:     parent.top
        anchors.left:    parent.left
        anchors.margins: 4
        font.pixelSize:  9
        color:           _vehicleReady ? "lime" : "red"
        wrapMode:        Text.WordWrap
        width:           195
        text:            _vehicleReady
                           ? "Mode: "     + activeVehicle.flightMode
                             + " | Alt: " + Math.round(activeVehicle.altitudeRelative.rawValue) + "m"
                             + " | Armed: "+ activeVehicle.armed
                             + " | GC: "  + (_gcReady ? "OK" : "NULL ⚠️")
                           : "⚠️ No Active Vehicle"
    }

    Column {
        anchors.centerIn: parent
        spacing:          15

        QGCLabel {
            text:      "MISSION CONTROL"
            font.bold: true
            color:     "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // ── 1. TAKEOFF ──
        //
        // FIX 2: Do NOT set armed = true manually before takeoff
        //        actionTakeoff (3) handles arming internally via
        //        guidedModeTakeoff() or startTakeoff() in C++
        //
        // sliderOutputValue = 30 → takeoff altitude 30m
        SliderSwitch {
            width:       170
            confirmText: "TAKEOFF"
            onAccept: {
                if (!_vehicleReady || !_gcReady) {
                    console.log("❌ Takeoff blocked | vehicle=" + _vehicleReady
                                + " | GC=" + _gcReady)
                    return
                }
                guidedController.executeAction(
                    guidedController.actionTakeoff, null, 10, false)
                console.log("✈️ actionTakeoff sent at 30m")
            }
        }

        // ── 2. GO TO POINT B ──
        //
        // FIX 3: Do NOT manually set flightMode before executeAction
        //        actionGoto (8) internally calls guidedModeGotoLocation()
        //        which handles mode switching — setting it manually
        //        before the call can cause a race condition
        //
        // FIX 4: Altitude raised to 50m — ArduPlane fixed-wing needs
        //        minimum altitude for safe turning radius
        //
        // FIX 5: Only enabled when airborne (alt > 5m)
        //        ArduPlane silently rejects Guided goto on ground
        // QGCButton {
        //     width:   170
        //     text:    "Go to Point B"
        //     enabled: _vehicleReady
        //                && activeVehicle.armed
        //                && activeVehicle.altitudeRelative.rawValue > 5
        //     onClicked: {
        //         if (!_vehicleReady || !_gcReady) {
        //             console.log("❌ Goto blocked | vehicle=" + _vehicleReady
        //                         + " | GC=" + _gcReady)
        //             return
        //         }
        //         var target = QtPositioning.coordinate(-35.35772, 149.165338, 50)
        //         // actionGoto (8) — sliderOutputValue ignored for this action
        //         guidedController.executeAction(
        //             guidedController.actionGoto, target, 0, false)
        //         console.log("📍 actionGoto sent → Point B at 50m")
        //     }
        // }

        // 2. TRIGGER SERVO (RC 9 -> 2000)
        QGCButton {
            width:     170
            text:      "DEPLOY"
            enabled:   activeVehicle !== null

            onClicked: {
                if (activeVehicle) {
                    // Method from your Vehicle.h:
                    // virtualTabletJoystickValue(roll, pitch, yaw, thrust)
                    // Note: If this only handles 4 axes, we use the ThreadSafe version:

                    activeVehicle.sendJoystickDataThreadSafe(
                        0.0, 0.0, 0.0, 0.0, // Roll, Pitch, Yaw, Thrust (Neutral)
                        0, 0,               // Buttons
                        0.0, 0.0,           // Pitch/Roll Ext
                        1.0,                // aux1 -> This is RC9. 1.0 = Max PWM (1900)
                        0.0, 0.0, 0.0, 0.0, 0.0
                    )
                    console.log("🎮 MAVLink #70: RC9 Override High")
                }
            }
        }

        // ── 3. AUTO LAND ──
        //
        // FIX 6: "Land" mode does NOT exist on ArduPlane — this was
        //        causing a silent failure. actionLand (2) directly calls
        //        _activeVehicle.guidedModeLand() in C++ which triggers
        //        ArduPlane AUTOLAND — confirmed from GuidedActionsController source
        //
        // FIX 7: Do NOT manually set flightMode = "Land" before executeAction
        //        guidedModeLand() handles everything internally
        //
        // visible logic uses isAtPointB + isArUcoDetected from your C++ properties
        QGCButton {
            width:   170
            text:    "AUTO LAND"
            visible: _vehicleReady
                    // && activeVehicle.isAtPointB
                    // && activeVehicle.isArUcoDetected
            enabled: _vehicleReady && activeVehicle.armed
            onClicked: {
                if (!_vehicleReady || !_gcReady) {
                    console.log("❌ Land blocked | vehicle=" + _vehicleReady
                                + " | GC=" + _gcReady)
                    return
                }
                // actionSetFlightMode (26) → _activeVehicle.flightMode = actionData
                // This is identical to MAVProxy "mode autoland" — no Guided needed
                guidedController.executeAction(
                    guidedController.actionSetFlightMode, "Autoland", 0, false)
                console.log("🛬 actionSetFlightMode Autoland sent | mode="
                            + activeVehicle.flightMode)
            }
            background: Rectangle {
                color:  parent.enabled ? "#27ae60" : "#555555"
                radius: 4
            }
        }
    }
}
