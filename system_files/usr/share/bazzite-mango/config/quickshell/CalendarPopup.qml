import QtQuick

// Month calendar popup anchored under the clock. Today gets an accent pill;
// chevrons page months, clicking the header jumps back to today.
Popout {
    id: root

    property date shown: new Date()

    cardWidth: 280
    cardHeight: 300

    onVisibleChanged: {
        if (visible)
            shown = new Date()
    }

    Column {
        anchors.fill: parent
        spacing: 8

        // header: ‹ month year ›
        Item {
            width: parent.width
            height: 28

            Text {
                id: prevBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅁"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 18
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.shown = new Date(root.shown.getFullYear(), root.shown.getMonth() - 1, 1)
                }
            }

            Text {
                anchors.centerIn: parent
                text: Qt.formatDate(root.shown, "MMMM yyyy")
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    onClicked: root.shown = new Date()
                }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅂"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 18
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.shown = new Date(root.shown.getFullYear(), root.shown.getMonth() + 1, 1)
                }
            }
        }

        // weekday header
        Row {
            width: parent.width
            Repeater {
                model: 7
                Text {
                    required property int index
                    width: parent.width / 7
                    text: Qt.locale().dayName((Qt.locale().firstDayOfWeek + index) % 7, Locale.ShortFormat)
                    color: Qt.alpha(Theme.fg, 0.5)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // day grid
        Grid {
            id: dayGrid
            width: parent.width
            columns: 7

            Repeater {
                model: 42

                Item {
                    id: cell
                    required property int index
                    width: dayGrid.width / 7
                    height: 30

                    readonly property date cellDate: {
                        const first = new Date(root.shown.getFullYear(), root.shown.getMonth(), 1)
                        const offset = (first.getDay() - Qt.locale().firstDayOfWeek + 7) % 7
                        return new Date(first.getFullYear(), first.getMonth(), 1 - offset + index)
                    }
                    readonly property bool inMonth: cellDate.getMonth() === root.shown.getMonth()
                    readonly property bool isToday: {
                        const now = new Date()
                        return cellDate.getFullYear() === now.getFullYear()
                            && cellDate.getMonth() === now.getMonth()
                            && cellDate.getDate() === now.getDate()
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: 13
                        color: cell.isToday ? Theme.selbg : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: cell.cellDate.getDate()
                            color: cell.isToday ? Theme.selfg
                                 : cell.inMonth ? Theme.fg
                                 : Qt.alpha(Theme.fg, 0.25)
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: cell.isToday
                        }
                    }
                }
            }
        }
    }
}
