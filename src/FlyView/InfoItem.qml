import QtQuick
import QtQuick.Layouts

Item {

    Layout.fillWidth: true

    implicitHeight: 22

    property string icon:      ""
    property string value:     ""
    property color  iconColor: "white"

    Row {

        anchors.fill: parent

        spacing: 6

        Text {

            width: 38

            anchors.verticalCenter: parent.verticalCenter

            text: icon

            color: iconColor

            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 0.5

            horizontalAlignment: Text.AlignLeft
        }

        Text {

            width: parent.width - 38 - 6

            anchors.verticalCenter: parent.verticalCenter

            text: value

            color: "#F2F6FA"

            font.pixelSize: 12
            font.bold: true

            elide: Text.ElideRight
        }
    }
}
