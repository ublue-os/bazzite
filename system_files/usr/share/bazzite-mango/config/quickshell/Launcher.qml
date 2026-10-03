import QtQuick
import Quickshell

// Debian swirl in the Omarchy logo slot, sized like the other bar glyphs.
//   left: system menu (scripts/menu, also Super+Alt+Space)
//   right: new terminal
// FiraCode NF carries the Font Logos glyph; JetBrainsMono NF here doesn't.
// The wallpaper picker lives here too, opened by Super+Shift+p / the menu.
BarModule {
    id: root

    icon: "\uf306"  // Debian swirl (Font Logos)
    iconFont: "FiraCode Nerd Font"
    iconPixelSize: Theme.iconSize
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["kitty"])
        else if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached([Theme.configDir + "/scripts/menu"])
    }

    WallpaperPicker {
        id: picker
        anchorItem: root
    }
}
