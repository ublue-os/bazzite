import QtQuick
import ".."

Item {
    id: settingsPage

    Flickable {
        anchors.fill: parent
        contentHeight: settingsColumn.height + Theme.spacingXl * 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: settingsColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingXl
            spacing: Theme.spacingXl

            Text {
                text: "Settings"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }

            // User section
            SettingsSection {
                title: "PROFILE"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: Theme.spacingSm

                    SettingsRow {
                        label: "Name"
                        value: configManager.userName || "Not set"
                    }
                }
            }

            // System section
            SettingsSection {
                title: "SYSTEM"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: Theme.spacingSm

                    SettingsRow {
                        label: "Switch to Desktop Mode"
                        actionText: "Switch"
                        onAction: {
                            audioManager.play("select")
                            Qt.callLater(function() {
                                // Use steamos-session-select to switch to desktop
                                gameLauncher.launch("_system", "Desktop Mode", "System", "", "steamos-session-select desktop")
                            })
                        }
                    }

                    SettingsRow {
                        label: "Rescan Game Library"
                        actionText: "Scan"
                        onAction: {
                            audioManager.play("select")
                            gameScanner.scan_all()
                        }
                    }

                    SettingsRow {
                        label: "Luna Version"
                        value: "1.0.0"
                    }
                }
            }

            // About section
            SettingsSection {
                title: "ABOUT"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: Theme.spacingSm

                    Text {
                        text: "Luna Console Mode"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textPrimary
                    }

                    Text {
                        text: "Part of Stellar OS - Built on Bazzite"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }

                    Text {
                        text: "A premium gaming console experience for your PC"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textDim
                    }
                }
            }
        }
    }

    // Reusable settings section
    component SettingsSection: Column {
        property string title: ""
        default property alias content: sectionContent.children
        spacing: Theme.spacingMd

        Text {
            text: title
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            font.letterSpacing: 2
            color: Theme.textDim
        }

        Rectangle {
            width: parent.width
            height: sectionContent.height + Theme.spacingMd * 2
            radius: Theme.borderRadius
            color: Theme.bgCard
            border.color: Theme.borderSubtle
            border.width: 1

            Column {
                id: sectionContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingMd
            }
        }
    }

    // Reusable settings row
    component SettingsRow: Rectangle {
        property string label: ""
        property string value: ""
        property string actionText: ""
        signal action()

        width: parent.width
        height: 48
        color: rowMouse.containsMouse && actionText ? Theme.bgCardHover : "transparent"
        radius: 6

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingSm
            anchors.rightMargin: Theme.spacingSm

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: label
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textPrimary
                width: parent.width * 0.6
            }

            Item { width: parent.width * 0.1; height: 1 }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: actionText || value
                font.pixelSize: Theme.fontSizeNormal
                font.bold: !!actionText
                color: actionText ? Theme.accentBlue : Theme.textSecondary
                horizontalAlignment: Text.AlignRight
                width: parent.width * 0.3
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: !!actionText
            cursorShape: actionText ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (actionText) action()
        }
    }
}
