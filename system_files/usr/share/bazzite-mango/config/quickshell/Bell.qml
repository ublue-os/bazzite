import QtQuick

// Do-not-disturb indicator, CapsLock-pattern: hidden while dunst is live,
// a red bell-off glyph only while DND is on — the state you must not lose
// track of. Toggling lives in the Commands panel; this stays clickable as
// the fast way out (click resumes notifications, right click history).
BarModule {
    id: root

    visible: Sys.dndOn
    icon: "󰂛"
    iconColor: Theme.red

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            history.visible = !history.visible
        else
            Sys.toggleDnd()
    }

    NotifyPopup {
        id: history
        anchorItem: root
    }
}
