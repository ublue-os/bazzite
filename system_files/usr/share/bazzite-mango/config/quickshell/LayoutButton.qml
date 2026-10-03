import QtQuick

// Current layout as its nerd-font glyph — the same symbols dwm's retired
// native bar used (layouts[] in config.h). Scroll cycles layouts, click
// opens the picker grid.
BarModule {
    id: root

    // lets Bar.qml's right-click-on-empty-bar toggle the same popup
    property alias pickerVisible: picker.visible

    icon: Wm.layouts[Wm.layoutIndex].glyph
    iconColor: Theme.fg

    onClicked: picker.visible = !picker.visible
    onScrolled: dir => Wm.cycleLayout(dir)

    LayoutPicker {
        id: picker
        anchorItem: root
    }
}
