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

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

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

    // ================= DEPLOY BUTTON =================
    Rectangle {
        id: deployButton

        width: 170
        height: 55
        radius: 10

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20

        visible: QGroundControl.multiVehicleManager.activeVehicle !== null

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

            font.pixelSize: 20
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
        anchors.right: parent.right
        anchors.margins: 20

        color: "transparent"   // clean background

        Image {
            anchors.centerIn: parent
            width: 30
            height: 30

            source: "qrc:/res/gear-white.svg"   // ✅ correct QGC resource path

            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            onClicked: settingsPopup.open()
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
     Popup {
        id: settingsPopup
        width: 380
        height: 360
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#2c3e50"
            radius: 10
        }
        onOpened: {
            aux1.text = "1"
            aux2.text = "2"
            aux3.text = "3"
            deployPWM.text = "1900"
            retractPWM.text = "1100"
        }
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // 🔷 Header Row
            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: "Settings"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }

                Item { width: 10 }

                Rectangle {
                    anchors.top: settingsPopup.top
                    anchors.right: settingsPopup.right
                    width: 70
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.color: "#e74c3c"
                    border.width: 1

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

            // 🔷 Form Area

            Column {
                width: parent.width
                spacing: 10

                // Servo 1
                Row {
                    spacing: 10

                    Text {
                        text: "Servo 1 (AUX)"
                        color: "white"
                        width: 140
                    }

                    Rectangle {
                        width: 180
                        height: 32
                        radius: 6
                        color: "#ecf0f1"

                        TextInput {
                            id: servo1Field
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "black"
                        }
                    }
                }

                // Servo 2
                Row {
                    spacing: 10

                    Text {
                        text: "Servo 2 (AUX)"
                        color: "white"
                        width: 140
                    }

                    Rectangle {
                        width: 180
                        height: 32
                        radius: 6
                        color: "#ecf0f1"

                        TextInput {
                            id: servo2Field
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "black"
                        }
                    }
                }

                // Servo 3
                Row {
                    spacing: 10

                    Text {
                        text: "Servo 3 (AUX)"
                        color: "white"
                        width: 140
                    }

                    Rectangle {
                        width: 180
                        height: 32
                        radius: 6
                        color: "#ecf0f1"

                        TextInput {
                            id: servo3Field
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "black"
                        }
                    }
                }

                // Deploy PWM
                Row {
                    spacing: 10

                    Text {
                        text: "Deploy PWM"
                        color: "white"
                        width: 140
                    }

                    Rectangle {
                        width: 180
                        height: 32
                        radius: 6
                        color: "#ecf0f1"

                        TextInput {
                            id: deployField
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "black"
                        }
                    }
                }

                // Retract PWM
                Row {
                    spacing: 10

                    Text {
                        text: "Retract PWM"
                        color: "white"
                        width: 140
                    }

                    Rectangle {
                        width: 180
                        height: 32
                        radius: 6
                        color: "#ecf0f1"

                        TextInput {
                            id: retractField
                            anchors.fill: parent
                            anchors.margins: 6
                            color: "black"
                        }
                    }
                }
            }

            Item { height: 10 }

            // 🔷 Save Button (FIXED POSITION)
            Rectangle {
                width: 100
                height: 36
                radius: 6
                color: "transparent"
                border.color: "#2ecc71"
                border.width: 1

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
                                    parseInt(servo1Field.text),
                                    parseInt(servo2Field.text),
                                    parseInt(servo3Field.text),
                                    parseInt(deployField.text),
                                    parseInt(retractField.text)
                                )
                        }
                        settingsPopup.close()
                    }
                }
            }
        }
    }
}
