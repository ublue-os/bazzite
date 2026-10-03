import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Power, Omarchy clicks: left opens the power panel (battery stats,
// power profiles, system actions), right toggles the battery percentage
// on the bar. Without a laptop battery it's a plain power glyph.
BarModule {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property bool hasBattery: bat?.isLaptopBattery ?? false
    readonly property int pct: Math.round((bat?.percentage ?? 0) * 100)
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging
                                  || bat?.state === UPowerDeviceState.FullyCharged
                                  || (!UPower.onBattery && hasBattery)
    property bool showPct: false

    readonly property var levels: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingLevels: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    icon: !hasBattery ? "⏻"
        : (charging ? chargingLevels : levels)[Math.min(10, Math.floor(pct / 10))]
    iconColor: hasBattery && !charging && pct <= 15 ? Theme.red : Theme.fg
    label: hasBattery && showPct ? pct + "%" : ""

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            showPct = !showPct
        else if (mouse.button === Qt.LeftButton)
            panel.visible = !panel.visible
    }

    function fmtTime(s) {
        if (!s || s <= 0) return ""
        const h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60)
        return h > 0 ? h + "h " + m + "m" : m + "m"
    }

    Popout {
        id: panel
        anchorItem: root

        IpcHandler {
            target: "power"
            function toggle(): void { panel.visible = !panel.visible }
        }
        cardWidth: 290
        cardHeight: col.implicitHeight + 2 * cardPadding

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            // battery summary
            Row {
                visible: root.hasBattery
                spacing: 12
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.icon
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 28
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: root.pct + "%" + (root.charging ? " · charging" : " · on battery")
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        readonly property string t: root.charging ? root.fmtTime(root.bat?.timeToFull)
                                                                  : root.fmtTime(root.bat?.timeToEmpty)
                        visible: t !== ""
                        text: t + (root.charging ? " until full" : " remaining")
                        color: Qt.alpha(Theme.fg, 0.7)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        visible: (root.bat?.changeRate ?? 0) > 0
                        text: (root.bat?.changeRate ?? 0).toFixed(1) + " W"
                        color: Qt.alpha(Theme.fg, 0.7)
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            Text {
                text: "Power profile"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                topPadding: 4
            }

            Row {
                width: parent.width
                spacing: 6
                Repeater {
                    model: [
                        { p: PowerProfile.PowerSaver, icon: "󰾆", label: "Saver" },
                        { p: PowerProfile.Balanced, icon: "󰾅", label: "Balanced" },
                        { p: PowerProfile.Performance, icon: "󰓅", label: "Perf" }
                    ]
                    Rectangle {
                        id: prof
                        required property var modelData
                        readonly property bool active: PowerProfiles.profile === modelData.p
                        visible: modelData.p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
                        width: (col.width - 12) / 3
                        height: 46
                        radius: 8
                        color: active ? Qt.alpha(Theme.accent, 0.22)
                             : pm.containsMouse ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.fg, 0.05)
                        Column {
                            anchors.centerIn: parent
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: prof.modelData.icon
                                color: prof.active ? Theme.accent : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: prof.modelData.label
                                color: prof.active ? Theme.accent : Qt.alpha(Theme.fg, 0.8)
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                        MouseArea {
                            id: pm
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: PowerProfiles.profile = prof.modelData.p
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: Qt.alpha(Theme.fg, 0.15)
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Repeater {
                    model: [
                        { icon: "󰌾", tip: "Lock", cmd: ["swaylock", "-f", "-c", "1e1e2e"] },
                        { icon: "󰤄", tip: "Suspend", cmd: ["systemctl", "suspend"] },
                        { icon: "󰜉", tip: "Reboot", cmd: ["systemctl", "reboot"] },
                        { icon: "⏻", tip: "Shut down", cmd: ["systemctl", "poweroff"] }
                    ]
                    Rectangle {
                        id: act
                        required property var modelData
                        width: 52
                        height: 40
                        radius: 8
                        color: am.containsMouse ? Qt.alpha(Theme.accent, 0.22) : Qt.alpha(Theme.fg, 0.05)
                        Text {
                            anchors.centerIn: parent
                            text: act.modelData.icon
                            color: am.containsMouse ? Theme.accent : Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: 17
                        }
                        MouseArea {
                            id: am
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                panel.visible = false
                                Quickshell.execDetached(act.modelData.cmd)
                            }
                        }
                    }
                }
            }
        }
    }
}
