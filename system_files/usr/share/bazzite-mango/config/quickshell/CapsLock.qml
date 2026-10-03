import QtQuick

// Caps-lock warning: hidden until caps is on, then an alert-colored glyph.
BarModule {
    visible: Sys.capsOn
    icon: "󰘲"
    iconColor: Theme.red
    interactive: false
}
