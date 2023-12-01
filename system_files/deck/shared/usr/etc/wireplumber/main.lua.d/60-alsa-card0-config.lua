-- HDMI output is always plugged in card 0 (HD_Audio Generic)
-- We always give higher priority to nodes from that card
-- Disable suspend timeout for HDMI to remove audio delay after idle

table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources from card HD-Audio Generic
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "HD-Audio Generic" },
    },
    {
      -- Matches all sinks from card HD-Audio Generic
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "HD-Audio Generic" },
    },
  },
  apply_properties = {
    ["priority.driver"]        = 900,
    ["priority.session"]       = 900,
    ["api.alsa.period-size"]   = 256,
    ["api.alsa.headroom"]      = 1024,
    ["session.suspend-timeout-seconds"] = 0
  }
})
