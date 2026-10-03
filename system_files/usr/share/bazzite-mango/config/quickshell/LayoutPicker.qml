import QtQuick
import Quickshell
import Quickshell.Io

// Layout + tweaks popup anchored under the layout button (right-click
// on empty bar opens it too — this is the port's one tweaks surface).
// Top: all fourteen mango layouts as glyph tiles; click applies via
// `mmsg dispatch setlayout`, panel stays open for experimenting.
// Middle: live tweaks — inner window gap (setoption, persisted to the
// mango-gaps state file Wm.qml re-applies on start), border width,
// master width and count (relative dispatches; tracked in Wm.qml, dimmed
// in layouts that ignore them), then blur / shadows / animations toggles
// and the unfocused-opacity slider (setoption, persisted to
// mango-effects). Bottom: bar height/scale, persisted to the state files
// Theme.qml watches.
Popout {
    id: root

    cardWidth: 340
    cardHeight: col.implicitHeight + 2 * cardPadding

    // scriptable open/close: qs -p ~/.config/suckless/quickshell ipc call layouts toggle
    IpcHandler {
        target: "layouts"
        function toggle(): void { root.visible = !root.visible }
    }
    // `tweaks` opens the same popup here (kept for cross-port parity:
    // bspwm's tweaks live in its picker too, and Bar.qml's right-click
    // uses this popup since BarTweaks folded in)
    IpcHandler {
        target: "tweaks"
        function toggle(): void { root.visible = !root.visible }
    }

    function persistFile(name, v) {
        Quickshell.execDetached(["sh", "-c",
            "printf '%s\\n' " + v + " > '" + Theme.configDir + "/" + name + "'"])
    }

    component SectionLabel: Text {
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: true
        topPadding: 6
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        SectionLabel { text: "Layout" }

        Grid {
            id: layoutGrid
            width: parent.width
            columns: 3
            spacing: 4

            Repeater {
                model: Wm.layouts

                Rectangle {
                    id: tile
                    required property var modelData
                    required property int index
                    readonly property bool current: Wm.layoutIndex === index

                    width: (layoutGrid.width - 8) / 3
                    height: 52
                    radius: 8
                    color: current ? Theme.selbg
                         : tileMa.containsMouse ? Qt.alpha(Theme.fg, 0.12)
                         : Qt.alpha(Theme.fg, 0.04)

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.glyph
                            color: tile.current ? Theme.selfg : Theme.cyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.name
                            color: tile.current ? Theme.selfg : Qt.alpha(Theme.fg, 0.8)
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: tile.current
                        }
                    }

                    MouseArea {
                        id: tileMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Wm.setLayout(tile.index)
                    }
                }
            }
        }

        SectionLabel { text: "Desktop" }

        TweakSlider {
            label: "window gap"
            from: 0; to: 40
            value: Wm.gaps
            suffix: " px"
            applyFn: v => Wm.setGaps(v)
            persistFn: v => root.persistFile("mango-gaps", v)
        }
        TweakSlider {
            label: "border width"
            from: 0; to: 6
            value: Wm.borderpx
            suffix: " px"
            applyFn: v => Wm.setBorder(v)
            persistFn: v => Wm.persistEffects()
        }
        // master sliders dim in layouts whose arrange ignores them
        TweakSlider {
            label: "master width"
            from: 20; to: 80
            value: Wm.mfact
            suffix: "%"
            applyFn: v => Wm.setMfact(v)
            persistFn: v => {}   // session state, nothing to persist
            enabled: Wm.layouts[Wm.layoutIndex].mfact
            opacity: enabled ? 1 : 0.35
        }
        TweakSlider {
            label: "master count"
            from: 1; to: 6
            value: Wm.nmaster
            applyFn: v => Wm.setNmaster(v)
            persistFn: v => {}   // session state, nothing to persist
            enabled: Wm.layouts[Wm.layoutIndex].nmaster
            opacity: enabled ? 1 : 0.35
        }

        SectionLabel { text: "Effects" }

        // live through setoption, persisted to mango-effects (Wm.qml)
        Grid {
            id: fxGrid
            width: parent.width
            columns: 3
            spacing: 4

            Repeater {
                model: [
                    { icon: "󰂲", label: "Blur", active: Wm.blur,
                      run: () => Wm.setEffect("blur", !Wm.blur) },
                    { icon: "󰘷", label: "Shadows", active: Wm.shadows,
                      run: () => Wm.setEffect("shadows", !Wm.shadows) },
                    { icon: "󰐊", label: "Animate", active: Wm.animations,
                      run: () => Wm.setEffect("animations", !Wm.animations) }
                ]
                TogglePill { width: (fxGrid.width - 8) / 3 }
            }
        }
        // windows without focus fade toward the wallpaper; 100 = off.
        // Pairs with a thin border: once the stack dims, the border isn't
        // the only focus cue any more.
        TweakSlider {
            label: "unfocused opacity"
            from: 70; to: 100
            value: Wm.unfocusedOpacity
            suffix: "%"
            applyFn: v => Wm.setUnfocusedOpacity(v)
            persistFn: v => Wm.persistEffects()
        }

        SectionLabel { text: "Bar" }

        TweakSlider {
            label: "bar height"
            from: 20; to: 72
            value: Theme.barHeight
            suffix: " px"
            applyFn: v => Theme.barHeight = v
            persistFn: v => root.persistFile("bar-height", v)
        }
        TweakSlider {
            label: "element scale"
            from: 0.7; to: 2.0
            value: Theme.barUserScale
            isInt: false
            suffix: "×"
            applyFn: v => Theme.barUserScale = v
            persistFn: v => root.persistFile("bar-scale", v)
        }
    }
}
