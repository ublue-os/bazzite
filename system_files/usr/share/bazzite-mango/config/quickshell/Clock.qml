import QtQuick
import Quickshell

// Omarchy-style clock: weekday + 24h time, pinned to the bar's center.
// Left click toggles the calendar, right click cycles to the full date
// with ISO week, middle click picks the timezone.
BarModule {
    id: root

    property bool alt: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    label: alt ? Qt.formatDateTime(clock.date, "d MMMM") + " W" + isoWeek(clock.date) + Qt.formatDateTime(clock.date, " yyyy")
               : Qt.formatDateTime(clock.date, "dddd HH:mm")

    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7))
        return Math.ceil(((t - Date.UTC(t.getUTCFullYear(), 0, 1)) / 86400000 + 1) / 7)
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            alt = !alt
        else if (mouse.button === Qt.MiddleButton)
            Quickshell.execDetached([Theme.configDir + "/scripts/timezone"])
        else
            calendar.visible = !calendar.visible
    }

    CalendarPopup {
        id: calendar
        anchorItem: root
    }
}
