import QtQuick
import Quickshell
import Quickshell.Io

// Weather panel under the weather indicator, Omarchy style:
//   forecast — current condition, feels like, wind, three days
//   location — type a place, pick a suggestion (Open-Meteo geocoding, no
//              key); stored as "lat,lon" in weather-location, or cleared
//              for automatic-by-IP (which follows a VPN exit node)
//   units    — Auto / °C / °F, stored in weather-units
// Weather.qml watches both files and refetches the moment they change.
Popout {
    id: root

    property string condition: ""
    property string feels: ""
    property string wind: ""
    property string place: ""
    property var days: []   // {label, glyph, hi, lo, rain}

    cardWidth: 330
    cardHeight: col.implicitHeight + 2 * cardPadding

    // scriptable: qs -p ~/.config/mango/quickshell ipc call weather toggle
    IpcHandler {
        target: "weather"
        function toggle(): void { root.visible = !root.visible }
    }

    readonly property string locFile: Theme.configDir + "/weather-location"
    readonly property string unitsFile: Theme.configDir + "/weather-units"

    property string pinned: ""      // weather-location contents ("" = auto)
    property string pinnedName: ""  // display name saved alongside
    property string units: ""       // "", "c", "f"
    property bool editing: false
    property var suggestions: []    // {name, detail, lat, lon}

    FileView {
        path: root.locFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.pinned = text().trim()
        onLoadFailed: root.pinned = ""
    }
    FileView {
        path: root.locFile + ".name"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.pinnedName = text().trim()
        onLoadFailed: root.pinnedName = ""
    }
    FileView {
        path: root.unitsFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.units = text().trim().toLowerCase()
        onLoadFailed: root.units = ""
    }

    onVisibleChanged: if (!visible) { editing = false; suggestions = [] }

    function setUnits(u) {
        units = u
        Quickshell.execDetached(["sh", "-c", u === ""
            ? "rm -f \"$1\"" : "printf '%s\\n' \"$2\" > \"$1\"", "sh", unitsFile, u])
    }
    function setLocation(value, name) {
        editing = false
        suggestions = []
        Quickshell.execDetached(["sh", "-c", value === ""
            ? "rm -f \"$1\" \"$1.name\""
            : "printf '%s\\n' \"$3\" > \"$1.name\"; printf '%s\\n' \"$2\" > \"$1\"",
            "sh", locFile, value, name])
    }

    Process {
        id: geo
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const r = JSON.parse(text).results ?? []
                    root.suggestions = r.map(x => ({
                        name: x.name,
                        detail: [x.admin1, x.country].filter(Boolean).join(", "),
                        lat: Number(x.latitude).toFixed(4),
                        lon: Number(x.longitude).toFixed(4)
                    }))
                } catch (e) {
                    root.suggestions = []
                }
            }
        }
    }
    Timer {
        id: geoDebounce
        interval: 300
        onTriggered: {
            const q = locInput.text.trim()
            if (q.length < 2) { root.suggestions = []; return }
            geo.running = false
            geo.command = ["curl", "-sf", "-m", "8", "-G",
                "https://geocoding-api.open-meteo.com/v1/search",
                "--data-urlencode", "name=" + q, "-d", "count=6", "-d", "language=en"]
            geo.running = true
        }
    }

    component SectionLabel: Text {
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: true
        topPadding: 6
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        // where this forecast is for — also the tell when a VPN exit node
        // is fooling the IP geolocation
        Text {
            width: parent.width
            visible: root.place !== ""
            text: "󰍎 " + root.place
            color: Qt.alpha(Theme.fg, 0.5)
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        // current condition · feels like · wind
        Text {
            width: parent.width
            text: root.condition
                + (root.feels !== "" ? "  ·  feels " + root.feels + "°" : "")
                + (root.wind !== "" ? "  ·  󰖝 " + root.wind : "")
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
        }

        Row {
            width: parent.width
            topPadding: 6

            Repeater {
                model: root.days

                Column {
                    id: day
                    required property var modelData
                    width: col.width / Math.max(root.days.length, 1)
                    spacing: 5

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.modelData.label
                        color: Qt.alpha(Theme.fg, 0.55)
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.modelData.glyph
                        color: Theme.yellow
                        font.family: Theme.fontFamily
                        font.pixelSize: 22
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.modelData.hi + "° / " + day.modelData.lo + "°"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.modelData.rain >= 30 ? "󰖌 " + day.modelData.rain + "%" : " "
                        color: Theme.cyan
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }

        Rectangle {
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: Qt.alpha(Theme.fg, 0.15)
        }

        SectionLabel { text: "Location" }

        // current location row / search field
        Rectangle {
            width: parent.width
            height: 32
            radius: 8
            color: Qt.alpha(Theme.fg, 0.07)
            border.width: root.editing ? 1 : 0
            border.color: Qt.alpha(Theme.accent, 0.6)

            Text {
                visible: !root.editing
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: editHint.left
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                text: root.pinned === "" ? "󰆤  Automatic (by IP)"
                    : "󰍎  " + (root.pinnedName !== "" ? root.pinnedName : root.pinned)
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
            Text {
                id: editHint
                visible: !root.editing
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "change"
                color: Qt.alpha(Theme.fg, 0.45)
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
            MouseArea {
                visible: !root.editing
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.editing = true
                    locInput.text = ""
                    locInput.forceActiveFocus()
                }
            }

            TextInput {
                id: locInput
                visible: root.editing
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 13
                clip: true
                onTextChanged: geoDebounce.restart()
                Keys.onReturnPressed: {
                    if (root.suggestions.length > 0) {
                        const s = root.suggestions[0]
                        root.setLocation(s.lat + "," + s.lon, s.name + (s.detail ? ", " + s.detail : ""))
                    } else if (text.trim() !== "")
                        root.setLocation(text.trim(), text.trim())
                }
                Keys.onEscapePressed: { root.editing = false; root.suggestions = [] }
            }
            Text {
                visible: root.editing && locInput.text === ""
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Search a city…"
                color: Qt.alpha(Theme.fg, 0.4)
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
        }

        component PickRow: Rectangle {
            id: pr
            property string glyph: ""
            property string title: ""
            property string detail: ""
            signal picked()
            width: col.width
            height: 30
            radius: 8
            color: prm.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: pr.glyph + "  " + pr.title + (pr.detail !== "" ? "  ·  " + pr.detail : "")
                color: Qt.alpha(Theme.fg, 0.9)
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
            MouseArea {
                id: prm
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: pr.picked()
            }
        }

        PickRow {
            visible: root.editing
            glyph: "󰆤"
            title: "Automatic (by IP)"
            onPicked: root.setLocation("", "")
        }
        Repeater {
            model: root.editing ? root.suggestions : []
            PickRow {
                required property var modelData
                glyph: "󰍎"
                title: modelData.name
                detail: modelData.detail
                onPicked: root.setLocation(modelData.lat + "," + modelData.lon,
                                           modelData.name + (modelData.detail ? ", " + modelData.detail : ""))
            }
        }

        SectionLabel { text: "Units" }

        Row {
            width: parent.width
            spacing: 6
            Repeater {
                model: [{ v: "", label: "Auto" }, { v: "c", label: "°C" }, { v: "f", label: "°F" }]
                Rectangle {
                    id: up
                    required property var modelData
                    readonly property bool active: root.units === modelData.v
                    width: (col.width - 12) / 3
                    height: 30
                    radius: 8
                    color: active ? Qt.alpha(Theme.accent, 0.22)
                         : um.containsMouse ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.fg, 0.05)
                    Text {
                        anchors.centerIn: parent
                        text: up.modelData.label
                        color: up.active ? Theme.accent : Qt.alpha(Theme.fg, 0.85)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: up.active
                    }
                    MouseArea {
                        id: um
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setUnits(up.modelData.v)
                    }
                }
            }
        }
    }
}
