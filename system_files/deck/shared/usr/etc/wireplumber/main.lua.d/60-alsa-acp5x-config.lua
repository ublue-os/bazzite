--ACP5X card hardware never hibernates, so remove the pops and lags.

table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources from card acp5x
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "acp5x" },
    },

    {
      -- Matches all sources from card acp6x
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "acp6x" },
    },

    {
      -- Matches all sources from SOF drivers
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "sof-nau8821-max" },
    },

    {
      -- Matches all sinks from card acp5x
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "acp5x" },
    },

    {
      -- Matches all sinks from card acp6x
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "acp6x" },
    },

    {
      -- Matches all sinks from card acp6x
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "sof-nau8821-max" },
    },


  },
  apply_properties = {
    ["session.suspend-timeout-seconds"] = 0,
    ["api.alsa.headroom"]      = 1024,

  }
})
