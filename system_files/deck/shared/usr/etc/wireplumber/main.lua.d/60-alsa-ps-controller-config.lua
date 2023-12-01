-- PS4/PS5 Controller output is always referenced as Wireless Controller
-- We always give the lowest priority to nodes from that card

table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources from card Controller
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "Wireless Controller" },
    },
    {
      -- Matches all sinks from card Wireless Controller
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "Wireless Controller" },
    },
  },
  apply_properties = {
    ["priority.driver"]        = 99,
    ["priority.session"]       = 99,
  }
})
