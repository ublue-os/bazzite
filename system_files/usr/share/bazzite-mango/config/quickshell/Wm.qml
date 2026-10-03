pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tag state + control — mango backend. `mmsg watch all-monitors` streams
// one JSON line per compositor state change (tags, focus, layout, title)
// and emits a snapshot on connect, so this is the whole read side: no
// polling, no WM patch. Actions go through `mmsg dispatch`. mmsg needs
// MANGO_INSTANCE_SIGNATURE; scripts/mango-ipc fills it in when the bar
// was started outside the compositor's environment.
Singleton {
    id: root

    property int seltags: 1
    property int occtags: 0
    property int urgtags: 0
    property int tagCount: 9
    property string title: ""
    property string monitor: ""     // focused output name (dispatch target)
    // per-output tag state, keyed by output name: { sel, occ, urg } bitmasks,
    // so each monitor's bar shows its own tags
    property var mons: ({})
    property int monitorCount: 1

    readonly property string ipc: Theme.configDir + "/scripts/mango-ipc"
    function dispatch(cmd) { Quickshell.execDetached([ipc, "dispatch", cmd]) }

    // --- layout: mirrors layouts[] in mango's src/layout/layout.h (symbol
    // is what the IPC reports; name is what setlayout takes). mfact and
    // nmaster flags mark the layouts whose arrange honours them. ---
    readonly property var layouts: [
        { name: "tile",              symbol: "T",  glyph: "󰙀", mfact: true,  nmaster: true  },
        { name: "scroller",          symbol: "S",  glyph: "󰕭", mfact: false, nmaster: false },
        { name: "grid",              symbol: "G",  glyph: "󰝘", mfact: false, nmaster: false },
        { name: "monocle",           symbol: "M",  glyph: "󰕮", mfact: false, nmaster: false },
        { name: "deck",              symbol: "K",  glyph: "󱇙", mfact: true,  nmaster: true  },
        { name: "center tile",       symbol: "CT", glyph: "󰕬", mfact: true,  nmaster: true  },
        { name: "right tile",        symbol: "RT", glyph: "󰙀", mfact: true,  nmaster: true  },
        { name: "vert scroller",     symbol: "VS", glyph: "󱒉", mfact: false, nmaster: false },
        { name: "vert tile",         symbol: "VT", glyph: "󱒈", mfact: true,  nmaster: true  },
        { name: "vert grid",         symbol: "VG", glyph: "󰕯", mfact: false, nmaster: false },
        { name: "vert deck",         symbol: "VK", glyph: "󱇚", mfact: true,  nmaster: true  },
        { name: "dwindle",           symbol: "DW", glyph: "󰕴", mfact: false, nmaster: false },
        { name: "fair",              symbol: "F",  glyph: "󰕫", mfact: false, nmaster: false },
        { name: "vert fair",         symbol: "VF", glyph: "󰪷", mfact: false, nmaster: false }
    ]
    // setlayout wants the snake_case name; the table shows a spaced one
    readonly property var layoutIds: ["tile", "scroller", "grid", "monocle", "deck",
        "center_tile", "right_tile", "vertical_scroller", "vertical_tile",
        "vertical_grid", "vertical_deck", "dwindle", "fair", "vertical_fair"]
    property int layoutIndex: 0

    // desktop tweaks. mango exposes no getters for these, and its setters
    // are relative (setmfact +0.05, incnmaster +1) or config options
    // (setoption gappih N), so the bar keeps the authoritative value: gaps
    // from the mango-gaps state file (re-applied on start, like dwm's),
    // mfact/nmaster from config.conf's defaults, then tracked locally.
    property int gaps: 5
    property int mfact: 55
    property int nmaster: 1
    property bool follow: false     // no follow toggle on mango; kept for parity
    function toggleFollow() {}

    // effects: blur / shadows / animations toggles, plus border width and
    // unfocused-window opacity sliders, all set live by the picker
    // (setoption) and persisted to mango-effects so they survive a bar
    // restart and a config reload (which resets setoption values). No
    // file = config.conf's values, which these defaults mirror; nothing
    // is pushed to the compositor until the user has touched a control.
    property bool blur: false
    property bool shadows: true
    property bool animations: true
    property int borderpx: 2
    property int unfocusedOpacity: 100   // percent; 100 = no dimming
    property bool effectsFromFile: false
    function applyEffects() {
        if (!effectsFromFile) return
        dispatch("setoption,blur," + (blur ? 1 : 0))
        dispatch("setoption,shadows," + (shadows ? 1 : 0))
        dispatch("setoption,animations," + (animations ? 1 : 0))
        dispatch("setoption,borderpx," + borderpx)
        dispatch("setoption,unfocused_opacity," + (unfocusedOpacity / 100).toFixed(2))
    }
    function persistEffects() {
        Quickshell.execDetached(["sh", "-c",
            "printf 'blur=%s\\nshadows=%s\\nanimations=%s\\nborderpx=%s\\nunfocused_opacity=%s\\n' "
            + (blur ? 1 : 0) + " " + (shadows ? 1 : 0) + " " + (animations ? 1 : 0)
            + " " + borderpx + " " + unfocusedOpacity
            + " > '" + Theme.configDir + "/mango-effects'"])
    }
    function setEffect(name, on) {
        root[name] = on
        effectsFromFile = true
        applyEffects()
        persistEffects()
    }
    // slider paths: applied live while dragging, persisted on release
    function setBorder(v) {
        borderpx = v
        effectsFromFile = true
        dispatch("setoption,borderpx," + v)
    }
    function setUnfocusedOpacity(pct) {
        unfocusedOpacity = pct
        effectsFromFile = true
        dispatch("setoption,unfocused_opacity," + (pct / 100).toFixed(2))
    }

    function setLayout(i) { dispatch("setlayout," + layoutIds[i]) }
    function cycleLayout(dir) {
        setLayout(((layoutIndex + dir) % layouts.length + layouts.length) % layouts.length)
    }
    function applyGaps(v) {
        // "window gap" = inner gaps
        dispatch("setoption,gappih," + v)
        dispatch("setoption,gappiv," + v)
        applyOuterGaps()
    }
    // outer gaps = the bar's edge inset (Theme.edgeInset, scaled to the
    // screen), so windows float off the edges exactly like the bar does
    function applyOuterGaps() {
        dispatch("setoption,gappoh," + Theme.edgeInset)
        dispatch("setoption,gappov," + Theme.edgeInset)
    }
    Connections {
        target: Theme
        function onEdgeInsetChanged() { root.applyOuterGaps() }
    }
    function setGaps(v) { gaps = v; applyGaps(v) }
    function setMfact(pct) {
        const d = (pct - mfact) / 100
        if (Math.abs(d) < 0.005) return
        mfact = pct
        dispatch("setmfact," + (d > 0 ? "+" : "") + d.toFixed(2))
    }
    function setNmaster(n) {
        let steps = n - nmaster
        nmaster = n
        while (steps > 0) { dispatch("incnmaster,+1"); steps-- }
        while (steps < 0) { dispatch("incnmaster,-1"); steps++ }
    }

    // gaps state file: written by the picker slider, applied on bar start
    // (a config reload resets setoption values; scripts/mango-reload asks
    // for a re-apply through the "wm" IpcHandler in shell.qml)
    FileView {
        path: Theme.configDir + "/mango-gaps"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const v = parseInt(text())
            if (!isNaN(v)) { root.gaps = v; root.applyGaps(v) }
        }
    }

    // effects state file, same lifecycle as the gaps one
    FileView {
        path: Theme.configDir + "/mango-effects"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            for (const line of text().split("\n")) {
                const [k, v] = line.split("=")
                const val = (v ?? "").trim()
                if (["blur", "shadows", "animations"].indexOf(k) >= 0)
                    root[k] = val === "1"
                else if (k === "borderpx" && !isNaN(parseInt(val)))
                    root.borderpx = parseInt(val)
                else if (k === "unfocused_opacity" && !isNaN(parseInt(val)))
                    root.unfocusedOpacity = parseInt(val)
            }
            root.effectsFromFile = true
            root.applyEffects()
        }
    }

    // --- state stream ---

    Process {
        id: watch
        command: [root.ipc, "watch", "all-monitors"]
        running: true
        stdout: SplitParser {
            onRead: line => root.parse(line)
        }
        // compositor restart / socket gone: come back on our own
        onExited: watchRetry.restart()
    }
    Timer {
        id: watchRetry
        interval: 2000
        onTriggered: watch.running = true
    }

    function parse(line) {
        let j
        try { j = JSON.parse(line) } catch (e) { return }
        const mons = j.monitors ?? []
        if (mons.length === 0) return
        const per = {}
        for (const mm of mons) {
            let s = 0, o = 0, u = 0
            for (const t of mm.tags ?? []) {
                const b = 1 << ((t.index ?? 1) - 1)
                if (t.is_active) s |= b
                if ((t.client_count ?? 0) > 0) o |= b
                if (t.is_urgent) u |= b
            }
            per[mm.name] = { sel: s, occ: o, urg: u }
        }
        root.mons = per
        monitorCount = mons.length
        let m = mons.find(x => x.active) ?? mons[0]
        monitor = m.name ?? ""
        let sel = 0, occ = 0, urg = 0
        const tags = m.tags ?? []
        for (const t of tags) {
            const bit = 1 << ((t.index ?? 1) - 1)
            if (t.is_active) sel |= bit
            if ((t.client_count ?? 0) > 0) occ |= bit
            if (t.is_urgent) urg |= bit
        }
        tagCount = tags.length || 9
        seltags = sel
        occtags = occ
        urgtags = urg
        title = m.active_client?.title ?? ""
        const li = layouts.findIndex(l => l.symbol === (m.layout_symbol ?? "T"))
        if (li >= 0) layoutIndex = li
    }

    // --- actions ---

    function viewTag(i) { dispatch("view," + (i + 1)) }
    function toggleViewTag(i) { dispatch("toggleview," + (i + 1)) }
    function sendToTag(i) { dispatch("tag," + (i + 1)) }
    function cycleTag(dir) { dispatch(dir > 0 ? "viewtoright_have_client" : "viewtoleft_have_client") }

    function openLauncher() {
        Quickshell.execDetached(["rofi", "-show", "drun", "-modi", "drun",
            "-line-padding", "4", "-hide-scrollbar", "-show-icons",
            "-theme", Theme.configDir + "/rofi/config.rasi"])
    }
    function openPowerMenu() {
        Quickshell.execDetached([Theme.configDir + "/scripts/power"])
    }
}
