import QtQuick

Item {

    id: root

    width: parent.width
    height: 24

    property string text: ""

    Column {

        anchors.fill: parent

        spacing: 5

        Text {

            text: root.text

            color: "#AFD8FF"

            font.pixelSize: 12
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1
        }

        Rectangle {

            width: 40
            height: 2
            radius: 1

            color: "#55AFD8FF"
        }
    }
}
