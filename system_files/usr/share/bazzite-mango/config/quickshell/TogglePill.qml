import QtQuick
import Quickshell

// Toggle pill for the popups' quick-settings grids: filled = on.
// Left click runs modelData.run. Right-click launches modelData.alt
// (a full external tool — closeFn shuts the popup first) or calls
// modelData.altFn (an in-panel action). Scroll goes to modelData.onScroll.
// Width defaults to a 2-column grid; override it for other grids.
Rectangle {
    id: pill
    required property var modelData
    property var closeFn: null
    readonly property bool on: modelData.active === true

    width: (parent.width - 6) / 2
    height: 40
    radius: 12
    color: on ? Theme.selbg
         : pillMa.containsMouse ? Qt.alpha(Theme.fg, 0.12)
         : Qt.alpha(Theme.fg, 0.05)

    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pill.modelData.icon
            color: pill.modelData.alert ? Theme.red
                 : pill.on ? Theme.selfg : Theme.cyan
            font.family: Theme.fontFamily
            font.pixelSize: 15
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pill.modelData.label
            color: pill.on ? Theme.selfg : Qt.alpha(Theme.fg, 0.9)
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: pill.on
        }
    }

    MouseArea {
        id: pillMa
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => {
            if (m.button === Qt.RightButton) {
                if (pill.modelData.alt) {           // external tool
                    if (pill.closeFn) pill.closeFn()
                    Quickshell.execDetached(pill.modelData.alt)
                } else if (pill.modelData.altFn) {  // in-panel action
                    pill.modelData.altFn()
                }
            } else {
                pill.modelData.run()
            }
        }
        onWheel: w => pill.modelData.onScroll?.(w.angleDelta.y > 0 ? 1 : -1)
    }
}
