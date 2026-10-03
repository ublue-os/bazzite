import QtQuick
import Quickshell

// Screenshot: left = region (slurp), right = full screen. grim saves to
// ~/Screenshots (scripts/screenshot).
BarModule {
    icon: "󰻛"
    onClicked: mouse => Quickshell.execDetached([Theme.configDir + "/scripts/screenshot",
        mouse.button === Qt.RightButton ? "full" : "region"])
}
