import QtQuick

// Base bar module, Omarchy style: a bare nerd-font glyph (+ optional
// label) on the bar background — no pill, no hover box, just a pointer
// cursor on clickable modules. Click/scroll signals; extra content can
// be added as children.
Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Theme.fg
    // some glyphs (e.g. Font Logos ) are missing from JetBrainsMono NF here
    property string iconFont: Theme.fontFamily
    property int iconPixelSize: Theme.iconSize
    property string label: ""
    property color labelColor: Theme.fg
    property bool interactive: true
    readonly property bool hovered: mouse.containsMouse

    // No hover-expanding labels: the right cluster is right-anchored, so
    // a module growing on hover shifts its neighbors out from under the
    // cursor mid-aim. Labels are static or event-flashed (Volume) only;
    // details live in each module's popup/app.

    // progress underline along the module bottom: 0..1 shows it, negative hides
    property real progress: -1

    signal clicked(var mouse)
    signal scrolled(int dir)

    default property alias extraContent: row.data

    implicitHeight: Theme.moduleHeight
    implicitWidth: row.implicitWidth + Math.round(17 * Theme.barScale)
    color: "transparent"

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Math.round(6 * Theme.barScale)

        Text {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.iconColor
            font.family: root.iconFont
            font.pixelSize: root.iconPixelSize
            Behavior on color { ColorAnimation { duration: 250 } }
        }

        Text {
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.labelColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 250 } }
        }
    }

    Rectangle {
        visible: root.progress >= 0
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Math.round(6 * Theme.barScale)
        anchors.bottomMargin: 2
        height: 2
        radius: 1
        width: Math.min(Math.max(root.progress, 0), 1) * (parent.width - anchors.leftMargin * 2)
        color: Theme.accent
        opacity: 0.9
        Behavior on width { NumberAnimation { duration: 300 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => root.clicked(m)
        onWheel: w => root.scrolled(w.angleDelta.y > 0 ? 1 : -1)
    }
}
