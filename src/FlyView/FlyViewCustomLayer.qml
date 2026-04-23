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
    Rectangle {
        id: deployButton

        width: 160
        height: 50
        radius: 8

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20

        property bool deployed: false

        visible: QGroundControl.multiVehicleManager.activeVehicle !== null


        color: deployed ? "#2ecc71" : "#e74c3c"   // green / red
        border.color: "black"
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent

            text: deployButton.deployed ? "RETRACT" : "DEPLOY"
            color: "white"
            font.pixelSize: 18
            font.bold: true

            // 🔥 ensures visibility on any background
            style: Text.Outline
            styleColor: "black"
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                deployButton.deployed = !deployButton.deployed

                if (QGroundControl.multiVehicleManager.activeVehicle) {
                    QGroundControl.multiVehicleManager
                        .activeVehicle
                        .deployLifebuoy(deployButton.deployed)
                }
            }
        }
    }
}
