import QtQuick
import Quickshell

// The ExpressVPN logo shipped by the official app, tinted with a theme
// color so it sits with the other bar glyphs: drawn into a Canvas, then
// filled with "source-in" so only the logo's own shape takes the color.
// (Core QtQuick only — QtQuick.Effects isn't installed here.) Adapted from
// omarchy-expressvpn's ExpressVpnIcon.qml (MIT); falls back to a shield
// glyph if the app's icon is missing.
Item {
    id: root

    property real iconSize: Theme.iconSize
    property color iconColor: Theme.fg

    readonly property string src: {
        const p = Quickshell.iconPath("expressvpn", true)
        return p !== "" ? p : "file:///usr/share/pixmaps/expressvpn.png"
    }

    implicitWidth: iconSize
    implicitHeight: iconSize

    onIconColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        Component.onCompleted: loadImage(root.src)
        onImageLoaded: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            if (!isImageLoaded(root.src)) return
            ctx.drawImage(root.src, 0, 0, width, height)
            ctx.globalCompositeOperation = "source-in"
            ctx.fillStyle = root.iconColor
            ctx.fillRect(0, 0, width, height)
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !canvas.isImageLoaded(root.src) && canvas.isImageError(root.src)
        text: "\u{F099D}"
        color: root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize
    }
}
