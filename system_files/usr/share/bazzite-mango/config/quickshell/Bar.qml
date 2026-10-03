import QtQuick
import Quickshell

// The bar window, effectiveBarHeight px tall, laid out like the Omarchy
// bar: a flush, full-width strip in three sections —
//   left:   Debian logo (menu) · workspaces (this monitor's tags)
//   center: indicators · clock (pinned to the exact screen center) ·
//           weather · pomodoro · Debian update badge
//   right:  screenshot · tray · ExpressVPN · bluetooth · network · audio ·
//           display · power
// Under mango this is a wlr-layer-shell panel: the compositor reserves its
// exclusive zone and re-tiles live when the height changes.
PanelWindow {
    id: root

    property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.effectiveBarHeight
    color: "transparent"
    // map once, at final size — see Theme.barStateReady
    visible: Theme.barStateReady

    Rectangle {
        id: panel
        anchors.fill: parent
        color: Theme.bg

        Behavior on color { ColorAnimation { duration: 400 } }

        // right-click empty bar = the layout/tweaks picker (also Super+Shift+t);
        // declared before the clusters so module mouse areas stack above it
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: picker.visible = !picker.visible
        }

        Row {
            id: leftCluster
            anchors.left: parent.left
            anchors.leftMargin: Math.round(4 * Theme.barScale)
            anchors.verticalCenter: parent.verticalCenter

            Launcher {}
            Tags { screenName: root.modelData?.name ?? "" }

            // zero-width anchor for the layout picker popup
            Item {
                id: pickerAnchor
                width: 1
                height: Theme.moduleHeight
                LayoutPicker {
                    id: picker
                    anchorItem: pickerAnchor
                }
            }
        }

        Clock {
            id: clock
            anchors.centerIn: parent
        }

        Row {
            anchors.right: clock.left
            anchors.verticalCenter: parent.verticalCenter

            // indicators: each shows only while its state needs attention
            MicMute {}
            CapsLock {}
            Bell {}
            Commands {}
        }

        Row {
            anchors.left: clock.right
            anchors.verticalCenter: parent.verticalCenter

            Weather {}
            Pomodoro {}
            Updates {}
        }

        Row {
            id: rightCluster
            anchors.right: parent.right
            anchors.rightMargin: Math.round(4 * Theme.barScale)
            anchors.verticalCenter: parent.verticalCenter

            Screenshot {}
            Tray {}
            ExpressVpn {}
            BluetoothButton {}
            Network {}
            Volume {}
            Display {}
            Power {}
        }
    }
}
