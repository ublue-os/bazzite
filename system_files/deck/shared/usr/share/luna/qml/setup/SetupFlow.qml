import QtQuick
import QtQuick.Controls
import ".."
import "../components"

Item {
    id: setupFlow
    signal setupComplete()

    property int step: 0  // 0 = name, 1 = wifi

    // Dim overlay
    Rectangle {
        anchors.fill: parent
        color: Theme.bgDeep
        opacity: 0.7
    }

    // Name setup (step 0)
    Item {
        anchors.fill: parent
        visible: setupFlow.step === 0
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingLg
            width: 500

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Welcome to Stellar OS"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "What should we call you?"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textSecondary
            }

            Item { width: 1; height: Theme.spacingSm }

            // Name input field
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 400
                height: 56
                radius: Theme.borderRadiusSm
                color: Theme.bgCard
                border.color: nameInput.activeFocus ? Theme.accentBlue : Theme.borderSubtle
                border.width: nameInput.activeFocus ? 2 : 1

                Behavior on border.color {
                    ColorAnimation { duration: Theme.animFast }
                }

                TextInput {
                    id: nameInput
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMd
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.textPrimary
                    selectionColor: Theme.accentBlue
                    clip: true
                    focus: setupFlow.step === 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Enter your name..."
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textDim
                        visible: !nameInput.text && !nameInput.activeFocus
                    }

                    Keys.onReturnPressed: confirmName()
                    Keys.onEnterPressed: confirmName()
                }
            }

            // Continue button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 48
                radius: Theme.borderRadiusSm
                color: nameInput.text.length > 0 ? (continueBtn.containsMouse ? Theme.accentGlow : Theme.accentBlue) : Theme.bgCard
                opacity: nameInput.text.length > 0 ? 1.0 : 0.5

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Text {
                    anchors.centerIn: parent
                    text: "Continue"
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.textPrimary
                }

                MouseArea {
                    id: continueBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: nameInput.text.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: confirmName()
                }
            }
        }
    }

    // WiFi setup (step 1)
    Item {
        anchors.fill: parent
        visible: setupFlow.step === 1
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingLg
            width: 500

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Connect to WiFi"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: wifiManager.connected ? "Connected!" : "Select a network or skip"
                font.pixelSize: Theme.fontSizeMedium
                color: wifiManager.connected ? Theme.successGreen : Theme.textSecondary
            }

            Item { width: 1; height: Theme.spacingSm }

            // Network list
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 440
                height: 280
                radius: Theme.borderRadius
                color: Theme.bgCard
                clip: true

                ListView {
                    id: networkList
                    anchors.fill: parent
                    anchors.margins: Theme.spacingXs
                    model: wifiManager.networks
                    spacing: 2

                    delegate: Rectangle {
                        width: networkList.width
                        height: 44
                        radius: 6
                        color: netMouse.containsMouse ? Theme.bgCardHover : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingMd
                            anchors.rightMargin: Theme.spacingMd
                            spacing: Theme.spacingSm

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.secure ? "🔒" : "📶"
                                font.pixelSize: 14
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.ssid
                                font.pixelSize: Theme.fontSizeNormal
                                color: Theme.textPrimary
                                width: parent.width - 100
                                elide: Text.ElideRight
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.signal + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textDim
                            }
                        }

                        MouseArea {
                            id: netMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                selectedNetwork = modelData.ssid
                                needsPassword = modelData.secure
                                if (!needsPassword) {
                                    wifiManager.connect_to(selectedNetwork, "")
                                } else {
                                    passwordPopup.open()
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Scanning for networks..."
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSizeNormal
                        visible: networkList.count === 0
                    }
                }
            }

            // Skip / Done buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingMd

                Rectangle {
                    width: 140
                    height: 48
                    radius: Theme.borderRadiusSm
                    color: skipBtn.containsMouse ? Theme.bgCardHover : Theme.bgCard

                    Text {
                        anchors.centerIn: parent
                        text: "Skip"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }

                    MouseArea {
                        id: skipBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: finishSetup()
                    }
                }

                Rectangle {
                    width: 140
                    height: 48
                    radius: Theme.borderRadiusSm
                    color: wifiManager.connected ? (doneBtn.containsMouse ? Theme.accentGlow : Theme.accentBlue) : Theme.bgCard
                    opacity: wifiManager.connected ? 1 : 0.4

                    Text {
                        anchors.centerIn: parent
                        text: "Done"
                        font.pixelSize: Theme.fontSizeNormal
                        font.bold: true
                        color: Theme.textPrimary
                    }

                    MouseArea {
                        id: doneBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: wifiManager.connected ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (wifiManager.connected) finishSetup()
                    }
                }
            }
        }
    }

    // Password popup
    property string selectedNetwork: ""
    property bool needsPassword: false

    Popup {
        id: passwordPopup
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true

        background: Rectangle {
            color: Theme.bgSurface
            radius: Theme.borderRadius
            border.color: Theme.borderSubtle
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingMd
            width: parent.width - Theme.spacingXl * 2

            Text {
                text: "Password for " + selectedNetwork
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 6
                color: Theme.bgCard
                border.color: pwInput.activeFocus ? Theme.accentBlue : Theme.borderSubtle

                TextInput {
                    id: pwInput
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSm
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textPrimary
                    echoMode: TextInput.Password
                    focus: passwordPopup.opened

                    Keys.onReturnPressed: connectWithPassword()
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: 6
                color: connectPwBtn.containsMouse ? Theme.accentGlow : Theme.accentBlue

                Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.textPrimary
                }

                MouseArea {
                    id: connectPwBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: connectWithPassword()
                }
            }
        }
    }

    function confirmName() {
        if (nameInput.text.length > 0) {
            configManager.setUserName(nameInput.text)
            setupFlow.step = 1
            wifiManager.scan()
            audioManager.play("select")
        }
    }

    function connectWithPassword() {
        wifiManager.connect_to(selectedNetwork, pwInput.text)
        passwordPopup.close()
        pwInput.text = ""
    }

    function finishSetup() {
        configManager.completeSetup()
        audioManager.play("transition")
        setupFlow.setupComplete()
    }

    Component.onCompleted: {
        if (wifiManager.connected) {
            // Already connected (wired), could skip WiFi step
        }
    }
}
