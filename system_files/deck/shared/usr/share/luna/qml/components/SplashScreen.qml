import QtQuick
import ".."

Item {
    id: splash
    signal finished()

    property bool loading: gameScanner.scanning

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Theme.bgDeep
        opacity: 0.85
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingLg

        // Logo / branding
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "✦ STELLAR OS ✦"
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
            font.letterSpacing: 8
            color: Theme.textPrimary

            // Subtle glow pulse
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.8; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.8; duration: 1500; easing.type: Easing.InOutSine }
            }
        }

        // Subtitle
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "L U N A"
            font.pixelSize: Theme.fontSizeLarge
            font.letterSpacing: 12
            color: Theme.accentCyan
            opacity: 0.9
        }

        Item { width: 1; height: Theme.spacingXl }

        // Loading indicator
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: 4

            // Track
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: Theme.borderSubtle
            }

            // Progress bar (indeterminate)
            Rectangle {
                id: progressBar
                height: parent.height
                radius: 2
                color: Theme.accentBlue
                width: parent.width * 0.3

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: -60; to: 200
                        duration: 1200
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: loading ? "Scanning game library..." : "Ready"
            font.pixelSize: Theme.fontSizeSmall
            font.letterSpacing: 2
            color: Theme.textDim
        }
    }

    // Auto-finish after minimum splash time + scan
    Timer {
        id: minTimer
        interval: 2500
        running: true
        onTriggered: {
            if (!splash.loading) {
                splash.finished()
            } else {
                waitForScan.running = true
            }
        }
    }

    Timer {
        id: waitForScan
        interval: 200
        repeat: true
        running: false
        onTriggered: {
            if (!splash.loading) {
                running = false
                splash.finished()
            }
        }
    }

    Connections {
        target: gameScanner
        function onScanComplete() {
            if (!minTimer.running) {
                splash.finished()
            }
        }
    }
}
