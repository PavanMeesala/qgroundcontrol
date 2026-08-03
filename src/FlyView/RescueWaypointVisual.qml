import QtQuick
import QtLocation

MapQuickItem {

    property var waypoint
    property int index
    property int activeIndex

    coordinate: waypoint.coordinate

    anchorPoint.x: 6
    anchorPoint.y: 6

    sourceItem: Rectangle {

        width: 12
        height: 12
        radius: 6

        border.width: 1
        border.color: "white"

        color:
            waypoint.reached ?
                "green" :
            index === activeIndex ?
                "yellow" :
                "red"

        // Text {
        //     anchors.centerIn: parent
        //     text: index
        //     font.bold: true
        //     color: "black"
        // }
    }
}
