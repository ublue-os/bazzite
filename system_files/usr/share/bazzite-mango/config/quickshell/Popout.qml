import QtQuick
import Quickshell
import Quickshell.Wayland

// Shared shell for every bar popup — Wayland edition. A full-screen
// transparent layer-shell overlay (the click catcher) with the styled
// card anchored under its bar item. Clicking anywhere outside the card
// closes it; Escape too. The window takes exclusive keyboard focus only
// while visible (an xdg-popup off a layer-shell panel never gets key
// events, which is why this is a layer surface and not PopupWindow).
// The same card chrome and behaviour as the X11 ports' Popout.
PanelWindow {
    id: root

    property Item anchorItem
    property real cardWidth: 300
    property real cardHeight: 300
    readonly property real cardPadding: 14
    // right-edge panel mode (control center) instead of centered-under-anchor
    property bool alignRight: false

    default property alias content: inner.data

    visible: false
    color: "transparent"

    // the output whose bar owns the anchor item
    screen: (anchorItem && anchorItem.QsWindow.window) ? anchorItem.QsWindow.window.screen : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // anchor's position inside the bar window == on-screen position, since
    // the bar is anchored to the top edge and this overlay covers the output
    property real ax: 0
    property real ay: 0

    onVisibleChanged: {
        if (visible && anchorItem) {
            const p = anchorItem.mapToGlobal(0, 0)
            ax = p.x
            ay = p.y
            inner.forceActiveFocus()
            enterAnim.restart()
        }
    }

    // catcher: any click outside the card closes
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: card

        x: root.alignRight ? root.width - width - 8
         : Math.min(Math.max(root.ax + (root.anchorItem?.width ?? 0) / 2 - width / 2, 8),
                    root.width - width - 8)
        y: root.ay + (root.anchorItem?.height ?? 0) + 12

        transform: Translate { id: slide; y: 0 }

        ParallelAnimation {
            id: enterAnim
            NumberAnimation { target: slide; property: "y"; from: -10; to: 0
                              duration: 160; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1
                              duration: 160 }
        }
        width: root.cardWidth
        height: root.cardHeight
        radius: 12
        // a touch translucent while mango blurs behind layers, so the
        // card frosts over the desktop; solid again when blur is off
        color: Wm.blur ? Qt.alpha(Theme.bg, 0.86) : Theme.bg
        border.width: 1
        border.color: Qt.alpha(Theme.accent, 0.4)

        Behavior on color { ColorAnimation { duration: 250 } }

        // swallow card clicks so they don't fall through to the catcher
        MouseArea { anchors.fill: parent }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: root.cardPadding
            focus: true
            Keys.onEscapePressed: root.visible = false
        }
    }
}
