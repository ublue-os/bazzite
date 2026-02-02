import QtQuick
import ".."

Item {
    id: storesPage

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingXl

        Text {
            text: "Stores"
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            color: Theme.textPrimary
        }

        Text {
            text: "Launch your game stores"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textSecondary
        }

        Item { width: 1; height: Theme.spacingMd }

        // Store buttons
        Row {
            spacing: Theme.spacingLg
            anchors.horizontalCenter: parent.horizontalCenter

            // Steam Store
            StoreButton {
                title: "Steam"
                subtitle: "Store & Community"
                iconText: "🎮"
                bgColor: "#1b2838"
                hoverColor: "#2a475e"
                onClicked: {
                    audioManager.play("select")
                    Qt.openUrlExternally("steam://store")
                }
            }

            // Epic Games
            StoreButton {
                title: "Epic Games"
                subtitle: "via Heroic Launcher"
                iconText: "🏔"
                bgColor: "#2a2a2a"
                hoverColor: "#3a3a3a"
                onClicked: {
                    audioManager.play("select")
                    launchHeroic()
                }
            }

            // Xbox / Game Pass
            StoreButton {
                title: "Xbox"
                subtitle: "via Heroic Launcher"
                iconText: "🎯"
                bgColor: "#107c10"
                hoverColor: "#1a9c1a"
                onClicked: {
                    audioManager.play("select")
                    launchHeroic()
                }
            }
        }
    }

    function launchHeroic() {
        try {
            Qt.openUrlExternally("heroic://")
        } catch (e) {
            // Fallback: try flatpak
        }
    }

    component StoreButton: Rectangle {
        id: storeBtn
        width: 240
        height: 280
        radius: Theme.borderRadius
        color: mouseArea.containsMouse ? hoverColor : bgColor

        property string title: ""
        property string subtitle: ""
        property string iconText: ""
        property color bgColor: Theme.bgCard
        property color hoverColor: Theme.bgCardHover

        signal clicked()

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        // Focus glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: Theme.borderRadius + 3
            color: "transparent"
            border.color: Theme.accentGlow
            border.width: mouseArea.containsMouse ? 2 : 0
            opacity: mouseArea.containsMouse ? 0.5 : 0

            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }

        scale: mouseArea.containsMouse ? 1.03 : 1.0
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingLg

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: storeBtn.iconText
                font.pixelSize: 64
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingXs

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: storeBtn.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: storeBtn.subtitle
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: audioManager.play("navigate")
            onClicked: storeBtn.clicked()
        }
    }
}
