import QtQuick
import Quickshell.Services.Mpris

// Now-playing popup (right-click the Media module): album art, full
// track info, click-to-seek bar, transport buttons, and a player
// switcher when more than one MPRIS player is up. All state comes from
// the Media module (passed as `media`) so the two never disagree.
Popout {
    id: root

    required property var media
    readonly property var player: media.player

    cardWidth: 320
    cardHeight: col.implicitHeight + 2 * cardPadding

    component TransportButton: Text {
        property bool allowed: true
        signal tapped()
        color: allowed
            ? (tbMa.containsMouse ? Theme.accent : Qt.alpha(Theme.fg, 0.85))
            : Qt.alpha(Theme.fg, 0.25)
        font.family: Theme.fontFamily
        Behavior on color { ColorAnimation { duration: 120 } }
        MouseArea {
            id: tbMa
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            onClicked: if (parent.allowed) parent.tapped()
        }
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        Row {
            width: parent.width
            spacing: 12

            Rectangle {
                id: artFrame
                width: 84
                height: 84
                radius: 8
                color: Qt.alpha(Theme.fg, 0.06)
                clip: true

                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }
                Text {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    text: "󰝚"
                    color: Qt.alpha(Theme.fg, 0.3)
                    font.family: Theme.fontFamily
                    font.pixelSize: 30
                }
            }

            Column {
                width: parent.width - artFrame.width - parent.spacing
                anchors.verticalCenter: artFrame.verticalCenter
                spacing: 3

                Text {
                    width: parent.width
                    text: root.player?.trackTitle ?? ""
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }
                Text {
                    width: parent.width
                    text: root.media.artistText
                    color: Qt.alpha(Theme.fg, 0.75)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    visible: (root.player?.trackAlbum ?? "") !== ""
                    text: root.player?.trackAlbum ?? ""
                    color: Qt.alpha(Theme.fg, 0.5)
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: root.player?.identity ?? ""
                    color: Qt.alpha(Theme.accent, 0.7)
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }
        }

        // click-to-seek; hidden for streams that report no length
        Item {
            width: parent.width
            height: 24
            visible: root.media.timed

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                text: root.media.fmt(root.media.pos)
                color: Qt.alpha(Theme.fg, 0.6)
                font.family: Theme.fontFamily
                font.pixelSize: 9
            }
            Text {
                anchors.right: parent.right
                anchors.top: parent.top
                text: root.media.fmt(root.media.len)
                color: Qt.alpha(Theme.fg, 0.6)
                font.family: Theme.fontFamily
                font.pixelSize: 9
            }

            Rectangle {
                id: seekTrack
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                height: 4
                radius: 2
                color: Qt.alpha(Theme.fg, 0.12)

                Rectangle {
                    width: Math.min(root.media.pos / root.media.len, 1) * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accent
                }
            }
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: 10
                enabled: root.player?.canSeek ?? false
                onClicked: m => {
                    const frac = Math.min(Math.max(m.x / width, 0), 1)
                    root.player.position = frac * root.media.len
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            TransportButton {
                text: "󰒮"
                font.pixelSize: 18
                allowed: root.player?.canGoPrevious ?? false
                onTapped: root.player.previous()
            }
            TransportButton {
                text: root.media.playing ? "󰏤" : "󰐊"
                font.pixelSize: 24
                allowed: root.player?.canTogglePlaying ?? false
                onTapped: root.player.togglePlaying()
            }
            TransportButton {
                text: "󰒭"
                font.pixelSize: 18
                allowed: root.player?.canGoNext ?? false
                onTapped: root.player.next()
            }
        }

        // other players, only when there's a choice to make
        Repeater {
            model: Mpris.players.values.length > 1 ? Mpris.players.values : []

            Rectangle {
                id: pRow
                required property var modelData
                readonly property bool current: modelData === root.player

                width: col.width
                height: 26
                radius: 6
                color: current ? Theme.selbg
                     : pMa.containsMouse ? Qt.alpha(Theme.fg, 0.12)
                     : Qt.alpha(Theme.fg, 0.04)

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    text: (pRow.modelData.playbackState === MprisPlaybackState.Playing
                           ? "󰐊 " : "󰏤 ") + pRow.modelData.identity
                    color: pRow.current ? Theme.selfg : Qt.alpha(Theme.fg, 0.8)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
                MouseArea {
                    id: pMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.media.manual = pRow.modelData
                }
            }
        }
    }
}
