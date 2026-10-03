import QtQuick

// Omarchy-style workspaces, per monitor. Tags 1-5 are the laptop panel's
// and 6-10 the external monitor's (config.conf binds them that way); each
// bar shows its own monitor's home range plus any other tag that is
// occupied, focused or urgent there. With a single monitor it's 1-5 plus
// whatever higher tags are in use. The focused tag is a filled square
// glyph, the rest are numbers — full strength when occupied, dimmed when
// empty. Urgent tags pulse in the alert color. Middle click sends the
// focused window.
Item {
    id: root

    property string screenName: ""

    readonly property var st: Wm.mons[screenName] ?? { sel: Wm.seltags, occ: Wm.occtags, urg: Wm.urgtags }
    readonly property bool external: Wm.monitorCount > 1 && !screenName.startsWith("eDP")
    readonly property int first: external ? 5 : 0          // 0-based
    readonly property int last: Wm.monitorCount > 1 ? first + 4 : 4

    readonly property var shown: {
        const out = []
        for (let i = 0; i < Wm.tagCount; i++) {
            const home = i >= first && i <= last
            if (home || ((st.sel | st.occ | st.urg) & (1 << i)) !== 0)
                out.push(i)
        }
        return out
    }

    implicitWidth: tagRow.implicitWidth
    implicitHeight: Theme.moduleHeight

    function view(i) {
        if (screenName !== "") Wm.dispatch("viewcrossmon," + (i + 1) + ",^" + screenName + "$")
        else Wm.viewTag(i)
    }
    function send(i) {
        if (screenName !== "") Wm.dispatch("tagcrossmon," + (i + 1) + ",^" + screenName + "$")
        else Wm.sendToTag(i)
    }

    WheelHandler {
        onWheel: ev => Wm.cycleTag(ev.angleDelta.y > 0 ? -1 : 1)
    }

    Row {
        id: tagRow
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: root.shown

            Item {
                id: tag
                required property int modelData
                readonly property int index: modelData
                readonly property bool selected: (root.st.sel & (1 << index)) !== 0
                readonly property bool occupied: (root.st.occ & (1 << index)) !== 0
                readonly property bool urgent: (root.st.urg & (1 << index)) !== 0

                width: Math.round(22 * Theme.barScale)
                height: Theme.moduleHeight
                opacity: selected || occupied || urgent ? 1 : 0.5

                Behavior on opacity { NumberAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent

                    // pulse on the glyph so it can't clobber the dim binding
                    SequentialAnimation on opacity {
                        running: tag.urgent
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.4; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }

                    text: tag.selected ? "󱓻" : String(tag.index + 1)
                    color: tag.urgent ? Theme.red : Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: tag.selected ? Theme.iconSize : Theme.fontSize
                    Behavior on color { ColorAnimation { duration: 160 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: m => {
                        if (m.button === Qt.MiddleButton)
                            root.send(tag.index)
                        else
                            root.view(tag.index)
                    }
                }
            }
        }
    }
}
