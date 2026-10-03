import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default sink volume, Omarchy clicks: left / middle open the audio panel
// (slider, output picker, pavucontrol), right mutes, scroll adjusts.
BarModule {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var audio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property bool muted: audio?.muted ?? false
    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0

    // flash the % briefly on any change (volume keys included)
    property bool flash: false
    onVolumeChanged: { flash = true; flashTimer.restart() }
    onMutedChanged: { flash = true; flashTimer.restart() }
    Timer {
        id: flashTimer
        interval: 1500
        onTriggered: root.flash = false
    }

    icon: muted ? "󰝟" : volume < 25 ? "󰕿" : volume < 65 ? "󰖀" : "󰕾"
    iconColor: muted ? Qt.alpha(Theme.fg, 0.45) : Theme.fg
    // label only flashes on change — deliberate feedback, never hover
    label: flash ? (muted ? "--" : volume + "%") : ""

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (audio)
                audio.muted = !audio.muted
        } else
            popup.visible = !popup.visible
    }
    onScrolled: dir => {
        if (audio) {
            audio.muted = false
            audio.volume = Math.max(0, Math.min(1, audio.volume + dir * 0.02))
        }
    }

    VolumePopup {
        id: popup
        anchorItem: root
    }
}
