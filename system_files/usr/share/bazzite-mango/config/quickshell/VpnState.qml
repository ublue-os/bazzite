pragma Singleton
// Vendored unchanged from github.com/pjgeutjens/omarchy-expressvpn (MIT,
// (c) Pieter Geutjens): the expressvpnctl state machine. The bar widget
// and panel are re-skinned for this shell in ExpressVpn.qml.

import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property bool installed: false
  property string connectionState: "Unknown"
  property string region: ""
  property var regions: []
  property string tunnelIp: ""
  property string lastError: ""
  property int desiredState: -1
  property string _statusOutput: ""
  property string _statusError: ""
  property string _regionOutput: ""
  property string _regionsOutput: ""
  property string _actionOutput: ""
  property string _actionError: ""
  property string _routeOutput: ""

  readonly property bool connected: connectionState === "Connected"
  readonly property bool transitional: connectionState === "Connecting"
    || connectionState === "Reconnecting"
    || connectionState === "DisconnectingToReconnect"
    || connectionState === "Disconnecting"
  readonly property bool backendActive: connectionState !== "Disconnected"
    && connectionState !== "Unknown"
  readonly property bool active: desiredState === -1
    ? backendActive
    : desiredState === 1
  readonly property bool busy: actionProcess.running || transitional
  readonly property bool loadingRegions: regionsProcess.running
  readonly property bool loadingAddress: connected && routeProcess.running
  readonly property string statusText: {
    if (!installed) return "ExpressVPN CLI not found"
    if (lastError !== "") return "Action failed"
    if (desiredState === 1 && !connected) return "Connecting…"
    if (desiredState === 0 && connectionState !== "Disconnected") return "Disconnecting…"
    if (connectionState === "Connected") return "Connected"
    if (connectionState === "Connecting") return "Connecting…"
    if (connectionState === "Reconnecting") return "Reconnecting…"
    if (connectionState === "Interrupted") return "Connection interrupted"
    if (connectionState === "DisconnectingToReconnect") return "Changing connection…"
    if (connectionState === "Disconnecting") return "Disconnecting…"
    if (connectionState === "Disconnected") return "Disconnected"
    return "Checking…"
  }
  readonly property string locationText: markupSafeText(formatRegion(region))

  // PanelHero and the bar tooltip are shared Omarchy components whose Text
  // format is not configurable by plugins. Keep command-derived values from
  // ever looking like rich-text markup before passing them to those sinks.
  function markupSafeText(raw) {
    return String(raw || "")
      .replace(/[\x00-\x1f\x7f]/g, " ")
      .replace(/</g, "‹")
      .replace(/>/g, "›")
      .replace(/&/g, "＆")
  }

  function isSafeRegionId(value) {
    return /^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$/.test(String(value || "").trim())
  }

  function isKnownRegionId(value) {
    var target = String(value || "").trim()
    return target === "smart" || regions.indexOf(target) !== -1
  }

  function cleanOutput(raw) {
    var lines = String(raw || "").split(/\r?\n/)
    for (var i = lines.length - 1; i >= 0; i--) {
      var value = lines[i].trim()
      if (value !== "") return value
    }
    return ""
  }

  function elide(text) {
    var value = markupSafeText(text).replace(/\s+/g, " ").trim()
    return value.length > 180 ? value.substring(0, 177) + "…" : value
  }

  function routeIp(raw) {
    try {
      var routes = JSON.parse(String(raw || ""))
      if (!(routes instanceof Array) || routes.length === 0) return ""
      var candidate = String(routes[0].prefsrc || "").trim()
      return /^[0-9A-Fa-f:.]+$/.test(candidate) ? candidate : ""
    } catch (error) {
      return ""
    }
  }

  function formatRegion(value) {
    var clean = String(value || "").trim()
    if (clean === "") return "Not available"
    if (clean.toLowerCase() === "smart") return "Smart location"
    var words = clean.replace(/[-_]+/g, " ").split(/\s+/)
    var abbreviations = { usa: "USA", uk: "UK", uae: "UAE", dc: "DC" }
    for (var i = 0; i < words.length; i++) {
      if (words[i] === "") continue
      var lookup = words[i].toLowerCase()
      if (abbreviations[lookup]) words[i] = abbreviations[lookup]
      else words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
    }
    return words.join(" ")
  }

  function applyState(raw) {
    var state = cleanOutput(raw)
    var previousState = connectionState
    var known = [
      "Disconnected",
      "Connecting",
      "Connected",
      "Interrupted",
      "Reconnecting",
      "DisconnectingToReconnect",
      "Disconnecting"
    ]
    if (known.indexOf(state) === -1) {
      connectionState = "Unknown"
      return
    }

    connectionState = state
    if (state === "Disconnected") {
      tunnelIp = ""
      addressRetry.stop()
    } else if (state === "Connected" && previousState !== "Connected") {
      tunnelIp = ""
    }
    if (desiredState === 1 && state === "Connected") {
      desiredState = -1
      desiredTimeout.stop()
    } else if (desiredState === 0 && state === "Disconnected") {
      desiredState = -1
      desiredTimeout.stop()
    }

    if (state === "Connected" || region === "") refreshRegion()
  }

  function refresh() {
    if (!installed) {
      if (!whichProcess.running) {
        whichProcess.command = ["which", "expressvpnctl"]
        whichProcess.running = true
      }
      return
    }
    if (statusProcess.running || actionProcess.running || routeProcess.running) return
    _statusOutput = ""
    _statusError = ""
    statusProcess.command = ["expressvpnctl", "-t", "5", "get", "connectionstate"]
    statusProcess.running = true
    statusWatchdog.restart()
  }

  function refreshRegion() {
    if (!installed || regionProcess.running || actionProcess.running || routeProcess.running) return
    _regionOutput = ""
    regionProcess.command = ["expressvpnctl", "-t", "5", "get", "region"]
    regionProcess.running = true
  }

  function refreshRegions() {
    if (!installed || regionsProcess.running || actionProcess.running || routeProcess.running) return
    _regionsOutput = ""
    regionsProcess.command = ["expressvpnctl", "-t", "15", "get", "regions"]
    regionsProcess.running = true
  }

  function refreshAddress() {
    if (!installed || !connected || routeProcess.running) return
    if (statusProcess.running || regionProcess.running || regionsProcess.running
        || actionProcess.running) {
      addressRetry.restart()
      return
    }

    _routeOutput = ""
    routeProcess.command = ["ip", "-j", "route", "get", "1.1.1.1"]
    routeProcess.running = true
  }

  function applyRegions(raw) {
    var lines = String(raw || "").split(/\r?\n/)
    var next = []
    var seen = ({})
    for (var i = 0; i < lines.length; i++) {
      var value = lines[i].trim()
      if (!isSafeRegionId(value) || seen[value]) continue
      seen[value] = true
      next.push(value)
    }
    regions = next
  }

  function toggle() {
    if (!installed || actionProcess.running) return
    if (active) disconnect()
    else connect()
  }

  function connect() {
    if (!installed || actionProcess.running) return
    tunnelIp = ""
    desiredState = 1
    runAction(["expressvpnctl", "-t", "30", "connect"])
  }

  function connectTo(regionId) {
    if (!installed || actionProcess.running) return
    var target = String(regionId || "").trim()
    if (!isSafeRegionId(target) || !isKnownRegionId(target)) {
      lastError = "Unknown ExpressVPN location"
      if (regions.length === 0) refreshRegions()
      return
    }
    region = target
    tunnelIp = ""
    desiredState = 1
    runAction(["expressvpnctl", "-t", "30", "connect", target])
  }

  function disconnect() {
    if (!installed || actionProcess.running) return
    desiredState = 0
    runAction(["expressvpnctl", "-t", "15", "disconnect"])
  }

  function runAction(command) {
    if (routeProcess.running) routeProcess.running = false
    addressRetry.stop()
    lastError = ""
    _actionOutput = ""
    _actionError = ""
    actionProcess.command = command
    actionProcess.running = true
    actionWatchdog.restart()
    desiredTimeout.restart()
  }

  Timer {
    id: refreshTimer
    interval: 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 500
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    id: addressRetry
    interval: 500
    repeat: false
    onTriggered: root.refreshAddress()
  }

  Timer {
    id: statusWatchdog
    interval: 7000
    repeat: false
    onTriggered: {
      if (!statusProcess.running) return
      statusProcess.running = false
      root.connectionState = "Unknown"
      root.lastError = "ExpressVPN did not answer the status request"
    }
  }

  Timer {
    id: actionWatchdog
    interval: 35000
    repeat: false
    onTriggered: {
      if (!actionProcess.running) return
      actionProcess.running = false
      root.desiredState = -1
      root.lastError = "ExpressVPN did not finish the requested action"
      delayedRefresh.restart()
    }
  }

  Timer {
    id: desiredTimeout
    interval: 35000
    repeat: false
    onTriggered: {
      root.desiredState = -1
      root.refresh()
    }
  }

  Process {
    id: whichProcess
    running: false
    command: []
    onExited: function(exitCode) {
      root.installed = exitCode === 0
      if (root.installed) {
        root.lastError = ""
        root.refresh()
        root.refreshRegion()
        root.refreshRegions()
      } else {
        root.connectionState = "Unknown"
        root.region = ""
        root.tunnelIp = ""
      }
    }
  }

  Process {
    id: statusProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: statusStdout
      waitForEnd: true
      onStreamFinished: root._statusOutput = text
    }
    stderr: StdioCollector {
      id: statusStderr
      waitForEnd: true
      onStreamFinished: root._statusError = text
    }
    onExited: function(exitCode) {
      statusWatchdog.stop()
      var stdout = String(root._statusOutput || statusStdout.text || "")
      var stderr = String(root._statusError || statusStderr.text || "")
      if (exitCode === 0) root.applyState(stdout)
      else {
        root.connectionState = "Unknown"
        if (!actionProcess.running) root.lastError = root.elide(stderr || stdout || "Could not read ExpressVPN status")
      }
    }
  }

  Process {
    id: regionProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: regionStdout
      waitForEnd: true
      onStreamFinished: root._regionOutput = text
    }
    onExited: function(exitCode) {
      var nextRegion = root.cleanOutput(root._regionOutput || regionStdout.text)
      if (exitCode === 0) root.region = root.isSafeRegionId(nextRegion) ? nextRegion : ""
      root.refreshAddress()
    }
  }

  Process {
    id: regionsProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: regionsStdout
      waitForEnd: true
      onStreamFinished: root._regionsOutput = text
    }
    onExited: function(exitCode) {
      if (exitCode === 0) root.applyRegions(root._regionsOutput || regionsStdout.text)
      root.refreshAddress()
    }
  }

  Process {
    id: routeProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: routeStdout
      waitForEnd: true
      onStreamFinished: root._routeOutput = text
    }
    onExited: function(exitCode) {
      var output = String(root._routeOutput || routeStdout.text || "")
      root.tunnelIp = exitCode === 0 && root.connected ? root.routeIp(output) : ""
    }
  }

  Process {
    id: actionProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: actionStdout
      waitForEnd: true
      onStreamFinished: root._actionOutput = text
    }
    stderr: StdioCollector {
      id: actionStderr
      waitForEnd: true
      onStreamFinished: root._actionError = text
    }
    onExited: function(exitCode) {
      actionWatchdog.stop()
      var stdout = String(root._actionOutput || actionStdout.text || "")
      var stderr = String(root._actionError || actionStderr.text || "")
      if (exitCode !== 0) {
        root.desiredState = -1
        desiredTimeout.stop()
        root.lastError = root.elide(stderr || stdout || "ExpressVPN command failed")
      } else {
        root.lastError = ""
      }
      delayedRefresh.restart()
    }
  }
}
