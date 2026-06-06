import QtQuick
import QtLocation

MapQuickItem {

    property var waypoint
    property int index
    property int activeIndex

    coordinate: waypoint.coordinate

    anchorPoint.x: 14
    anchorPoint.y: 14

    sourceItem: Rectangle {

        width: 28
        height: 28
        radius: 14

        border.width: 2
        border.color: "white"

        color:
            waypoint.reached ?
                "green" :
            index === activeIndex ?
                "yellow" :
                "red"

        Text {
            anchors.centerIn: parent
            text: index
            font.bold: true
            color: "black"
        }
    }
}
