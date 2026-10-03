import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// StatusNotifierItem tray (SNI over DBus, works fine on X11).
// Left click activates, right click opens the item's menu.
Rectangle {
    id: root

    visible: SystemTray.items.values.length > 0
    implicitWidth: trayRow.implicitWidth + Math.round(14 * Theme.barScale)
    implicitHeight: Theme.moduleHeight
    color: "transparent"

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            MouseArea {
                id: trayItem
                required property SystemTrayItem modelData

                width: Math.round(20 * Theme.barScale)
                height: Theme.moduleHeight
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Math.round(16 * Theme.barScale)
                    source: trayItem.modelData.icon
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                    anchor.rect.y: trayItem.height + 8
                }

                onClicked: m => {
                    if (m.button === Qt.LeftButton)
                        modelData.activate()
                    else if (m.button === Qt.MiddleButton)
                        modelData.secondaryActivate()
                    else if (modelData.hasMenu)
                        menuAnchor.open()
                }
            }
        }
    }
}
