import QtQuick
import Quickshell
import Quickshell.Io

// Display, Omarchy clicks: left opens the display panel (brightness
// slider, night light, display settings), scroll steps the backlight.
// Hidden when there's no backlight (desktops).
BarModule {
    id: root

    property bool hasBacklight: false
    property int brightness: 50

    visible: hasBacklight
    icon: brightness < 34 ? "󰃞" : brightness < 67 ? "󰃟" : "󰃠"

    Process {
        id: readProc
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\n")[0].split(",")
                root.hasBacklight = f.length >= 4
                if (root.hasBacklight)
                    root.brightness = parseInt(f[3]) || root.brightness
            }
        }
    }
    // brightness keys change it behind our back; a cheap poll keeps the glyph honest
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readProc.running = true
    }

    function setBrightness(v) {
        brightness = Math.max(1, Math.min(100, v))
        Quickshell.execDetached(["brightnessctl", "-q", "-c", "backlight", "set", brightness + "%"])
    }

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            panel.visible = !panel.visible
    }
    onScrolled: dir => setBrightness(brightness + dir * 5)

    Popout {
        id: panel
        anchorItem: root

        IpcHandler {
            target: "display"
            function toggle(): void { panel.visible = !panel.visible }
        }
        cardWidth: 280
        cardHeight: col.implicitHeight + 2 * cardPadding
        onVisibleChanged: if (visible) readProc.running = true

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 6

            TweakSlider {
                label: "brightness"
                from: 1; to: 100
                value: root.brightness
                suffix: "%"
                applyFn: v => root.setBrightness(v)
                persistFn: v => {}
            }

            Repeater {
                model: [
                    { icon: "󱩌", label: "Night light (toggle)",
                      run: () => Quickshell.execDetached(["sh", "-c",
                          "pkill -x wlsunset || (wlsunset -t 4500 -T 6500 >/dev/null 2>&1 &)"]) },
                    { icon: "󰍹", label: "Display settings",
                      run: () => Quickshell.execDetached(["sh", "-c",
                          "command -v wdisplays >/dev/null && exec wdisplays || notify-send Display 'wdisplays is not installed'"]) }
                ]

                Rectangle {
                    id: rowRect
                    required property var modelData
                    width: parent.width
                    height: 34
                    radius: 8
                    color: ma.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 10
                        Text {
                            text: rowRect.modelData.icon
                            color: Theme.cyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                        }
                        Text {
                            text: rowRect.modelData.label
                            color: Qt.alpha(Theme.fg, 0.9)
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                        }
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { panel.visible = false; rowRect.modelData.run() }
                    }
                }
            }
        }
    }
}
