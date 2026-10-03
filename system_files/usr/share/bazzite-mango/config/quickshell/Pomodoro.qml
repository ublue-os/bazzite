import QtQuick
import Quickshell
import Quickshell.Io

// gnome-pomodoro on the bar, drawn in the bar's own colors (a glyph, not
// the app's red tomato). Reads the org.gnome.Pomodoro D-Bus service —
// only once it's already running, so the poll never auto-starts it.
//   left: start, or pause/resume a running timer
//   middle: stop · right: open the gnome-pomodoro window (settings, stats)
// While a session runs: countdown label + an accent progress underline;
// breaks swap the glyph to a coffee cup; paused dims it.
BarModule {
    id: root

    property string pstate: "off"       // off | null | pomodoro | short-break | long-break
    property bool paused: false
    property real duration: 0
    property real elapsed: 0
    property real polledAt: 0
    property real now: 0

    readonly property bool active: pstate === "pomodoro" || pstate.endsWith("break")
    readonly property real remaining: Math.max(0, duration - elapsed - (paused ? 0 : (now - polledAt) / 1000))

    icon: pstate.endsWith("break") ? "󰅶" : "󰔛"
    iconColor: paused ? Qt.alpha(Theme.fg, 0.45) : Theme.fg
    label: active ? fmt(remaining) : ""
    labelColor: paused ? Qt.alpha(Theme.fg, 0.45) : Theme.fg
    progress: active && duration > 0 ? remaining / duration : -1

    function fmt(s) {
        s = Math.ceil(s)
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0")
    }

    Process {
        id: poll
        command: ["sh", "-c",
            "gdbus call --session -d org.freedesktop.DBus -o /org/freedesktop/DBus " +
            "-m org.freedesktop.DBus.NameHasOwner org.gnome.Pomodoro 2>/dev/null | grep -q true || exit 3; " +
            "gdbus call --session -d org.gnome.Pomodoro -o /org/gnome/Pomodoro " +
            "-m org.freedesktop.DBus.Properties.GetAll org.gnome.Pomodoro"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text
                const num = k => { const m = t.match(new RegExp("'" + k + "': <([0-9.]+)>")); return m ? parseFloat(m[1]) : 0 }
                const m = t.match(/'State': <'([a-z-]+)'>/)
                if (!m) return
                root.pstate = m[1]
                root.paused = /'IsPaused': <true>/.test(t)
                root.duration = num("StateDuration")
                root.elapsed = num("Elapsed")
                root.polledAt = Date.now()
                root.now = root.polledAt
            }
        }
        onExited: code => { if (code !== 0) root.pstate = "off" }
    }

    Timer {
        interval: root.active ? 5000 : 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poll.running = true
    }
    // smooth countdown between polls
    Timer {
        interval: 1000
        running: root.active && !root.paused
        repeat: true
        onTriggered: root.now = Date.now()
    }
    Timer {
        id: soon
        interval: 700
        onTriggered: poll.running = true
    }

    function run(args) {
        Quickshell.execDetached(["gnome-pomodoro", "--no-default-window"].concat(args))
        soon.restart()
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["gnome-pomodoro"])
        else if (mouse.button === Qt.MiddleButton)
            run(["--stop"])
        else
            run(active ? ["--pause-resume"] : ["--start"])
    }
}
