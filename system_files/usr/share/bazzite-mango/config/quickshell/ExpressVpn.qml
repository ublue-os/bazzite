import QtQuick
import Quickshell
import Quickshell.Io

// ExpressVPN — port of the omarchy-expressvpn plugin (pjgeutjens, MIT) to
// this shell. Same behaviour, this bar's look:
//   left: status panel · right: connect / disconnect · middle: refresh
// The dot beside the glyph is lit (accent) when connected and pulses
// while the connection is changing. The panel has the on/off switch, the
// Smart Location ("Fastest") row, location search (/ focuses it) with
// starred favourites kept on top, and the tunnel IP. State comes from
// VpnState.qml (vendored unchanged); favourites persist to
// ~/.config/mango/expressvpn-favorites, one region id per line.
// Hidden when expressvpnctl isn't installed.
BarModule {
    id: root

    visible: VpnState.installed
    ExpressVpnIcon {
        anchors.verticalCenter: parent.verticalCenter
        iconSize: Theme.iconSize
        iconColor: VpnState.active ? Theme.fg : Qt.alpha(Theme.fg, 0.55)
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(5 * Theme.barScale)
        height: width
        radius: width / 2
        color: VpnState.connected ? Theme.accent
             : VpnState.transitional ? Theme.fg : Qt.alpha(Theme.fg, 0.3)

        SequentialAnimation on opacity {
            running: VpnState.transitional
            loops: Animation.Infinite
            alwaysRunToEnd: true
            NumberAnimation { to: 0.3; duration: 500 }
            NumberAnimation { to: 1.0; duration: 500 }
        }
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            VpnState.toggle()
        else if (mouse.button === Qt.MiddleButton)
            VpnState.refresh()
        else
            panel.visible = !panel.visible
    }

    // same IPC surface as the plugin:
    //   qs -p ~/.config/mango/quickshell ipc call expressvpn connectTo belgium
    IpcHandler {
        target: "expressvpn"
        function open(): void { panel.visible = true }
        function close(): void { panel.visible = false }
        function toggle(): void { panel.visible = !panel.visible }
        function connect(): string { VpnState.connect(); return VpnState.statusText }
        function connectTo(region: string): string { VpnState.connectTo(region); return VpnState.statusText }
        function disconnect(): string { VpnState.disconnect(); return VpnState.statusText }
        function toggleVpn(): string { VpnState.toggle(); return VpnState.statusText }
        function refresh(): string { VpnState.refresh(); return VpnState.statusText }
        function status(): string {
            return JSON.stringify({ installed: VpnState.installed, state: VpnState.connectionState,
                active: VpnState.active, location: VpnState.locationText,
                tunnelIp: VpnState.tunnelIp, error: VpnState.lastError })
        }
    }

    // --- favourites ---
    property var favorites: []
    FileView {
        id: favFile
        path: Theme.configDir + "/expressvpn-favorites"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.favorites = text().split("\n").map(s => s.trim()).filter(s => VpnState.isSafeRegionId(s))
        onLoadFailed: root.favorites = []
    }
    function isFavorite(r) { return favorites.indexOf(r) !== -1 }
    function toggleFavorite(r) {
        const next = isFavorite(r) ? favorites.filter(x => x !== r) : favorites.concat([r])
        favorites = next
        favFile.setText(next.join("\n") + "\n")
    }

    property string query: ""
    readonly property var filtered: {
        const q = query.trim().toLowerCase().replace(/\s+/g, "-")
        const match = r => q === "" || r.toLowerCase().indexOf(q) !== -1
                        || VpnState.formatRegion(r).toLowerCase().indexOf(query.trim().toLowerCase()) !== -1
        const all = VpnState.regions.filter(r => r !== "smart" && match(r))
        return all.filter(r => isFavorite(r)).concat(all.filter(r => !isFavorite(r)))
    }

    Popout {
        id: panel
        anchorItem: root
        cardWidth: 340
        cardHeight: col.implicitHeight + 2 * cardPadding

        onVisibleChanged: {
            if (visible) {
                root.query = ""
                VpnState.refresh()
                if (VpnState.regions.length === 0) VpnState.refreshRegions()
            }
        }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            Keys.onPressed: ev => {
                if (ev.key === Qt.Key_Slash && !search.activeFocus) {
                    search.forceActiveFocus()
                    ev.accepted = true
                }
            }

            // header: glyph · status / location / IP · switch
            Item {
                width: parent.width
                height: 52

                ExpressVpnIcon {
                    id: bigIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 30
                    iconColor: VpnState.connected ? Theme.accent : Qt.alpha(Theme.fg, 0.6)
                }
                Column {
                    anchors.left: bigIcon.right
                    anchors.leftMargin: 12
                    anchors.right: sw.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: VpnState.statusText
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: VpnState.locationText
                        color: Qt.alpha(Theme.fg, 0.75)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        visible: VpnState.connected
                        text: VpnState.tunnelIp !== "" ? "IP " + VpnState.tunnelIp
                              : VpnState.loadingAddress ? "IP …" : ""
                        color: Qt.alpha(Theme.fg, 0.6)
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }
                // on/off switch
                Rectangle {
                    id: sw
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 24
                    radius: 12
                    color: VpnState.active ? Theme.accent : Qt.alpha(Theme.fg, 0.2)
                    opacity: VpnState.busy ? 0.6 : 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        y: 3
                        x: VpnState.active ? parent.width - width - 3 : 3
                        color: Theme.bg
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: VpnState.toggle()
                    }
                }
            }

            Text {
                visible: VpnState.lastError !== ""
                width: parent.width
                wrapMode: Text.Wrap
                text: VpnState.lastError
                color: Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            component LocRow: Rectangle {
                id: lr
                property string region: ""
                property string title: VpnState.formatRegion(region)
                property string glyph: ""
                property bool starrable: true
                readonly property bool current: VpnState.region === region && VpnState.active
                width: col.width
                height: 32
                radius: 8
                color: current ? Qt.alpha(Theme.accent, 0.18)
                     : lrMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"

                MouseArea {
                    id: lrMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: VpnState.connectTo(lr.region)
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: star.left
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: (lr.glyph !== "" ? lr.glyph + "  " : "") + lr.title
                    color: lr.current ? Theme.accent : Qt.alpha(Theme.fg, 0.9)
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: lr.current
                }
                Text {
                    id: star
                    visible: lr.starrable
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.isFavorite(lr.region) ? "󰓎" : "󰓒"
                    color: root.isFavorite(lr.region) ? Theme.accent : Qt.alpha(Theme.fg, 0.4)
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleFavorite(lr.region)
                    }
                }
            }

            LocRow { region: "smart"; title: "Fastest (Smart location)"; glyph: "󱐋"; starrable: false }

            // search
            Rectangle {
                width: parent.width
                height: 32
                radius: 8
                color: Qt.alpha(Theme.fg, 0.07)
                border.width: search.activeFocus ? 1 : 0
                border.color: Qt.alpha(Theme.accent, 0.6)
                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    clip: true
                    text: root.query
                    onTextChanged: root.query = text
                    Keys.onEscapePressed: { if (text !== "") text = ""; else panel.visible = false }
                    Keys.onReturnPressed: if (root.filtered.length > 0) VpnState.connectTo(root.filtered[0])
                }
                Text {
                    visible: search.text === ""
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: VpnState.loadingRegions ? "Loading locations…" : "Search locations  ( / )"
                    color: Qt.alpha(Theme.fg, 0.4)
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

            ListView {
                width: parent.width
                height: Math.min(contentHeight, 240)
                clip: true
                spacing: 2
                model: root.filtered
                boundsBehavior: Flickable.StopAtBounds
                delegate: LocRow {
                    required property var modelData
                    region: modelData
                }
            }
        }
    }
}
