import QtQuick
import QtQuick.Controls
import ".."
import "../components"

Item {
    id: libraryPage

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingXl
        spacing: Theme.spacingLg

        // Header
        Row {
            width: parent.width
            spacing: Theme.spacingMd

            Text {
                text: "Library"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                text: gameScanner.games.length + " games"
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textDim
            }

            Item { width: parent.width - 400; height: 1 }

            // Filter chips
            Row {
                anchors.bottom: parent.bottom
                spacing: Theme.spacingSm

                Repeater {
                    model: ["All", "Steam", "Epic", "Xbox", "Native"]

                    Rectangle {
                        width: filterText.width + Theme.spacingMd * 2
                        height: 32
                        radius: 16
                        color: libraryPage.activeFilter === modelData ?
                               Theme.accentBlue :
                               (filterMouse.containsMouse ? Theme.bgCardHover : Theme.bgCard)
                        border.color: libraryPage.activeFilter === modelData ? Theme.accentGlow : Theme.borderSubtle
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            id: filterText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: libraryPage.activeFilter === modelData
                            color: libraryPage.activeFilter === modelData ? Theme.textPrimary : Theme.textSecondary
                        }

                        MouseArea {
                            id: filterMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                libraryPage.activeFilter = modelData
                                audioManager.play("navigate")
                            }
                        }
                    }
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.borderSubtle
        }

        // Game list
        ListView {
            id: gameList
            width: parent.width
            height: parent.height - 100
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: 2

            model: filteredGames

            delegate: GameListItem {
                width: gameList.width
                gameId: modelData.id || ""
                gameName: modelData.name || ""
                gameSource: modelData.source || ""
                gameArt: modelData.art || ""
                launchCmd: modelData.launch_cmd || ""
                isHeroic: modelData.heroic || false
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: libraryPage.activeFilter === "All" ?
                      "No games found" :
                      "No " + libraryPage.activeFilter + " games found"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textSecondary
                visible: gameList.count === 0
            }
        }
    }

    property string activeFilter: "All"
    property var filteredGames: {
        var all = gameScanner.games
        if (activeFilter === "All") return all
        var result = []
        for (var i = 0; i < all.length; i++) {
            if (all[i].source === activeFilter) {
                result.push(all[i])
            }
        }
        return result
    }
}
