import QtQuick

// Labeled slider for tweaks popups: applies live while dragging
// (throttled), persists on release. WM-agnostic — callers supply
// applyFn/persistFn.
Item {
    id: ts

    property string label
    property real from: 0
    property real to: 40
    property real value: 0
    property bool isInt: true
    property string suffix: ""

    required property var applyFn
    required property var persistFn

    signal committed(real v)

    property real drag: 0
    readonly property real shown: ma.pressed ? drag : value

    function fmt(v) { return isInt ? Math.round(v) : Math.round(v * 100) / 100 }

    width: parent.width
    height: 36

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        text: ts.label
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: 11
    }
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        text: ts.fmt(ts.shown) + ts.suffix
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7
        height: 4
        radius: 2
        color: Qt.alpha(Theme.fg, 0.12)

        Rectangle {
            readonly property real frac: Math.min(Math.max(
                (ts.shown - ts.from) / (ts.to - ts.from), 0), 1)
            width: frac * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.accent
        }
        Rectangle {
            readonly property real frac: Math.min(Math.max(
                (ts.shown - ts.from) / (ts.to - ts.from), 0), 1)
            x: frac * parent.width - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            radius: 6
            color: Theme.fg
            border.width: 2
            border.color: Theme.bg
        }
    }

    // throttle live applies while dragging
    Timer {
        id: applyThrottle
        interval: 60
        onTriggered: ts.applyFn(ts.fmt(ts.drag))
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.topMargin: 12
        function at(mx) {
            const f = Math.min(Math.max(mx / width, 0), 1)
            return ts.from + f * (ts.to - ts.from)
        }
        onPressed: m => { ts.drag = at(m.x); applyThrottle.restart() }
        onPositionChanged: m => {
            if (pressed) { ts.drag = at(m.x); applyThrottle.restart() }
        }
        onReleased: {
            const v = ts.fmt(ts.drag)
            ts.applyFn(v)
            ts.persistFn(v)
            ts.committed(v)
        }
    }
}
