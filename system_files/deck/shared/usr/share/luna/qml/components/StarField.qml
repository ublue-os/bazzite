import QtQuick
import ".."

Item {
    id: starField

    // Generate star layers for depth
    Repeater {
        model: 120

        Rectangle {
            id: star
            property real startX: Math.random() * starField.width
            property real startY: Math.random() * starField.height
            property real starSize: Math.random() * 2.5 + 0.5
            property real twinkleSpeed: Math.random() * 3000 + 2000
            property real twinkleMin: Math.random() * 0.2 + 0.1
            property real layer: Math.random()

            x: startX
            y: startY
            width: starSize
            height: starSize
            radius: starSize / 2
            color: layer > 0.85 ? Theme.accentCyan :
                   layer > 0.7 ? Theme.accentBlue :
                   Theme.textPrimary
            opacity: twinkleMin

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: star.layer > 0.7 ? 0.9 : 0.7
                    duration: star.twinkleSpeed
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: star.twinkleMin
                    duration: star.twinkleSpeed
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // Occasional shooting star
    Rectangle {
        id: shootingStar
        width: 40
        height: 1.5
        radius: 1
        color: Theme.accentCyan
        opacity: 0
        rotation: -25

        // Gradient trail effect
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.7; color: Theme.accentCyan }
            GradientStop { position: 1.0; color: "white" }
        }

        SequentialAnimation {
            id: shootAnim
            loops: Animation.Infinite

            PauseAnimation { duration: Math.random() * 8000 + 6000 }
            ParallelAnimation {
                NumberAnimation {
                    target: shootingStar; property: "opacity"
                    from: 0; to: 0.8; duration: 100
                }
                NumberAnimation {
                    target: shootingStar; property: "x"
                    from: starField.width * 0.2; to: starField.width * 0.8
                    duration: 800; easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: shootingStar; property: "y"
                    from: starField.height * 0.1; to: starField.height * 0.5
                    duration: 800; easing.type: Easing.InQuad
                }
            }
            NumberAnimation {
                target: shootingStar; property: "opacity"
                to: 0; duration: 200
            }
            PauseAnimation { duration: Math.random() * 12000 + 8000 }
        }

        Component.onCompleted: shootAnim.start()
    }

    // Subtle nebula glow spots (soft colored circles)
    Repeater {
        model: 3

        Rectangle {
            property real cx: Math.random() * starField.width
            property real cy: Math.random() * starField.height
            x: cx - 150
            y: cy - 150
            width: 300
            height: 300
            radius: 150
            color: index === 0 ? Theme.accentBlue : Theme.accentCyan
            opacity: 0.03

            NumberAnimation on opacity {
                from: 0.02; to: 0.06
                duration: 5000 + index * 2000
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }
        }
    }
}
