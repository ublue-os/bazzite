import QtQuick
import ".."

Rectangle {
    id: navRail
    width: Theme.navRailWidth
    color: Theme.navBg

    property int currentIndex: 0
    signal navigated(int index)

    // Subtle right border
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.borderSubtle
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingSm

        Repeater {
            model: [
                { icon: "⌂", label: "Home" },
                { icon: "▤", label: "Library" },
                { icon: "⊞", label: "Stores" },
                { icon: "▶", label: "Shows" },
                { icon: "⚙", label: "Settings" }
            ]

            delegate: Item {
                width: Theme.navRailWidth
                height: 64

                property bool isActive: navRail.currentIndex === index
                property bool isHovered: mouseArea.containsMouse

                Rectangle {
                    anchors.centerIn: parent
                    width: 52
                    height: 52
                    radius: Theme.borderRadiusSm
                    color: isActive ? Theme.navActive : isHovered ? Theme.bgCardHover : "transparent"
                    border.color: isActive ? Theme.accentBlue : "transparent"
                    border.width: isActive ? 1.5 : 0

                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: Theme.animFast }
                    }

                    // Glow effect when active
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: Theme.accentGlow
                        border.width: isActive ? 1 : 0
                        opacity: isActive ? 0.3 : 0
                        scale: isActive ? 1.15 : 1.0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.animNormal }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            font.pixelSize: 22
                            color: isActive ? Theme.accentCyan : Theme.textSecondary

                            Behavior on color {
                                ColorAnimation { duration: Theme.animFast }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pixelSize: 9
                            font.letterSpacing: 1
                            color: isActive ? Theme.textPrimary : Theme.textDim

                            Behavior on color {
                                ColorAnimation { duration: Theme.animFast }
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        navRail.navigated(index)
                        audioManager.play("select")
                    }
                }

                Keys.onReturnPressed: navRail.navigated(index)
                Keys.onEnterPressed: navRail.navigated(index)
            }
        }
    }
}
