//@ pragma UseQApplication
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    // scripts/mango-reload: reload_config resets setoption values, so the
    // script asks the bar to push its gaps (inner + scaled outer) back
    IpcHandler {
        target: "wm"
        function applyGaps(): void { Wm.applyGaps(Wm.gaps) }
        function applyEffects(): void { Wm.applyEffects() }
    }
}
