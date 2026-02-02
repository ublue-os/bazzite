import QtQuick
import ".."

Item {
    id: showsPage

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingLg

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "▶"
            font.pixelSize: 72
            color: Theme.textDim
            opacity: 0.4
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Shows & Media"
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            color: Theme.textPrimary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Coming soon"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textSecondary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Streaming apps and media content will be available here"
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textDim
        }
    }
}
