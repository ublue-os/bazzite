import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "components"
import "pages"
import "setup"

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    color: Theme.bgDeep
    title: "Luna"

    property bool setupMode: !configManager.setupComplete
    property bool splashDone: false
    property int currentPage: 0  // 0=Home, 1=Library, 2=Stores, 3=Shows, 4=Settings

    // Star field background - always visible
    StarField {
        anchors.fill: parent
        z: 0
    }

    // Warp flash overlay
    WarpFlash {
        id: warpFlash
        anchors.fill: parent
        z: 100
    }

    // Splash screen
    SplashScreen {
        id: splash
        anchors.fill: parent
        visible: !splashDone
        z: 50
        onFinished: {
            splashDone = true
            warpFlash.flash()
        }
    }

    // Setup flow (first boot only)
    SetupFlow {
        id: setupFlow
        anchors.fill: parent
        visible: splashDone && setupMode
        z: 10
        onSetupComplete: {
            setupMode = false
            warpFlash.flash()
        }
    }

    // Main shell (nav rail + content)
    Item {
        id: shell
        anchors.fill: parent
        visible: splashDone && !setupMode
        opacity: visible ? 1.0 : 0.0
        z: 5

        Behavior on opacity {
            NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic }
        }

        NavRail {
            id: navRail
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            currentIndex: root.currentPage
            onNavigated: function(index) {
                if (root.currentPage !== index) {
                    root.currentPage = index
                    warpFlash.flash()
                    audioManager.play("navigate")
                }
            }
        }

        // Content area
        Item {
            id: contentArea
            anchors.left: navRail.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            HomePage {
                anchors.fill: parent
                visible: root.currentPage === 0
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }

            LibraryPage {
                anchors.fill: parent
                visible: root.currentPage === 1
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }

            StoresPage {
                anchors.fill: parent
                visible: root.currentPage === 2
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }

            ShowsPage {
                anchors.fill: parent
                visible: root.currentPage === 3
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }

            SettingsPage {
                anchors.fill: parent
                visible: root.currentPage === 4
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // Global keyboard navigation
    focus: true
    Keys.onPressed: function(event) {
        if (!splashDone || setupMode) return

        if (event.key === Qt.Key_Escape) {
            if (currentPage !== 0) {
                currentPage = 0
                warpFlash.flash()
                audioManager.play("back")
            }
            event.accepted = true
        }
    }
}
