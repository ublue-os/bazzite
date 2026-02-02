import QtQuick
import QtQuick.Controls
import ".."
import "../components"

Item {
    id: homePage

    property var recentGames: configManager.getRecentGames()

    Connections {
        target: configManager
        function onRecentGamesChanged() {
            homePage.recentGames = configManager.getRecentGames()
        }
    }

    Connections {
        target: gameScanner
        function onScanComplete() {
            homePage.recentGames = configManager.getRecentGames()
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.spacingXl * 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingXl
            spacing: Theme.spacingXl

            // Greeting
            Column {
                spacing: Theme.spacingXs

                Text {
                    text: configManager.userName ? "Welcome back, " + configManager.userName : "Welcome"
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    color: Theme.textPrimary
                }

                Text {
                    text: "What do you want to play?"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.textSecondary
                }
            }

            // Recently Played section
            Column {
                width: parent.width
                spacing: Theme.spacingMd
                visible: homePage.recentGames.length > 0

                Text {
                    text: "RECENTLY PLAYED"
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    font.letterSpacing: 2
                    color: Theme.textDim
                }

                // Recent games grid (up to 6 tiles)
                Flow {
                    width: parent.width
                    spacing: Theme.spacingMd

                    Repeater {
                        model: homePage.recentGames

                        GameTile {
                            gameId: modelData.id || ""
                            gameName: modelData.name || ""
                            gameSource: modelData.source || ""
                            gameArt: modelData.art || ""
                            launchCmd: findLaunchCmd(modelData.id)
                            onLaunched: homePage.recentGames = configManager.getRecentGames()
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

            // All Games section
            Column {
                width: parent.width
                spacing: Theme.spacingMd

                Text {
                    text: "ALL GAMES"
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    font.letterSpacing: 2
                    color: Theme.textDim
                }

                Text {
                    text: gameScanner.games.length + " games"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textDim
                    visible: gameScanner.games.length > 0
                }

                // Game list
                Column {
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: gameScanner.games

                        GameListItem {
                            width: parent.width
                            gameId: modelData.id || ""
                            gameName: modelData.name || ""
                            gameSource: modelData.source || ""
                            gameArt: modelData.art || ""
                            launchCmd: modelData.launch_cmd || ""
                            isHeroic: modelData.heroic || false
                            onLaunched: homePage.recentGames = configManager.getRecentGames()
                        }
                    }
                }

                // Empty state
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingMd
                    visible: gameScanner.games.length === 0 && !gameScanner.scanning

                    Item { width: 1; height: Theme.spacingXl }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No games found"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textSecondary
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Install games through Steam or Heroic Games Launcher"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textDim
                    }
                }
            }
        }
    }

    function findLaunchCmd(gameId) {
        for (var i = 0; i < gameScanner.games.length; i++) {
            if (gameScanner.games[i].id === gameId) {
                return gameScanner.games[i].launch_cmd || ""
            }
        }
        return ""
    }
}
