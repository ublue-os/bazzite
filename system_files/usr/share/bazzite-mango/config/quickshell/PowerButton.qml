import QtQuick

// Opens the existing rofi power menu script.
BarModule {
    icon: "⏻"
    onClicked: Wm.openPowerMenu()
}
