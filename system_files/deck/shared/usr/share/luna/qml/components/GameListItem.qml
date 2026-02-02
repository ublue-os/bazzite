import QtQuick
import ".."

Rectangle {
    id: listItem
    width: parent ? parent.width : 400
    height: Theme.listItemHeight
    color: isHovered ? Theme.bgCardHover : "transparent"
    radius: Theme.borderRadiusSm

    property string gameId: ""
    property string gameName: ""
    property string gameSource: ""
    property string gameArt: ""
    property string launchCmd: ""
    property bool isHeroic: false
    property bool isHovered: mouseArea.containsMouse

    signal launched()

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingSm
        anchors.rightMargin: Theme.spacingSm
        spacing: Theme.spacingMd

        // Thumbnail
        Rectangle {
            width: 80
            height: 45
            anchors.verticalCenter: parent.verticalCenter
            radius: 6
            color: Theme.bgCard
            clip: true

            Image {
                anchors.fill: parent
                source: listItem.gameArt ? (listItem.gameArt.startsWith("http") ? listItem.gameArt : "file://" + listItem.gameArt) : ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
                smooth: true
            }

            // Placeholder icon
            Text {
                anchors.centerIn: parent
                text: "🎮"
                font.pixelSize: 18
                visible: !listItem.gameArt
            }
        }

        // Game name
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 180
            text: listItem.gameName
            font.pixelSize: Theme.fontSizeNormal
            color: listItem.isHovered ? Theme.textPrimary : Theme.textSecondary
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }

        // Source badge
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: srcText.width + Theme.spacingSm * 2
            height: 22
            radius: 4
            color: Theme.sourceBadgeColor(listItem.gameSource)

            Text {
                id: srcText
                anchors.centerIn: parent
                text: listItem.gameSource
                font.pixelSize: 10
                font.bold: true
                color: Theme.textPrimary
            }
        }
    }

    // Focus indicator left bar
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: listItem.isHovered ? parent.height * 0.6 : 0
        radius: 2
        color: Theme.accentBlue

        Behavior on height {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: audioManager.play("navigate")
        onClicked: {
            audioManager.play("select")
            gameLauncher.launch(listItem.gameId, listItem.gameName, listItem.gameSource, listItem.gameArt, listItem.launchCmd)
            listItem.launched()
        }
    }
}
