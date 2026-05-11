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
        anchors.right: parent.right
        anchors.leftMargin: 20  // Specific distance from left
        anchors.topMargin:  60
        // anchors.margins: 60 // make it 20 to move it to corner

        width: 160
        height: 150
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
        height: 360
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#2c3e50"
            radius: 10
        }

        onOpened: {

            servo1Field.text =
                vehicle.getParamInt("SERVO9_FUNCTION", 59) === 59 ? "9" : ""

            servo2Field.text =
                vehicle.getParamInt("SERVO10_FUNCTION", 59) === 59 ? "10" : ""

            servo3Field.text =
                vehicle.getParamInt("SERVO11_FUNCTION", 59) === 59 ? "11" : ""

            // IMPORTANT
            deployField.text = ""
            retractField.text = ""
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

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

            // 🔷 Form Area
            Column {
                width: parent.width
                spacing: 10

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

                        TextField {
                            id: servo1Field
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "black"
                            font.pixelSize: 14

                            placeholderText: "e.g. 9"
                            placeholderTextColor: "#7f8c8d"

                            background: Rectangle {
                                radius: 6
                                color: "#ecf0f1"
                                border.color: "#bdc3c7"
                            }
                        }
                    }
                }

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

                        TextField {
                            id: servo2Field
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "black"
                            font.pixelSize: 14

                            placeholderText: "e.g. 10"
                            placeholderTextColor: "#7f8c8d"

                            background: Rectangle {
                                radius: 6
                                color: "#ecf0f1"
                                border.color: "#bdc3c7"
                            }
                        }
                    }
                }

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

                        TextField {
                            id: servo3Field
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "black"
                            font.pixelSize: 14

                            placeholderText: "e.g. 11"
                            placeholderTextColor: "#7f8c8d"

                            background: Rectangle {
                                radius: 6
                                color: "#ecf0f1"
                                border.color: "#bdc3c7"
                            }
                        }

                    }
                }

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

                        TextField {
                            id: deployField
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "black"
                            font.pixelSize: 14

                            placeholderText: "e.g. 1900"
                            placeholderTextColor: "#7f8c8d"
                            background: Rectangle {
                                radius: 6
                                color: "#ecf0f1"
                                border.color: "#bdc3c7"
                            }
                        }
                    }
                }

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

                        TextField {
                            id: retractField
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "black"
                            font.pixelSize: 14

                            placeholderText: "e.g. 1100"
                            placeholderTextColor: "#7f8c8d"

                            background: Rectangle {
                                radius: 6
                                color: "#ecf0f1"
                                border.color: "#bdc3c7"
                            }
                        }
                    }
                }
            }

            Item { height: 10 }

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
}
