import QtQuick
import ".."

Rectangle {
    id: flash
    color: Theme.accentBlue
    opacity: 0

    function flash() {
        flashAnim.restart()
    }

    SequentialAnimation {
        id: flashAnim

        NumberAnimation {
            target: flash
            property: "opacity"
            from: 0; to: 0.6
            duration: 80
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: flash
            property: "opacity"
            from: 0.6; to: 0
            duration: Theme.animWarp
            easing.type: Easing.OutCubic
        }
    }
}
