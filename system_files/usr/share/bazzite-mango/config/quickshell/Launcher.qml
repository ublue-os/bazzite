import QtQuick
import QtQuick.Effects
import Quickshell

// Bazzite logo in the Omarchy logo slot, sized like the other bar glyphs.
//   left: system menu (scripts/menu, also Super+Alt+Space)
//   right: new terminal
// No nerd-font glyph exists for Bazzite, so this is the press-kit BW SVG
// (white on transparent) tinted to the palette's fg, so it follows
// wallpaper-theme / theme-set like the glyphs around it.
// The wallpaper picker lives here too, opened by Super+Shift+p / the menu.
BarModule {
    id: root

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["kitty"])
        else if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached([Theme.configDir + "/scripts/menu"])
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.iconSize
        height: Theme.iconSize

        Image {
            id: logo
            anchors.fill: parent
            source: Qt.resolvedUrl("bazzite.svg")
            sourceSize: Qt.size(width * 2, height * 2)
            smooth: true
            visible: false
        }

        MultiEffect {
            anchors.fill: logo
            source: logo
            colorization: 1.0
            colorizationColor: root.iconColor
            Behavior on colorizationColor { ColorAnimation { duration: 250 } }
        }
    }

    WallpaperPicker {
        id: picker
        anchorItem: root
    }
}
