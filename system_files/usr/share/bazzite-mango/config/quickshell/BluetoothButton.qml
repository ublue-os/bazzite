import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth, Omarchy clicks: left opens the Bluetooth manager (blueman,
// floated by config.conf), right toggles the radio. Glyph shows off /
// on / connected. Hidden on machines without an adapter.
BarModule {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    readonly property int connected: (adapter?.devices?.values ?? []).filter(d => d.connected).length

    visible: adapter !== null
    icon: !on ? "󰂲" : connected > 0 ? "󰂱" : "󰂯"
    iconColor: on ? Theme.fg : Qt.alpha(Theme.fg, 0.45)

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (adapter) adapter.enabled = !adapter.enabled
        } else if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["blueman-manager"])
    }
}
