import QtQuick
import ".."

Item {
    id: tile
    width: Theme.tileWidth
    height: Theme.tileHeight

    property string gameId: ""
    property string gameName: ""
    property string gameSource: ""
    property string gameArt: ""
    property string launchCmd: ""
    property bool isHeroic: false
    property bool isFocused: mouseArea.containsMouse

    signal launched()

    // Card background
    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.borderRadius
        color: Theme.bgCard
        clip: true

        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }

        // Game art
        Image {
            id: artImage
            anchors.fill: parent
            source: tile.gameArt ? (tile.gameArt.startsWith("http") ? tile.gameArt : "file://" + tile.gameArt) : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            smooth: true
        }

        // Placeholder when no art
        Rectangle {
            anchors.fill: parent
            visible: !artImage.visible
            color: Theme.bgCard
            radius: Theme.borderRadius

            Text {
                anchors.centerIn: parent
                text: tile.gameName
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textSecondary
                width: parent.width - Theme.spacingLg * 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Bottom gradient overlay for name
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * 0.45
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85) }
            }
        }

        // Game name
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacingSm
            text: tile.gameName
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            color: Theme.textPrimary
            elide: Text.ElideRight
        }

        // Source badge
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Theme.spacingSm
            width: badgeText.width + Theme.spacingSm * 2
            height: 20
            radius: 4
            color: Theme.sourceBadgeColor(tile.gameSource)
            opacity: 0.9

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: tile.gameSource
                font.pixelSize: 10
                font.bold: true
                color: Theme.textPrimary
            }
        }
    }

    // Focus glow halo
    Rectangle {
        anchors.fill: card
        anchors.margins: -3
        radius: Theme.borderRadius + 3
        color: "transparent"
        border.color: Theme.accentGlow
        border.width: tile.isFocused ? 2 : 0
        opacity: tile.isFocused ? 0.6 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast }
        }
        Behavior on border.width {
            NumberAnimation { duration: Theme.animFast }
        }
    }

    // Scale on hover
    scale: isFocused ? 1.04 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: audioManager.play("navigate")
        onClicked: {
            audioManager.play("select")
            gameLauncher.launch(tile.gameId, tile.gameName, tile.gameSource, tile.gameArt, tile.launchCmd)
            tile.launched()
        }
    }
}
