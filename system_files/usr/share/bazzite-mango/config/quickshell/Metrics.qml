import QtQuick

// System numbers, flat on the bar: CPU / RAM / root fs ("/" tag is the
// mountpoint), plus battery on laptops (hidden when none). Text tags in
// the slstatus color story; battery keeps its state-encoding glyph.
// No pill background: boxes are for things you can click.
BarModule {
    interactive: false
    color: "transparent"

    // dim dot — keeps "RAM 15% / 19%" from scanning as a fraction
    component Sep: Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "·"
        color: Qt.alpha(Theme.fg, 0.3)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    component Seg: Row {
        property string tag: ""
        property string icon: ""
        property color tagColor
        property string value
        property color valueColor: Theme.fg
        spacing: Math.round(5 * Theme.barScale)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            visible: parent.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: parent.icon
            color: parent.tagColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        Text {
            visible: parent.tag !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: parent.tag
            color: parent.tagColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            color: parent.valueColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 250 } }
        }
    }

    // one Row child so segment spacing is ours, not BarModule's tighter default
    Row {
        spacing: Math.round(10 * Theme.barScale)
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 4
        rightPadding: 4

        Seg {
            tag: "CPU"
            tagColor: Theme.red
            value: Math.round(Sys.cpu) + "%"
            valueColor: Sys.cpu > 90 ? Theme.red : Theme.fg
        }
        Sep {}
        Seg {
            tag: "RAM"
            tagColor: Theme.blue
            value: Math.round(Sys.mem) + "%"
            valueColor: Sys.mem > 90 ? Theme.red : Theme.fg
        }
        Sep {}
        Seg {
            tag: "/"
            tagColor: Theme.yellow
            value: Math.round(Sys.disk) + "%"
            valueColor: Sys.disk > 90 ? Theme.red : Theme.fg
        }
        Sep { visible: Sys.hasBattery }
        Seg {
            visible: Sys.hasBattery
            icon: Sys.batteryCharging ? "󰂄"
                : Sys.battery < 15 ? "󰁺"
                : Sys.battery < 40 ? "󰁼"
                : Sys.battery < 80 ? "󰁾"
                : "󰁹"
            tagColor: Sys.batteryCharging ? Theme.green
                : Sys.battery < 15 ? Theme.red
                : Sys.battery < 40 ? Theme.yellow
                : Theme.green
            value: Math.round(Sys.battery) + "%"
            valueColor: !Sys.batteryCharging && Sys.battery < 15 ? Theme.red : Theme.fg
        }
    }
}
