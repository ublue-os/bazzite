import QtQuick
import Quickshell
import Quickshell.Io

// Network, Omarchy style. Left click opens the network panel:
//   header   — active connection, IP, Wi-Fi radio switch
//   DNS      — provider pills (DHCP / Cloudflare / Google / Quad9 /
//              OpenDNS / Custom), applied through scripts/dns
//   Wi-Fi    — scanned networks with signal strength; click to connect,
//              secured networks ask for the password inline
// Right click opens the full network app (VPN, Bluetooth, saved profiles).
BarModule {
    id: root

    icon: Sys.netIcon
    iconColor: Sys.online ? Theme.fg : Theme.red

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached([Theme.configDir + "/scripts/network"])
        else if (mouse.button === Qt.LeftButton)
            panel.visible = !panel.visible
    }

    readonly property string dnsScript: Theme.configDir + "/scripts/dns"
    readonly property var providers: ["DHCP", "Cloudflare", "Google", "Quad9", "OpenDNS", "Custom"]

    property string conName: ""
    property string conType: ""
    property string ipAddr: ""
    property bool wifiOn: true
    property string dns: "DHCP"          // provider name
    property string dnsCustom: ""        // servers when Custom
    property bool dnsBusy: false
    property bool editingCustom: false
    property var networks: []            // {ssid, signal, secure, active, known}
    property bool scanning: false
    property string askPassFor: ""
    property string connecting: ""
    property string error: ""

    function refresh() {
        stateProc.running = true
        dnsProc.running = true
    }
    function scan(rescan) {
        if (scanProc.running) return
        scanning = true
        scanProc.command = ["sh", "-c",
            "printf '%s\\n' \"$(nmcli -t -f NAME connection show | tr '\\n' '\\t')\"; " +
            "nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan " + (rescan ? "yes" : "auto")]
        scanProc.running = true
    }

    Process {
        id: stateProc
        command: ["sh", "-c",
            "nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep -vE ':(loopback|bridge|tun|wireguard):' | head -n1; " +
            "nmcli radio wifi; " +
            "ip -4 -o addr show scope global | grep -vE ' (virbr|docker|tun|wg)' | awk '{print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n")
                const c = (l[0] ?? "").split(":")
                root.conName = c[0] ?? ""
                root.conType = (c[1] ?? "").indexOf("wireless") >= 0 ? "Wi-Fi"
                             : (c[1] ?? "").indexOf("ethernet") >= 0 ? "Ethernet" : (c[1] ?? "")
                root.wifiOn = (l[1] ?? "").trim() === "enabled"
                root.ipAddr = (l[2] ?? "").trim()
            }
        }
    }

    Process {
        id: dnsProc
        command: [root.dnsScript]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t.startsWith("Custom")) {
                    root.dns = "Custom"
                    root.dnsCustom = t.substring(6).trim()
                } else if (t !== "")
                    root.dns = t
            }
        }
    }

    Process {
        id: dnsSet
        stderr: StdioCollector { onStreamFinished: if (text.trim() !== "") root.error = text.trim() }
        onExited: code => { root.dnsBusy = false; if (code === 0) root.error = ""; dnsProc.running = true }
    }
    function setDns(p, servers) {
        dnsBusy = true
        dns = p
        dnsSet.command = p === "Custom" ? [dnsScript, "Custom", servers] : [dnsScript, p]
        dnsSet.running = true
    }

    Process {
        id: scanProc
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                const known = (lines[0] ?? "").split("\t")
                const seen = {}
                const out = []
                for (const line of lines.slice(1)) {
                    // IN-USE:SIGNAL:SECURITY:SSID — SSID last, may contain ':' (escaped \:)
                    const m = line.match(/^([* ]?):(\d+):([^:]*):(.*)$/)
                    if (!m) continue
                    const ssid = m[4].replace(/\\:/g, ":")
                    if (ssid === "" || (seen[ssid] && m[1] !== "*")) continue
                    seen[ssid] = true
                    out.push({ ssid: ssid, signal: parseInt(m[2]), secure: m[3] !== "" && m[3] !== "--",
                               enterprise: m[3].indexOf("802.1X") >= 0,
                               active: m[1] === "*", known: known.indexOf(ssid) >= 0 })
                }
                out.sort((a, b) => (b.active - a.active) || (b.signal - a.signal))
                root.networks = out.filter((n, i) => out.findIndex(x => x.ssid === n.ssid) === i)
                root.scanning = false
            }
        }
        onExited: root.scanning = false
    }

    Process {
        id: connectProc
        stderr: StdioCollector { onStreamFinished: if (text.trim() !== "") root.error = text.trim().split("\n").pop() }
        onExited: code => {
            root.connecting = ""
            if (code === 0) { root.error = ""; root.askPassFor = "" }
            root.refresh()
            root.scan(false)
        }
    }
    function connectTo(n, pass) {
        error = ""
        if (n.enterprise && !n.known) {
            // 802.1X needs the full editor (identity, EAP method, certs)
            Quickshell.execDetached(["nm-connection-editor", "--create", "--type=802-11-wireless"])
            return
        }
        if (n.secure && !n.known && pass === undefined) { askPassFor = n.ssid; return }
        connecting = n.ssid
        connectProc.command = n.known ? ["nmcli", "connection", "up", "id", n.ssid]
            : pass !== undefined ? ["nmcli", "device", "wifi", "connect", n.ssid, "password", pass]
            : ["nmcli", "device", "wifi", "connect", n.ssid]
        connectProc.running = true
    }

    function bars(s) { return s >= 75 ? "󰤨" : s >= 50 ? "󰤥" : s >= 25 ? "󰤢" : "󰤟" }

    component SectionLabel: Text {
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: true
        topPadding: 4
    }

    Popout {
        id: panel
        anchorItem: root

        IpcHandler {
            target: "network"
            function toggle(): void { panel.visible = !panel.visible }
        }
        cardWidth: 360
        cardHeight: col.implicitHeight + 2 * cardPadding

        onVisibleChanged: {
            if (visible) {
                root.error = ""
                root.askPassFor = ""
                root.editingCustom = false
                root.refresh()
                root.scan(false)
            }
        }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            // header
            Item {
                width: parent.width
                height: 44
                Text {
                    id: hIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Sys.netIcon
                    color: Sys.online ? Theme.accent : Theme.red
                    font.family: Theme.fontFamily
                    font.pixelSize: 26
                }
                Column {
                    anchors.left: hIcon.right
                    anchors.leftMargin: 12
                    anchors.right: wsw.left
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.conName !== "" ? root.conName : "Not connected"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        text: [root.conType, root.ipAddr].filter(Boolean).join(" · ")
                        color: Qt.alpha(Theme.fg, 0.65)
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }
                // Wi-Fi radio switch
                Rectangle {
                    id: wsw
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44; height: 24; radius: 12
                    color: root.wifiOn ? Theme.accent : Qt.alpha(Theme.fg, 0.2)
                    Rectangle {
                        width: 18; height: 18; radius: 9; y: 3
                        x: root.wifiOn ? parent.width - width - 3 : 3
                        color: Theme.bg
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.wifiOn = !root.wifiOn
                            Quickshell.execDetached(["nmcli", "radio", "wifi", root.wifiOn ? "on" : "off"])
                            if (root.wifiOn) rescanLater.restart(); else root.networks = []
                        }
                    }
                    Timer { id: rescanLater; interval: 2500; onTriggered: root.scan(true) }
                }
            }

            SectionLabel { text: "DNS" + (root.dnsBusy ? "  …" : "") }

            Grid {
                width: parent.width
                columns: 3
                spacing: 6
                Repeater {
                    model: root.providers
                    Rectangle {
                        id: pill
                        required property string modelData
                        readonly property bool active: root.dns === modelData
                        width: (col.width - 12) / 3
                        height: 30
                        radius: 8
                        color: active ? Qt.alpha(Theme.accent, 0.22)
                             : pma.containsMouse ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.fg, 0.05)
                        Text {
                            anchors.centerIn: parent
                            text: pill.modelData
                            color: pill.active ? Theme.accent : Qt.alpha(Theme.fg, 0.85)
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: pill.active
                        }
                        MouseArea {
                            id: pma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (pill.modelData === "Custom") {
                                    root.editingCustom = true
                                    customInput.text = root.dnsCustom
                                    customInput.forceActiveFocus()
                                } else {
                                    root.editingCustom = false
                                    root.setDns(pill.modelData)
                                }
                            }
                        }
                    }
                }
            }

            // custom servers entry
            Rectangle {
                visible: root.editingCustom
                width: parent.width
                height: 32
                radius: 8
                color: Qt.alpha(Theme.fg, 0.07)
                border.width: 1
                border.color: Qt.alpha(Theme.accent, 0.6)
                TextInput {
                    id: customInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    clip: true
                    Keys.onReturnPressed: if (text.trim() !== "") { root.setDns("Custom", text); root.editingCustom = false }
                    Keys.onEscapePressed: root.editingCustom = false
                }
                Text {
                    visible: customInput.text === ""
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "servers, e.g. 192.168.1.1 1.1.1.1  ⏎"
                    color: Qt.alpha(Theme.fg, 0.4)
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }
            Text {
                visible: root.dns === "Custom" && !root.editingCustom && root.dnsCustom !== ""
                text: root.dnsCustom
                color: Qt.alpha(Theme.fg, 0.6)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                leftPadding: 4
            }

            Item {
                width: parent.width
                height: wifiLabel.implicitHeight
                SectionLabel { id: wifiLabel; text: "Wi-Fi" + (root.scanning ? "  scanning…" : "") }
                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: "󰑐"
                    color: rsm.containsMouse ? Theme.accent : Qt.alpha(Theme.fg, 0.6)
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    MouseArea {
                        id: rsm
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.scan(true)
                    }
                }
            }

            Text {
                visible: !root.wifiOn
                text: "Wi-Fi is off"
                color: Qt.alpha(Theme.fg, 0.5)
                font.family: Theme.fontFamily
                font.pixelSize: 12
                leftPadding: 4
            }

            ListView {
                visible: root.wifiOn
                width: parent.width
                height: Math.min(contentHeight, 260)
                clip: true
                spacing: 2
                model: root.networks
                boundsBehavior: Flickable.StopAtBounds
                delegate: Column {
                    id: net
                    required property var modelData
                    width: ListView.view.width
                    spacing: 4

                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: 8
                        color: net.modelData.active ? Qt.alpha(Theme.accent, 0.18)
                             : nma.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            Text {
                                text: root.bars(net.modelData.signal)
                                color: net.modelData.active ? Theme.accent : Theme.cyan
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                            }
                            Text {
                                width: col.width - 110
                                elide: Text.ElideRight
                                text: net.modelData.ssid
                                color: net.modelData.active ? Theme.accent : Qt.alpha(Theme.fg, 0.9)
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: net.modelData.active
                            }
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.connecting === net.modelData.ssid ? "…"
                                : (net.modelData.known ? "󰆓 " : "") + (net.modelData.secure ? "󰌾" : "")
                            color: Qt.alpha(Theme.fg, 0.45)
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: nma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (!net.modelData.active) root.connectTo(net.modelData)
                        }
                    }

                    // inline password prompt
                    Rectangle {
                        visible: root.askPassFor === net.modelData.ssid
                        width: parent.width
                        height: 32
                        radius: 8
                        color: Qt.alpha(Theme.fg, 0.07)
                        border.width: 1
                        border.color: Qt.alpha(Theme.accent, 0.6)
                        onVisibleChanged: if (visible) passInput.forceActiveFocus()
                        TextInput {
                            id: passInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            clip: true
                            Keys.onReturnPressed: root.connectTo(net.modelData, text)
                            Keys.onEscapePressed: root.askPassFor = ""
                        }
                        Text {
                            visible: passInput.text === ""
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "password  ⏎"
                            color: Qt.alpha(Theme.fg, 0.4)
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Text {
                visible: root.error !== ""
                width: parent.width
                wrapMode: Text.Wrap
                text: root.error
                color: Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            Rectangle {
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: Qt.alpha(Theme.fg, 0.15)
            }

            Rectangle {
                width: parent.width
                height: 32
                radius: 8
                color: more.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰒓   Network app (VPN, profiles)"
                    color: Qt.alpha(Theme.fg, 0.9)
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                MouseArea {
                    id: more
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        panel.visible = false
                        Quickshell.execDetached([Theme.configDir + "/scripts/network"])
                    }
                }
            }
        }
    }
}
