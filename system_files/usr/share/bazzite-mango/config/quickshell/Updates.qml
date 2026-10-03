import QtQuick
import Quickshell
import Quickshell.Io

// Pending-updates indicator, presence-gated: hidden at zero, an icon +
// count when updates are waiting. Bazzite counts as: 1 for a newer system
// image (rpm-ostree upgrade --check) plus each Flatpak with an update.
// Polled hourly plus shortly after the upgrade terminal is opened; middle
// click re-checks now. Bazzite also updates itself in the background.
BarModule {
    id: root

    property int count: 0
    visible: count > 0
    icon: "󰚰"
    label: String(count)

    Process {
        id: checkProc
        command: ["sh", "-c",
            "n=$(flatpak remote-ls --updates --columns=application 2>/dev/null | grep -c .); " +
            "rpm-ostree upgrade --check >/dev/null 2>&1 && n=$((n+1)); echo $n"]
        stdout: StdioCollector {
            onStreamFinished: root.count = parseInt(text.trim()) || 0
        }
    }

    Timer {
        interval: 3600 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProc.running = true
    }

    // the upgrade runs in a detached terminal — recheck a few minutes
    // after it was opened so the pill clears without waiting out the hour
    Timer {
        id: recheck
        interval: 5 * 60 * 1000
        onTriggered: checkProc.running = true
    }

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            checkProc.running = true
        } else {
            Quickshell.execDetached(["kitty", "-e", "sh", "-c",
                "ujust update; " +
                "printf '\\ndone - press enter to close '; read _"])
            recheck.restart()
        }
    }
}
