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

            width: 32

            anchors.verticalCenter: parent.verticalCenter

            text: icon

            color: iconColor

            font.pixelSize: ScreenTools.defaultFontPixelHeight

            horizontalAlignment: Text.AlignHCenter
        }

        Text {

            width: parent.width - 18 - 6

            anchors.verticalCenter: parent.verticalCenter

            text: value

            color: "#F2F6FA"

            font.pixelSize: ScreenTools.defaultFontPixelHeight
            font.bold: true

            elide: Text.ElideRight
        }
    }
}
