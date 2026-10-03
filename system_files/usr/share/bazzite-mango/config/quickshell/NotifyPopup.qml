import QtQuick
import Quickshell
import Quickshell.Io

// Recent notifications under the bell (right-click): vertical list from
// dunst's history — urgency stripes, hover-dismiss, clear-all. DND itself
// stays on the bell's left click.
Popout {
    id: root

    cardWidth: 340
    cardHeight: Math.min(64 + list.contentHeight, 430)

    property var notifs: []
    property real uptimeSecs: 0

    onVisibleChanged: if (visible) refresh()

    function refresh() {
        uptimeProc.running = true
        histProc.running = false
        histProc.running = true
    }

    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]
        stdout: SplitParser {
            onRead: line => root.uptimeSecs = parseFloat(line.split(" ")[0]) || 0
        }
    }

    property string _hist: ""
    Process {
        id: histProc
        command: ["dunstctl", "history"]
        stdout: SplitParser {
            onRead: line => root._hist += line
        }
        onRunningChanged: {
            if (running) root._hist = ""
            else root.parseHistory(root._hist)
        }
    }

    function parseHistory(txt) {
        try {
            const j = JSON.parse(txt)
            const arr = (j.data && j.data[0]) ? j.data[0] : []
            const out = []
            for (const n of arr) {
                out.push({
                    nid: n.id?.data ?? 0,
                    app: n.appname?.data ?? "",
                    summary: n.summary?.data ?? "",
                    body: String(n.body?.data ?? "").replace(/<[^>]*>/g, ""),
                    urgency: n.urgency?.data ?? "NORMAL",
                    ts: (n.timestamp?.data ?? 0) / 1000000
                })
            }
            notifs = out.slice(0, 12)
        } catch (e) {
            notifs = []
        }
    }

    function age(ts) {
        const d = Math.max(0, uptimeSecs - ts)
        if (d < 60) return "now"
        if (d < 3600) return Math.floor(d / 60) + "m"
        if (d < 86400) return Math.floor(d / 3600) + "h"
        return Math.floor(d / 86400) + "d"
    }

    Timer {
        id: reHist
        interval: 250
        onTriggered: {
            histProc.running = false
            histProc.running = true
        }
    }

    // header: title + clear all
    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 22

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Notifications"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: root.notifs.length > 0
            text: "clear all"
            color: clearMa.containsMouse ? Theme.fg : Qt.alpha(Theme.fg, 0.5)
            font.family: Theme.fontFamily
            font.pixelSize: 11
            MouseArea {
                id: clearMa
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                onClicked: {
                    Quickshell.execDetached(["dunstctl", "history-clear"])
                    reHist.restart()
                }
            }
        }
    }

    Flickable {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        contentHeight: notifCol.implicitHeight
        clip: true

        Column {
            id: notifCol
            width: parent.width
            spacing: 6

            Text {
                visible: root.notifs.length === 0
                text: "nothing missed"
                color: Qt.alpha(Theme.fg, 0.35)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                topPadding: 6
            }

            Repeater {
                model: root.notifs

                Rectangle {
                    id: ncard
                    required property var modelData
                    width: notifCol.width
                    height: content.implicitHeight + 14
                    radius: 8
                    color: Qt.alpha(Theme.fg, cardMa.containsMouse ? 0.1 : 0.06)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: 3
                        radius: 1.5
                        color: ncard.modelData.urgency === "CRITICAL" ? Theme.red
                             : ncard.modelData.urgency === "LOW" ? Qt.alpha(Theme.fg, 0.25)
                             : Theme.accent
                    }

                    Column {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 15
                        anchors.rightMargin: 9
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Item {
                            width: parent.width
                            height: 14

                            Text {
                                anchors.left: parent.left
                                anchors.right: meta.left
                                anchors.rightMargin: 6
                                text: ncard.modelData.summary
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Row {
                                id: meta
                                anchors.right: parent.right
                                spacing: 8

                                Text {
                                    text: ncard.modelData.app + " · " + root.age(ncard.modelData.ts)
                                    color: Qt.alpha(Theme.fg, 0.4)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                                Text {
                                    visible: cardMa.containsMouse
                                    text: "󰅖"
                                    color: disMa.containsMouse ? Theme.red : Qt.alpha(Theme.fg, 0.5)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    MouseArea {
                                        id: disMa
                                        anchors.fill: parent
                                        anchors.margins: -5
                                        hoverEnabled: true
                                        onClicked: {
                                            Quickshell.execDetached(["dunstctl", "history-rm",
                                                String(ncard.modelData.nid)])
                                            reHist.restart()
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            visible: ncard.modelData.body !== ""
                            text: ncard.modelData.body
                            color: Qt.alpha(Theme.fg, 0.65)
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: cardMa
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }
}
