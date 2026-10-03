import QtQuick
import Quickshell
import Quickshell.Io

// Command menu: quick actions that have NO other bar surface — power
// profile, keep-awake, mic mute, night light, bluetooth power, brightness
// (laptops), pomodoro, updates, screen off, power menu. The rule: the bar shows
// state, this menu holds actions that would otherwise each need a whole
// new bar widget. Stateful glanceable things (volume, network, DND,
// media) keep their own modules and never appear here.
// Quick-settings layout: toggle pills in a 2-col grid (filled = on,
// right-click = the full external tool where one exists), sliders under
// them, then launcher rows. Toggles stay open so the state change is
// visible; launchers close. A running pomodoro puts its countdown on
// this pill itself — glanceable without a dedicated module.
BarModule {
    id: root

    // Omarchy-style indicators slot: on the bar it only shows the modes
    // that are on (keep awake, night light) and takes no space otherwise;
    // click = the quick-settings menu (also Super+Shift+m). Pomodoro is
    // gnome-pomodoro now (Pomodoro.qml).
    icon: (caffeine ? "󰅶" : "") + (caffeine && nightLight ? " " : "") + (nightLight ? "󱩌" : "")
    visible: icon !== ""
    onClicked: menu.visible = !menu.visible

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: stateProc.running = true
    }

    // polled on every open, all read back from the system so a bar
    // restart can't desync the pills: keep-awake is a systemd-inhibit
    // holder process, night light is a running wlsunset
    property string profile: "balanced"
    property bool caffeine: false
    property bool nightLight: false
    property bool hasBacklight: false
    property int brightness: 50

    Process {
        id: stateProc
        // one printf, one guaranteed line per field — a missing tool
        // yields an empty line instead of shifting the indices below
        command: ["sh", "-c",
            "printf '%s\\n' " +
            "\"$(powerprofilesctl get 2>/dev/null)\" " +
            "\"$(brightnessctl -m -c backlight 2>/dev/null | head -n1)\" " +
            "\"$(pgrep -f '[w]hy=quickshell-caffeine' >/dev/null && echo awake)\" " +
            "\"$(pgrep -x wlsunset >/dev/null && echo night)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                if (root.profileOrder.indexOf(lines[0]) >= 0)
                    root.profile = lines[0]
                const bl = (lines[1] ?? "").split(",")
                root.hasBacklight = bl.length >= 4
                if (root.hasBacklight)
                    root.brightness = parseInt(bl[3]) || root.brightness
                root.caffeine = lines[2] === "awake"
                root.nightLight = lines[3] === "night"
            }
        }
    }

    readonly property var profileOrder: ["performance", "balanced", "power-saver"]
    readonly property var profileIcons: ({ performance: "󰓅", balanced: "󰾅", "power-saver": "󰾆" })

    function cycleProfile() {
        const next = profileOrder[(profileOrder.indexOf(profile) + 1) % profileOrder.length]
        Quickshell.execDetached(["powerprofilesctl", "set", next])
        profile = next
    }

    component CommandRow: Rectangle {
        id: rowRect
        required property var modelData

        width: parent.width
        height: 34
        radius: 8
        color: rowMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rowRect.modelData.icon
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: rowRect.modelData.label
                color: Qt.alpha(Theme.fg, 0.9)
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                menu.visible = false
                rowRect.modelData.run()
            }
        }
    }

    // history home while the Bell is hidden (it only shows during DND)
    NotifyPopup {
        id: notifHistory
        anchorItem: root
    }

    Popout {
        id: menu
        anchorItem: root
        cardWidth: 270
        cardHeight: col.implicitHeight + 2 * cardPadding

        onVisibleChanged: if (visible) stateProc.running = true

        // scriptable open/close: qs -p ~/.config/suckless/quickshell ipc call commands toggle
        IpcHandler {
            target: "commands"
            function toggle(): void { menu.visible = !menu.visible }
        }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 6

            Grid {
                width: parent.width
                columns: 2
                spacing: 6

                Repeater {
                    model: [
                        { icon: root.profileIcons[root.profile],
                          label: root.profile,
                          active: root.profile !== "balanced",
                          run: () => root.cycleProfile() },
                        { icon: "󰅶", label: "Keep awake",
                          active: root.caffeine,
                          run: () => {
                              root.caffeine = !root.caffeine
                              Quickshell.execDetached(["sh", "-c", root.caffeine
                                  ? "systemd-inhibit --what=idle --who=quickshell --why=quickshell-caffeine sleep infinity >/dev/null 2>&1 &"
                                  : "pkill -f '[w]hy=quickshell-caffeine'"])
                          } },
                        { icon: Sys.micMuted ? "󰍭" : "󰍬",
                          label: Sys.micMuted ? "Muted" : "Mic",
                          active: Sys.micMuted, alert: Sys.micMuted,
                          alt: ["pavucontrol", "-t", "4"],
                          run: () => Sys.toggleMicMute() },
                        { icon: "󱩌", label: "Night light",
                          active: root.nightLight,
                          run: () => {
                              root.nightLight = !root.nightLight
                              Quickshell.execDetached(["sh", "-c", root.nightLight
                                  ? "command -v wlsunset >/dev/null && (wlsunset -t 4500 -T 6500 >/dev/null 2>&1 &) || notify-send -a quickshell 'Night light' 'wlsunset is not installed'"
                                  : "pkill -x wlsunset"])
                          } },
                        { icon: Sys.dndOn ? "󰂛" : "󰂚",
                          label: "DND",
                          active: Sys.dndOn, alert: Sys.dndOn,
                          altFn: () => {
                              menu.visible = false
                              notifHistory.visible = true
                          },
                          run: () => Sys.toggleDnd() }
                    ]
                    TogglePill { closeFn: () => menu.visible = false }
                }
            }

            TweakSlider {
                visible: root.hasBacklight
                label: "brightness"
                from: 5; to: 100
                value: root.brightness
                suffix: "%"
                applyFn: v => Quickshell.execDetached(
                    ["brightnessctl", "-c", "backlight", "set", v + "%"])
                persistFn: v => {}   // hardware remembers; nothing to persist
            }

            Rectangle {
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: Qt.alpha(Theme.fg, 0.15)
            }

            Repeater {
                model: [
                    { icon: "󰚰", label: "Check updates",
                      run: () => Quickshell.execDetached(["kitty", "-e", "sh", "-c",
                          "rpm-ostree upgrade --check; flatpak remote-ls --updates; " +
                          "printf '\\ndone - press enter to close '; read _"]) },
                    { icon: "󰌌", label: "Keybindings",
                      run: () => Quickshell.execDetached([Theme.configDir + "/scripts/help"]) },
                    { icon: "󰑓", label: "Restart bar",
                      run: () => Quickshell.execDetached([Theme.configDir + "/scripts/bar", "restart"]) },
                    { icon: "󰌢", label: "Screen off",
                      run: () => Quickshell.execDetached([Theme.configDir + "/scripts/screen-off"]) },
                    { icon: "󰐥", label: "Power menu",
                      run: () => Quickshell.execDetached([Theme.configDir + "/scripts/power"]) }
                ]
                CommandRow {}
            }
        }
    }
}
