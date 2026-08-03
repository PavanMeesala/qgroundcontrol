import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap
// import QtQuick.Controls 2.15

// To implement a custom overlay copy this code to your own control in your custom code source. Then override the
// FlyViewCustomLayer.qml resource with your own qml. See the custom example and documentation for details.
Item {
    id: _root
    // Lifebuoy Control Panel - Custom Overlay Example
    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle
    property int compId: vehicle ? vehicle.defaultComponentId : -1

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl
    property var mgr: _activeVehicle ? _activeVehicle.rescueManager : null
    property bool paramsReady: vehicle !== null
                           && vehicle.parameterManager !== null

    // since this file is a placeholder for the custom layer in a standard build, we will just pass through the parent insets
    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    parentToolInsets.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset
    }
    Rectangle {
        id: lifebuoyPanel
        anchors.top: parent.top

        states: [
            State {
                name: "LEFT"
                when: QGroundControl.multiVehicleManager.vehicles.count > 1
                AnchorChanges {
                    target: lifebuoyPanel
                    anchors.left:  parent.left
                    anchors.right: undefined
                }
                PropertyChanges {
                    target: lifebuoyPanel
                    anchors.topMargin: ScreenTools.toolbarHeight * 0.8 + ScreenTools.defaultFontPixelHeight * 0.6
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.6
                    // anchors.leftMargin:  60
                    // anchors.topMargin:  10
                }
            },
            State {
                name: "RIGHT"
                when: QGroundControl.multiVehicleManager.vehicles.count <= 1
                AnchorChanges {
                    target: lifebuoyPanel
                    anchors.left:  undefined
                    anchors.right: parent.right
                }
                PropertyChanges {
                    target: lifebuoyPanel
                    anchors.leftMargin:  0
                    anchors.topMargin: ScreenTools.toolbarHeight * 3 + ScreenTools.defaultFontPixelHeight * 0.5
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.6
                    // anchors.rightMargin: 10
                    // anchors.topMargin:  60
                }
            }
        ]

        transitions: Transition {
            AnchorAnimation { duration: 200 }
        }
        width: 160
        height: 130
        radius: 10
        color:Qt.rgba(0, 0, 0, 0.11)
        visible: QGroundControl.multiVehicleManager.activeVehicle !== null
        QGCLabel {
                text:      "Lifebuoy Control"
                font.bold: true
                color:     "white"
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
            }

        // ================= DEPLOY BUTTON =================
        Rectangle {
            id: deployButton

            width: 100
            height: 30
            radius: 8

            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter

            property bool deployed: false

            color: deployed ? "#27ae60" : "#c0392b"
            border.color: "#222"
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent

                text: deployButton.deployed ? "RETRACT" : "DEPLOY"

                font.pixelSize: 12
                font.bold: true

                // FORCE visibility in all themes
                color: "white"

                // Strong outline (fixes invisibility issue)
                style: Text.Outline
                styleColor: "black"

                // Extra trick (important)
                renderType: Text.NativeRendering
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deployButton.deployed = !deployButton.deployed

                    if (QGroundControl.multiVehicleManager.activeVehicle) {
                        QGroundControl.multiVehicleManager.activeVehicle
                            .deployLifebuoy(deployButton.deployed)
                    }
                }
            }
        }

        // ===============================
        // ⚙ SETTINGS BUTTON
        // ===============================
        Rectangle {
            id: settingsButton
            width: 50
            height: 50
            radius: 25

            anchors.top: deployButton.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            color: "transparent"   // clean background

            Image {
                anchors.centerIn: parent
                width: 30
                height: 30

                source: "qrc:/res/gear-white.svg"   // ✅ correct QGC resource path

                fillMode: Image.PreserveAspectFit
            }

            opacity: paramsReady ? 1.0 : 0.4

            MouseArea {
                anchors.fill: parent
                enabled: paramsReady

                onClicked: {
                    if (paramsReady) {
                        settingsPopup.open()
                    } else {
                        console.log("⏳ Params not loaded yet")
                    }
                }
            }
        }
        // ===============================
        // ⚙ SETTINGS POPUP
        // ===============================
        Connections {
            target: QGroundControl.multiVehicleManager

            function onActiveVehicleChanged() {
                deployButton.deployed = false
            }
        }

    }
Popup {
    id: settingsPopup

    width: 380
    implicitHeight: mainColumn.implicitHeight + 32   // 16px top + 16px bottom margin
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    // Center in the window rather than defaulting to top-left, which
    // was overlapping TelemetryCard docked in the same corner.
    x: parent ? (parent.width  - width)  / 2 : 0
    y: parent ? (parent.height - implicitHeight) / 2 : 0

    background: Rectangle {
        color: "#2c3e50"
        radius: 10
    }

    // Servo channels are fixed AUX1-3 (Servo9/10/11). Only their PWM
    // range is user-configurable now, not the channel assignment.
    readonly property int servo1Channel: 9
    readonly property int servo2Channel: 10
    readonly property int servo3Channel: 11

    onOpened: {
        min1Field.text = vehicle.getParamInt("SERVO9_MIN", 1100).toString()
        max1Field.text = vehicle.getParamInt("SERVO9_MAX", 1900).toString()

        min2Field.text = vehicle.getParamInt("SERVO10_MIN", 1100).toString()
        max2Field.text = vehicle.getParamInt("SERVO10_MAX", 1900).toString()

        min3Field.text = vehicle.getParamInt("SERVO11_MIN", 1100).toString()
        max3Field.text = vehicle.getParamInt("SERVO11_MAX", 1900).toString()
    }

    Column {
        id: mainColumn

        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 🔷 Header Row
        Item {
            width: parent.width
            height: 30

            Text {
                text: "Settings"
                color: "white"
                font.pixelSize: 20
                font.bold: true
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 70
                height: 28
                radius: 6
                color: "transparent"
                border.color: "#e74c3c"
                border.width: 1

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    color: "#e74c3c"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: settingsPopup.close()
                }
            }
        }

        // 🔷 Form Area - 3 column table: Servo | Min PWM | Max PWM
        Column {
            width: parent.width
            spacing: 10

            // Column headers
            Row {
                spacing: 8

                Text {
                    text: "Servo"
                    color: "#bdc3c7"
                    font.pixelSize: 12
                    font.bold: true
                    width: 64
                }

                Text {
                    text: "Min PWM"
                    color: "#bdc3c7"
                    font.pixelSize: 12
                    font.bold: true
                    width: 115
                }

                Text {
                    text: "Max PWM"
                    color: "#bdc3c7"
                    font.pixelSize: 12
                    font.bold: true
                    width: 115
                }
            }

            // Servo 1
            Row {
                spacing: 8

                Text {
                    text: "Servo 1"
                    color: "white"
                    width: 64
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: min1Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO9_MIN", 1100).toString() : "1100"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: max1Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO9_MAX", 1900).toString() : "1900"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }
            }

            // Servo 2
            Row {
                spacing: 8

                Text {
                    text: "Servo 2"
                    color: "white"
                    width: 64
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: min2Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO10_MIN", 1100).toString() : "1100"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: max2Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO10_MAX", 1900).toString() : "1900"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }
            }

            // Servo 3
            Row {
                spacing: 8

                Text {
                    text: "Servo 3"
                    color: "white"
                    width: 64
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: min3Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO11_MIN", 1100).toString() : "1100"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 32
                    radius: 6
                    color: "#ecf0f1"

                    TextField {
                        id: max3Field
                        anchors.fill: parent
                        anchors.margins: 2
                        color: "black"
                        font.pixelSize: 14
                        placeholderText: vehicle ? vehicle.getParamInt("SERVO11_MAX", 1900).toString() : "1900"
                        placeholderTextColor: "#7f8c8d"
                        validator: IntValidator { bottom: 0; top: 3000 }

                        background: Rectangle {
                            radius: 6
                            color: "#ecf0f1"
                            border.color: "#bdc3c7"
                        }
                    }
                }
            }
        }

        // 🔷 Save Button aligned RIGHT
        Item {
            width: parent.width
            height: 30

            Rectangle {
                width: 70
                height: 28
                radius: 6
                color: "transparent"
                border.color: "#2ecc71"
                border.width: 1

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    color: "#2ecc71"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (QGroundControl.multiVehicleManager.activeVehicle) {
                            QGroundControl.multiVehicleManager.activeVehicle
                                .setServoSettings(
                                    settingsPopup.servo1Channel,
                                    settingsPopup.servo2Channel,
                                    settingsPopup.servo3Channel,
                                    parseInt(min1Field.text),
                                    parseInt(max1Field.text),
                                    parseInt(min2Field.text),
                                    parseInt(max2Field.text),
                                    parseInt(min3Field.text),
                                    parseInt(max3Field.text)
                                )
                        }
                        settingsPopup.close()
                    }
                }
            }
        }
    }
}


}
