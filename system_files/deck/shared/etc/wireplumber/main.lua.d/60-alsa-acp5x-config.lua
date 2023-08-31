--ACP5X card hardware never hibernates, so remove the pops and lags.

table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources from card acp5x
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "acp5x" },
    },
    {
      -- Matches all sinks from card acp5x
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "acp5x" },
    },
  },
  apply_properties = {
    ["session.suspend-timeout-seconds"] = 0,
  }
})
