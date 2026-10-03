import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Volume popup (right-click the Volume module): a slider for the default
// sink, then the sink picker — every audio output PipeWire knows about,
// click to make it the default (headphones vs speakers vs HDMI, the
// daily case) — and a pavucontrol row for everything else (per-app
// routing, profiles). State comes straight from the Pipewire service,
// so switching outputs elsewhere shows here too.
Popout {
    id: root

    cardWidth: 300
    cardHeight: col.implicitHeight + 2 * cardPadding

    // scriptable open/close: qs -p ~/.config/mango/quickshell ipc call volume toggle
    IpcHandler {
        target: "volume"
        function toggle(): void { root.visible = !root.visible }
    }

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    // bound so their audio state (volume, mute) stays live while listed
    PwObjectTracker { objects: root.sinks }

    readonly property var current: Pipewire.defaultAudioSink
    readonly property var audio: current?.audio ?? null

    function sinkLabel(n) {
        return n.description || n.nickname || n.name
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

        TweakSlider {
            label: root.audio?.muted ? "volume (muted)" : "volume"
            from: 0; to: 100
            value: root.audio ? Math.round(root.audio.volume * 100) : 0
            suffix: "%"
            applyFn: v => {
                if (!root.audio) return
                root.audio.muted = false
                root.audio.volume = v / 100
            }
            persistFn: v => {}   // PipeWire remembers
        }

        SectionLabel { text: "Output" }

        Repeater {
            model: root.sinks

            Rectangle {
                id: row
                required property var modelData
                readonly property bool active: modelData === root.current

                width: parent.width
                height: 34
                radius: 8
                color: active ? Qt.alpha(Theme.accent, 0.18)
                     : rowMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"

                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.active ? "󰄬" : "󰝚"
                        color: row.active ? Theme.accent : Theme.cyan
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.cardWidth - 2 * root.cardPadding - 44
                        text: root.sinkLabel(row.modelData)
                        elide: Text.ElideRight
                        color: row.active ? Theme.fg : Qt.alpha(Theme.fg, 0.9)
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: row.active
                    }
                }

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Pipewire.preferredDefaultAudioSink = row.modelData
                }
            }
        }

        Text {
            visible: root.sinks.length === 0
            text: "no outputs"
            color: Qt.alpha(Theme.fg, 0.5)
            font.family: Theme.fontFamily
            font.pixelSize: 12
            leftPadding: 10
        }

        Rectangle {
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: Qt.alpha(Theme.fg, 0.15)
        }

        Rectangle {
            width: parent.width
            height: 34
            radius: 8
            color: mixMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"

            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰕾"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Mixer (pavucontrol)"
                    color: Qt.alpha(Theme.fg, 0.9)
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

            MouseArea {
                id: mixMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.visible = false
                    Quickshell.execDetached(["pavucontrol"])
                }
            }
        }
    }
}
