import QtQuick
import Quickshell
import Quickshell.Io

// Weather: condition glyph + temperature from wttr.in (no API key),
// refreshed every 30 minutes. Click for the 3-day forecast card — same
// fetch, no extra requests. Hidden until the first successful fetch, so
// an offline boot just shows no weather.
//
// Location: by default wttr.in locates by IP — which reports the VPN exit
// node's weather when a VPN is up. Pin it by writing a city/zip to
// ~/.config/bspwm/weather-location (plain text, e.g. "Cleveland" or 44101).
//
// Units: auto — imperial locales get °F/mph, everyone else °C/km/h.
// Override with a single "f" or "c" in ~/.config/bspwm/weather-units.
BarModule {
    id: root

    visible: temp !== ""

    property string temp: ""
    property int code: 113

    property string unitsOverride: ""
    readonly property bool useF: unitsOverride === "f" ? true
                               : unitsOverride === "c" ? false
                               : Qt.locale().measurementSystem !== Locale.MetricSystem

    FileView {
        path: Theme.configDir + "/weather-units"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.unitsOverride = text().trim().toLowerCase()
        onLoadFailed: root.unitsOverride = "" // file removed → back to auto
    }

    // pin/unpin location → refetch right away instead of waiting 30 min
    // (deleting the file lands in loadFailed, so cover both paths)
    FileView {
        path: Theme.configDir + "/weather-location"
        watchChanges: true
        onFileChanged: {
            reload()
            fetch.running = false
            fetch.running = true
        }
        onLoadFailed: {
            fetch.running = false
            fetch.running = true
        }
    }

    property var lastJson: null
    onUseFChanged: if (lastJson) parse(lastJson)

    // WWO condition codes → a handful of glyph buckets
    function glyphFor(c) {
        if ([200, 386, 389, 392, 395].indexOf(c) !== -1) return "󰖓"
        if ([179, 182, 185, 227, 230, 317, 320, 323, 326, 329, 332, 335,
             338, 350, 368, 371, 374, 377].indexOf(c) !== -1) return "󰖘"
        if ([143, 248, 260].indexOf(c) !== -1) return "󰖑"
        if (c === 113) return "󰖙"
        if (c === 116) return "󰖕"
        if (c === 119 || c === 122) return "󰖐"
        return "󰖗"  // everything else in WWO's table is some kind of rain
    }

    icon: glyphFor(code)
    iconColor: Theme.yellow
    label: temp + "°"

    // Omarchy clicks: left forecast popup · right full weather as a
    // notification · middle refresh. (Location/units: menu → Setup → Weather.)
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            notifyFull()
        else if (mouse.button === Qt.MiddleButton) {
            fetch.running = false
            fetch.running = true
        } else
            forecast.visible = !forecast.visible
    }

    function notifyFull() {
        const u = useF ? "°F" : "°C"
        let body = forecast.condition + ", " + temp + u
        if (forecast.feels !== "") body += " (feels " + forecast.feels + u + ")"
        if (forecast.wind !== "") body += " · wind " + forecast.wind
        for (const d of forecast.days)
            body += "\n" + d.glyph + "  " + d.label + "  " + d.hi + "/" + d.lo + u + "  " + d.rain + "% rain"
        Quickshell.execDetached(["notify-send", "-a", "Weather", forecast.place || "Weather", body])
    }

    WeatherPopup {
        id: forecast
        anchorItem: root
    }

    property string _buf: ""
    Process {
        id: fetch
        command: ["sh", "-c",
            "LOC=$(tr -d '\\n' < \"" + Theme.configDir + "/weather-location\" 2>/dev/null | tr ' ' '+'); " +
            "curl -sf -m 10 \"https://wttr.in/${LOC}?format=j1\""]
        running: true
        stdout: SplitParser {
            onRead: line => root._buf += line
        }
        onRunningChanged: {
            if (running) {
                root._buf = ""
            } else {
                try {
                    root.parse(JSON.parse(root._buf))
                } catch (e) {
                    retry.start() // network hiccup — try again soon
                }
            }
        }
    }

    function parse(j) {
        lastJson = j
        const f = useF
        const c = j.current_condition[0]
        temp = f ? c.temp_F : c.temp_C
        code = parseInt(c.weatherCode) || 113
        forecast.condition = c.weatherDesc?.[0]?.value ?? ""
        const a = j.nearest_area?.[0]
        forecast.place = a ? [a.areaName?.[0]?.value,
                              a.region?.[0]?.value || a.country?.[0]?.value]
                              .filter(Boolean).join(", ") : ""
        forecast.feels = (f ? c.FeelsLikeF : c.FeelsLikeC) ?? ""
        forecast.wind = f ? (c.windspeedMiles ? c.windspeedMiles + "mph" : "")
                          : (c.windspeedKmph ? c.windspeedKmph + "km/h" : "")

        const days = []
        const names = ["today", "tomorrow"]
        for (let i = 0; i < Math.min(3, (j.weather ?? []).length); i++) {
            const d = j.weather[i]
            const noon = d.hourly?.[4] ?? d.hourly?.[0] ?? {}
            let rain = 0
            for (const h of d.hourly ?? [])
                rain = Math.max(rain, parseInt(h.chanceofrain) || 0)
            days.push({
                label: names[i] ?? new Date(d.date + "T12:00").toLocaleDateString(Qt.locale(), "ddd"),
                glyph: glyphFor(parseInt(noon.weatherCode) || 113),
                hi: (f ? d.maxtempF : d.maxtempC) ?? "?",
                lo: (f ? d.mintempF : d.mintempC) ?? "?",
                rain: rain
            })
        }
        forecast.days = days
    }

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: true
        onTriggered: { fetch.running = false; fetch.running = true }
    }
    Timer {
        id: retry
        interval: 3 * 60 * 1000
        onTriggered: { fetch.running = false; fetch.running = true }
    }
}
